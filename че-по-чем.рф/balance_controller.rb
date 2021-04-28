class Cabinet::Balance::BalanceController < Cabinet::CabinetController
	before_action :find_owned_adv, only: [:up, :prolongation,
		:vip, :unvip,
		:select, :unselect,
		:turbo, :unturbo,
		:constant, :unconstant,
		:url_share, :url_unshare]
	# ===========================================================
	# Отображение списка расходов пользователя
	def outgoings
		@menu = :wallet
		params.sanitize :page => {:type => :integer, :greater => 0, :allow_nil => true}

		@outs = current_user.outgoings.
			order('created_at DESC').page params[:page]

		infinity_scroll 'cabinet/balance/outgoings', @outs, 'cabinet/balance/outgoings', '#infinity-scroll #outgoings', true
	end
	# ===========================================================
	# Отображение списка пополнений пользователя
	def incomings
		@menu = :wallet
		params.sanitize :page => {:type => :integer, :greater => 0, :allow_nil => true}

		@incs = current_user.incomings.
			order('created_at DESC').page params[:page]

		infinity_scroll 'cabinet/balance/incomings', @incs, 'cabinet/balance/incomings', '#infinity-scroll #incomings', true
	end
	# ===========================================================
	# Отображение списка возвратов пользователя
	def refunds
		@menu = :wallet
		params.sanitize :page => {:type => :integer, :greater => 0, :allow_nil => true}

		@refunds = current_user.refunds.
			order('created_at DESC').page params[:page]

		infinity_scroll 'cabinet/balance/refunds', @refunds, 'cabinet/balance/refunds', '#infinity-scroll #refunds', true
	end
	# ===========================================================
	def up_process adv
		if !adv.is_a? ActiveAdv
			raise StatusExcpt.new :locked, 'Поднимать можно только активные объявления.'
		end

		if adv.expired?
			raise StatusExcpt.new :locked, 'Поднимать можно только не просроченные объявления.'
		end

		if adv.last_up_at and 1.day.ago<adv.last_up_at
			raise StatusExcpt.new :locked, 'Объявление можно поднимать не чаще, чем раз в сутки.'
		end
		@adv = adv
		@adv.update_attribute :last_up_at, Time.now
		@service = PriceList.up
		make_outgoing
		true
	end
	#Поднятие объявления
	def up
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			@price = check_creditworthiness :up
			return unless up_process @adv
		end
		notify_title = 'Активирована услуга'
		notify_msg = "Активирована услуга \"Поднятие в поиске\" для объявления №#{@adv.id}:#{@adv.title}"
		unless current_user.admin?
			notify notify_title,
					notify_msg,
					adv_path(@adv.secure).ru,
					:admin, :service_tag
		end
		activated_respond 'Объявление поднято.'
	end

	# ===========================================================
	#Выделение объявления
	def select
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			if !@adv.is_a? ActiveAdv
				raise StatusExcpt.new :locked, 'Выделять можно только активные объявления.'
			end
			if @adv.expired?
				raise StatusExcpt.new :locked, 'Выделять можно только не просроченные объявления.'
			end
			if @adv.turbo?
				raise StatusExcpt.new :locked, 'Запрещено. Уже активирована услуга Турбо-продажа.'
			end
			if @adv.vip?
				raise StatusExcpt.new :locked, 'Запрещено. Уже активирована услуга VIP-статус.'
			end
			if @adv.selected?
				raise StatusExcpt.new :locked, 'Объявление можно выделять не чаще, чем раз в неделю.'
			end

			# Проверяем платежеспособность. Проверка может окончится исключением и отменой транзакции.
			@price = check_creditworthiness :select
		
			# Обновляем временную метку последнего выделения объявления
			# Списываем средства и создаем запись в таблице расходов
			tm = Time.now
			if @adv.expired_at < tm+7.days
				exp = tm+7.days
			else
				exp = @adv.expired_at
			end
			@adv.update_attributes selected_expired_notified: nil, selected_at: tm, expired_at: exp
			make_outgoing
		end

		unless current_user.admin?
			notify 'Активирована услуга',
				"Активирована услуга \"Выделение на неделю\" для объявления №#{@adv.id}:#{@adv.title}",
				adv_path(@adv.secure).ru,
					:admin, :service_tag
		end
		activated_respond 'Объявление выделено на неделю.'
	end
	# ===========================================================
	# Отмена выделения
	def unselect
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			if !@adv.selected?
				raise StatusExcpt.new :locked, 'Отменить "Выделение на неделю" невозможно, т.к. действующей услуги нет.'
			end
			remove_selection @adv
		end
		deactivated_respond(
			'Выполнена отмена выделения объявления.',
			PriceList.select.price)
	end
	# ===========================================================
	# Турбо
	def turbo #ajax
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			if !@adv.is_a? ActiveAdv
				raise StatusExcpt.new :locked, 'Турбо-продажу можно применять только к активным объявлениям.'
			end
			if @adv.expired?
				raise StatusExcpt.new :locked, 'Турбо-продажу можно применять только к не просроченным объявлениям.'
			end
			if @adv.vip?
				raise StatusExcpt.new :locked, 'Запрещено. Уже активирована услуга VIP-статус.'
			end
			if @adv.turbo?
				raise StatusExcpt.new :locked, 'Турбо-продажу можно активировать не чаще, чем раз в неделю.'
			end


			# Проверяем платежеспособность. Проверка может окончится исключением и отменой транзакции.
			@price = check_creditworthiness :turbo
			
			# Обновляем временную метку последнего турбирования объявления
			# Списываем средства и создаем запись в таблице расходов 
			tm = Time.now
			if @adv.expired_at < tm+7.days
				exp = tm+7.days
			else
				exp = @adv.expired_at
			end
			@adv.update_attributes turbo_expired_notified: nil, turbo_at: tm, expired_at: exp
			make_outgoing
			remove_selection @adv if @adv.selected?
		end
		
		unless current_user.admin?
			notify 'Активирована услуга',
				"Активирована услуга \"Турбо-продажа\" на неделю для объявления №#{@adv.id}:#{@adv.title}",
				adv_path(@adv.secure).ru,
				:admin, :service_tag
		end
		activated_respond 'Турбо-продажа на неделю активирована.'
	end
	# ===========================================================
	# Отмена турбо
	def unturbo
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			if !@adv.turbo?
				raise StatusExcpt.new :locked, 'Отменить "Турбо-продажа на неделю" невозможно, т.к. действующей услуги нет.'
			end
			remove_turbo @adv
		end
		deactivated_respond(
			'Выполнена отмена турбо-продажи объявления.',
			PriceList.turbo.price)
	end
	# ===========================================================
	# VIP
	def vip
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			if !@adv.is_a? ActiveAdv
				raise StatusExcpt.new :locked, 'VIP можно применять только к активным объявлениям.'
			end
			if @adv.expired?
				raise StatusExcpt.new :locked, 'VIP можно применять только к не просроченным объявлениям.'
			end
			if @adv.vip?
				raise StatusExcpt.new :locked, 'VIP можно активировать не чаще, чем раз в неделю.'
			end

			# Проверяем платежеспособность. Проверка может окончится исключением и отменой транзакции.
			@price = check_creditworthiness :vip
			
			# Обновляем временную метку последнего турбирования объявления
			# Списываем средства и создаем запись в таблице расходов 
			tm = Time.now
			if @adv.expired_at < tm+7.days
				exp = tm+7.days
			else
				exp = @adv.expired_at
			end
			@adv.update_attributes vip_expired_notified: nil, vip_at: tm, expired_at: exp
			make_outgoing

			remove_selection @adv if @adv.selected?
			remove_turbo @adv if @adv.turbo?
		end

		unless current_user.admin?
			notify 'Активирована услуга',
				"Активирована услуга \"VIP на неделю\" для объявления №#{@adv.id}:#{@adv.title}",
				adv_path(@adv.secure).ru,
				:admin, :service_tag
		end
		activated_respond 'VIP на неделю активирована.'
	end
	# ===========================================================
	# Отмена VIP
	def unvip #ajax
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			if !@adv.vip?
				raise StatusExcpt.new :locked, 'Отменить "VIP на неделю" невозможно, т.к. действующей услуги нет.'
			end
			remove_vip @adv
		end
		deactivated_respond(
			'Выполнена отмена VIP объявления.',
			PriceList.vip.price)
	end
	# ===========================================================
	# Постоянное
	def constant #ajax
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			if !@adv.is_a? ActiveAdv
				raise StatusExcpt.new :locked, 'Услугу "Постоянное объявление" можно применять только к активным объявлениям.'
			end
			if @adv.expired?
				raise StatusExcpt.new :locked, 'Услугу "Постоянное объявление" можно применять только к не просроченным объявлениям.'
			end
			if @adv.constant?
				raise StatusExcpt.new :locked, 'Постоянное объявление можно активировать не чаще, чем раз в год.'
			end
	
			# Проверяем платежеспособность. Проверка может окончится исключением и отменой транзакции.
			@price = check_creditworthiness :constant
			
			# Обновляем временную метку последнего постоянства объявления
			# Обновляем временную метку последнего поднятия объявления объявления
			# Списываем средства и создаем запись в таблице расходов
			time = Time.now
			@adv.constant_at = time
			@adv.constant_expired_notified = nil
			@adv.expired_at = @adv.expired_at+1.year
			@adv.last_up_at = time
			@adv.save validate: false
			make_outgoing
		end

		unless current_user.admin?
			notify 'Активирована услуга',
				"Активирована услуга \"Автоматическое поднятие в течение года\" для объявления №#{@adv.id}:#{@adv.title}",
				adv_path(@adv.secure).ru,
				:admin, :service_tag
		end
		activated_respond 'Постоянное объявление на год активировано.'
	end
	# ===========================================================
	# Отмена постоянного
	def unconstant
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			if !@adv.constant?
				raise StatusExcpt.new :locked, 'Отменить "Постоянное на год" невозможно, т.к. действующей услуги нет.'
			end
			remove_constant @adv
		end
		deactivated_respond(
			'Выполнена отмена услуги "Постоянное на год".',
			PriceList.constant.price)
	end
	# ===========================================================
	# Продление объявления
	def prolongation_process adv
		time = Time.now
		@adv = adv
		# Списываем средства и создаем запись в таблице расходов
		if @adv.expired_at > time
			@adv.expired_at += 1.month
		else
			@adv.expired_at = time+1.month
		end
		#Сбрасываем метку уведомлен ли хозяин объявления об окончании
		#срока действия объявления
		@adv.expired_notified = false
		@adv.save validate: false
		@service = PriceList.prolongation
		try_set_active_adv! @adv
		make_outgoing
		true
	end

	def prolongation
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			if @adv.trashed
				raise StatusExcpt.new :locked, 'Продлевать объявление, лежащее в корзине нельзя.'
			end
			if @adv.blocked
				raise StatusExcpt.new :locked, 'Продлевать заблокированное объявление нельзя.'
			end
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'

			# Проверяем платежеспособность. Проверка может окончится исключением и отменой транзакции.
			@price = check_creditworthiness :prolongation
			prolongation_process @adv
		end

		notify_title = 'Активирована услуга'
		notify_msg = "Активирована услуга \"Продление\" на месяц для объявления №#{@adv.id}:#{@adv.title}. Объявление продлено до #{format_date @adv.expired_at}"
		unless current_user.admin?
			notify notify_title,
				notify_msg,
				adv_path(@adv.secure).ru,
				:admin, :service_tag
		end

		if request.get?
			flash[:success] = notify_msg
			redirect_to adv_path(@adv.secure)
		else
			activated_respond notify_msg
		end
	end

	def prolongation_all_non_active
		time = Time.now
		prolongation = PriceList.prolongation
		price = (1-current_user.discount/100.0)*prolongation.price
		price = eval(sprintf('%8.2f', price))
		price = 0.01 if price < 0.01
		@msg = ''
		@prolongated_advs = []
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			current_user.lock! 'FOR UPDATE'
			cnt = current_user.advs.
					where(empty: false, blocked: false, trashed: false, accessible: true).
					where("expired_at <= '#{time.to_s}'").count
			if price*cnt > current_user.amount
				raise StatusExcpt.new(:payment_required,
					"Недостаточно средств для продления #{cnt} объявлений. Пополните баланс и попробуйте снова.")
			end

			current_user.advs.lock('FOR UPDATE').
					where(empty: false, blocked: false, trashed: false, accessible: true).
					where("expired_at <= '#{time.to_s}'").find_each do |i|
				@prolongated_advs << i if prolongation_process(i)
				@msg << "#{i.title} истекает #{format_date i.expired_at}\n"
			end
		end
		total = "Продлено #{@prolongated_advs.count} объявлений\n"
		@msg << total
		notify 'Пакетное продление объявлений', @msg
		if @prolongated_advs.count > 0
			flash[:success] = total
		else
			flash[:notice] = total
		end
		redirect_to advs_index_path
	end

	def prolongation_all_active
		time = Time.now
		prolongation = PriceList.prolongation
		price = (1-current_user.discount/100.0)*prolongation.price
		price = eval(sprintf('%8.2f', price))
		price = 0.01 if price < 0.01
		@msg = ''
		@prolongated_advs = []
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'

			cnt = current_user.active_advs.where(accessible: true).count
			if price*cnt > current_user.amount
				raise StatusExcpt.new(:payment_required,
					"Недостаточно средств для продления #{cnt} объявлений. Пополните баланс и попробуйте снова.")
			end
			
			current_user.active_advs.where(accessible: true).find_each do |i|
				@prolongated_advs << i if prolongation_process(i)
				@msg << "#{i.title} истекает #{format_date i.expired_at}\n"
			end
		end
		total = "Продлено #{@prolongated_advs.count} объявлений\n"
		@msg << total
		notify 'Пакетное продление объявлений', @msg
		if @prolongated_advs.count > 0
			flash[:success] = total
		else
			flash[:notice] = total
		end
		redirect_to advs_index_path
	end
	def up_all_active
		time = Time.now
		up = PriceList.up
		price = (1-current_user.discount/100.0)*up.price
		price = eval(sprintf('%8.2f', price))
		price = 0.01 if price < 0.01
		@upped_advs = []
		@msg = ''
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'

			cnt = current_user.active_advs.where(accessible: true).count
			if price*cnt > current_user.amount
				raise StatusExcpt.new(:payment_required,
					"Недостаточно средств для поднятия #{cnt} объявлений. Пополните баланс и попробуйте снова.")
			end
		
			current_user.active_advs.where(accessible: true).find_each do |i|
				@upped_advs << i if up_process(i)
				@msg << "#{i.title} поднято\n"
			end
		end
		total = "Поднято в поиске #{@upped_advs.count} объявлений\n"
		@msg << total
		notify 'Пакетное поднятие объявлений', @msg
		if @upped_advs.count > 0
			flash[:success] = total
		else
			flash[:notice] = total
		end
		redirect_to advs_index_path
	end
	# ===========================================================
	# Внешняя ссылка
	def url_share
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			if @adv.expired?
				raise StatusExcpt.new :locked, 'Услугу "Внешняя ссылка" можно применять только к не просроченным объявлениям.'
			end
			if @adv.url.blank?
				raise StatusExcpt.new :locked, 'Услугу "Внешняя ссылка" можно применять только, если указан внешний url в настройках объявления.'
			end
			if @adv.url_share
				raise StatusExcpt.new :locked, 'Услуга "Внешняя ссылка" уже активирована.'
			end
			@price = check_creditworthiness :url_share
			@adv.update_attribute :url_share, true
			make_outgoing
		end
		unless current_user.admin?
			notify 'Активирована услуга',
				"Активирована услуга \"Внешняя ссылка\" для объявления №#{@adv.id}:#{@adv.title}",
				adv_path(@adv.secure).ru,
				:admin, :service_tag
		end

		msg = 'Активирована услуга "Внешняя ссылка".'
		if request.get?
			flash[:success] = msg
			redirect_to adv_path(@adv.secure)
		else
			activated_respond msg
		end
	end
	# ===========================================================
	# Отмена внешней ссылки
	def url_unshare
		# Начинаем транзакцию:
		ActiveRecord::Base.connection.transaction(isolation: :serializable) do
			# Ждем освобождения пользователя, в случае, если другая транзакция его уже захватила
			# а затем блокируем пользователя от изменения другими транзакциями - пусть все
			# ждут пока не определимся с окончательным значением баланса пользователя:
			current_user.lock! 'FOR UPDATE'
			# Дожидаемся освобождения объявления и блокируем его от изменений:
			@adv.lock! 'FOR UPDATE'
			if !@adv.url_share
				raise StatusExcpt.new :locked, 'Отменить "Внешняя ссылка" невозможно, т.к. действующей услуги нет.'
			end
			remove_url_share @adv
		end
		deactivated_respond(
			'Выполнена отмена услуги "Внешняя ссылка".',
			PriceList.url_share.price)
	end

