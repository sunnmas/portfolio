class AdvsController < ApplicationController
	include SearchLoadFromSession

	def show
		@adv = ActiveAdv.where(:secure => params[:secure]).first
		@adv = Adv.where(:secure => params[:secure]).first if !@adv
		if !@adv
			if user_signed_in? and current_user.admin?
				@adv = ActiveAdv.where(:id => params[:secure]).first
				@adv = Adv.where(:id => params[:secure]).first if !@adv
				if @adv
					redirect_to adv_path(@adv.secure)
					return
				end
			end
		end
		adv_view_permissions
		
		@favs = []
		@is_liked = false
		if user_signed_in?
			# Получаем массив айдишников избранных объявлений
			# [adv_id, adv_id,..., adv_id]
			@favs = Favorite.where(user_id: current_user.id).to_a.map{|e| e.adv_id}
			@is_liked = true if Like.where(user_id: current_user.id, adv_id: @adv.id).count > 0
			@is_price_watched = true if PriceWatch.where(user_id: current_user.id, adv_id: @adv.id).count > 0
		end

		set_category_vars
		if !@is_owner && @adv.published
			@adv.update_column(:show_count, @adv.show_count+1)
		end
		@adv.update_column :last_view_at, Time.now #!!Не обновляем updated_at
		
		@no_photo = (@adv.photos.count == 0)

		@meta_keywords = Category.name(@adv.category) + ', '
		if @details
			@model.TreeAttrs.each do |struct|
				depth = struct[1].size
				tree = struct[3]
				path = []
				1.upto(depth) do |i|
					val = @details.method(struct[0].to_s+i.to_s).call
					break if val == nil
					path << val
					@meta_keywords << tree.node(path).to_s.gsub('*', '') << ', '
				end
			end
		end
	end
	# ===========================================================
	# Показывает телефон к объявлению
	def view_phone #ajax
		def notify_admin
			if user_signed_in?
				usr = "Пользователь:#{current_user.info}"
			else
				usr = 'Просмотр незарегистрированным пользователем'
			end
			msg = usr + "\t#{@adv.id}: #{@adv.title}"
			slack "*Просмотр телефона*\r\n#{@adv.title}\r\n#{adv_url(secure: @adv.secure).ru}\r\n#{usr}"
			notify 'Просмотр телефона', msg, adv_path(@adv.secure).ru, :admin
		end
		@without_layout = true
		params.sanitize :id => {:type => :integer, :greater => 0}
		@adv = ActiveAdv.where(:id => params[:id]).first
		@adv = Adv.where(:id => params[:id]).first if !@adv

		adv_view_permissions
		phone_view_permissions

		@phone_only = to_bool params[:phone_only]
		@show_phone = false
		@error = false
		if to_bool ENV['recaptcha_enable']
			if user_signed_in?
				views_count = current_user.phone_views_count
				if views_count < ENV['phone_views'].to_i
					current_user.update_attribute :phone_views_count, views_count+1
					@show_phone = true
					notify_admin
				else
					if verify_recaptcha
						current_user.update_attribute :phone_views_count, 0
						@show_phone = true
						notify_admin
					else
						@error = true if params['g-recaptcha-response']
					end
				end
			else
				if verify_recaptcha
					@show_phone = true
					notify_admin
				else
					@error = true if params['g-recaptcha-response']
				end
			end
		else
			@show_phone = true
			notify_admin
		end

		render :phone, layout: false
	end
	# ===========================================================
	# Рендерит комментарии объявления
	def comments #ajax
		@without_layout = true
		params.sanitize :id => {:type => :integer, :greater => 0}
		@adv = ActiveAdv.where(:id => params[:id]).first
		@adv = Adv.where(:id => params[:id]).first if !@adv
		adv_view_permissions
		render 'advs/comments/comments', layout: false
	end
	# ===========================================================
	# Возвращает в формате json список городов по массиву регионов
	def cities #ajax
		params.sanitize :region => {:type => :integer, :in => 0...GeoObjects.regions.count}
		region = params['region']
		cities = GeoObjects.cities(region).
					map{|i| {:name => i.name.gsub('*',''), :id => i.id, 
						:payload => GeoObjects.crypt_coordinates(i.lattitude, i.longitude),
						:capital => i.capital?, :have_metro => i.have_metro?}}.
					to_a
		render json: JSON.generate(cities)
	end
	# ===========================================================
	# Возвращает в формате json список районов по массиву городов
	def districts #ajax
		params.sanitize :region => {:type => :integer, :in => 0...GeoObjects.regions.count}
		region = params[:region]
		params.sanitize :city => {:type => :integer, :in => 0...GeoObjects.cities(region).count}
		city = params[:city]
		d = GeoObjects.districts(region, city).
				map{|i| {:name => i.clean_name, :id => i.id,
						:payload => GeoObjects.crypt_coordinates(i.lattitude, i.longitude),
						:metro => i.metro?}}.
				to_a
		render json: JSON.generate(d)
	end
	# ===========================================================
	# Список категорий по группе категорий
	def cats_by_group #ajax
	    params.sanitize :id => {:type => :integer, :in => 0...Category.groups_count}
	    res = Category.all_in_category_group(params[:id]).map{|x|
	            {:name => x.clean_name,
	            :id => x.id,
	            :demanded => x.demanded}
	        }
	    render json: JSON.generate(res)
	end

	# ===========================================================
	# Возвращает в формате json список вариантов выбора
	# для древовидного типа данных 
	def get_tree_entries #ajax
		@without_layout = true
		pars = {
			category: {:type => :integer, :in => 0...Category.count},
			prompt: :boolean
		}
		# puts 'пробуем санитайзить параметры'
		params.sanitize pars
		# puts 'параметры чистые'
		@prompt = params[:prompt]
		model = Category.model params[:category]
		symbol = params[:sym].to_sym
		tree = model.FindTreeAttr(symbol)[3]
		path = params[:path]
		raise StatusExcpt.new :server_error, 'Параметр path не передан.' if !path
		@entries = tree.entries path.map{|x| x.to_i}
		if @entries
			render '/advs/tree_entries', layout: false
		else
			render plain: ''
		end
	end

	def send_message_to_owner_form
		render 'advs/message/form', layout: false
	end
	def send_message_to_owner
		if to_bool ENV['recaptcha_enable']
			raise StatusExcpt.new :captcha unless Rails.env.test? || verify_recaptcha
		end
		raise StatusExcpt.new :locked, 'Объявление не передано.' if !params[:id]
		raise StatusExcpt.new :locked, 'Сообщение пустое.' if !params[:msg] || params[:msg] == ''
		@adv = ActiveAdv.where(id: params[:id]).first
		raise StatusExcpt.new :not_found, 'Объявление не найдено.' if !@adv or @adv.empty
		user = @adv.user
		raise StatusExcpt.new :forbidden, 'Пользователь запретил посылать ему сообщения.' if !user.notify_messages
		UserMailer.new_message(params[:msg], @adv.id, user.id).deliver_later
		res = {user: user.name}
		render json: JSON.generate(res)
	end