private
	# ===========================================================
	# Проверка платежеспособности
	def check_creditworthiness name
		# Проверка платежеспособности вызвана с открытой транзакцией, 
		# если пользователь беден, то откатываем транзакцию
		@voucher = nil
		@service = PriceList.method(name).call
		price = (1-current_user.discount/100.0)*@service.price
		price = eval(sprintf('%8.2f', price))
		price = 0.01 if price < 0.01
		amount_enough = price <= current_user.amount

		# Отбираем и блокируем все ваучеры пользователя от изменений
		current_user.vouchers.lock('FOR UPDATE').active.each do |v|
			if v.kind == @service.id
				@voucher = v
				break
			end
		end
		unless amount_enough or @voucher
			raise StatusExcpt.new :payment_required, 'Недостаточно средств. Пополните баланс и попробуйте снова.'
		end
		@service	
	end
	# ===========================================================
	# Произвести списание
	def make_outgoing
		if @voucher
			puts 'Расплачиваемся ваучером'
			@voucher.burn
			return
		end
		out = nil
		final_price = @service.price*(1-current_user.discount/100.0)
		final_price = 0.01 if final_price < 0.01
		#Записываем расход в таблицу outgoings
		out = Outgoing.new
		out.user_id = current_user.id
		out.adv_id = @adv.id
		out.active_adv_id = @adv.id
		out.price_id = @service.id
		out.amount = final_price
		out.discount = current_user.discount
		out.created_at = Time.now
		out.updated_at = Time.now
		out.save

		if !out.errors.empty?
			rollback_db_transaction
			raise StatusExcpt.new :locked, out.errors.full_messages.to_s
		end
	
		#Списываем со счета ассигнации
		puts "Баланс пользователя до списания: #{current_user.amount}"
		puts "Сумма списания: #{final_price}"
		current_user.amount = current_user.amount - final_price
		puts "Баланс пользователя после списания: #{current_user.amount}"
		current_user.amount = eval(sprintf('%8.2f',current_user.amount))
		puts "Баланс пользователя после округления: #{current_user.amount}"
		current_user.save validate: false
		# Пишем лог
		Outgoings_LOG(current_user,@service,@adv)
		RedisCounters.inc_by 'outgoings', final_price
	end

	# ===========================================================
	def activated_respond msg
		ans = {
			response: msg,
			balance: triade(current_user.amount),
			info: @adv.info
		}
		render json: JSON.generate(ans)
	end
	# ===========================================================
	def deactivated_respond msg, price
		current_user.reload
		ans = {
			response: msg,
			balance: triade(current_user.amount),
			price: price,
			info: @adv.info
		}
		render json: JSON.generate(ans)
	end
end