private
	def adv_view_permissions
		if !@adv or @adv.empty
			raise StatusExcpt.new :not_found, 'Объявление не найдено.'
		end

		if !@adv.accessible
			unless @admin
				raise StatusExcpt.new :forbidden, 'Объявление не доступно.'
			end
		end

		if user_signed_in?
			@is_owner = current_user.advs.include?(@adv) || current_user.active_advs.include?(@adv)
			@admin = current_user.try :admin?
		end

		if @adv.blocked
			unless @admin || @is_owner
				raise StatusExcpt.new :forbidden, 'Объявление заблокировано. Отображению не подлежит.'
			end
		end
	end

	def phone_view_permissions
		if !@adv.published
			unless @admin || @is_owner
				raise StatusExcpt.new :forbidden, 'Объявление в данный момент на модерации администратором. Попробуйте зайти позже.'
			end
		end

		@phone = @adv.phone
		if !@phone && !@adv.forced?
			unless @adv.user.phones.count > 0
				raise StatusExcpt.new :forbidden, 'Объявление не содержит телефона.'
			end
		end
		
		if @adv.trashed
			unless @admin || @is_owner
				raise StatusExcpt.new :forbidden, 'Владелец поместил объявление в корзину. Скорее всего он не хочет, чтобы в данный момент его беспокоили по поводу данного объявления.'
			end
		end

		if !@adv.accessible
			unless @admin
				raise StatusExcpt.new :forbidden, 'Объявление не доступно. Просмотр телефона невозможен.'
			end
		end
		
		if @adv.is_a? Adv
			unless @admin || @is_owner
				if @adv.expired?
					raise StatusExcpt.new :forbidden, 'Объявление просрочено. Просмотр телефона невозможен.'
				else
					raise StatusExcpt.new :forbidden, 'Объявление не активно. Просмотр телефона невозможен.'
				end
			end

		end
	end
end