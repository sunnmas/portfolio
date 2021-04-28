class Cabinet::PhoneController < Cabinet::CabinetController
	before_action :find_phone, only: [:update, :destroy]

	# Создание телефона
	def create
		raise StatusExcpt.new :locked, 'Телефон не передан.' if !params[:phone] 
		if current_user.phones.count>=ENV['max_phones_count_per_user'].to_i
			raise StatusExcpt.new :locked, "Допускается не более #{ENV['max_phones_count_per_user']} телефонов."
		end
		phone = Phone.new
		phone.user_id = current_user.id
		phone.phone = params[:phone]
		phone.save
		if !phone.errors.empty?
			raise ParamExcpt.new phone.errors.messages, 423
		end

		msg =  "Телефон #{phone(phone.phone_plus7)} добавлен."
		notify 'Добавление телефона', msg, user_aadvs_path(current_user).ru, :admin, :phone_tag
		render json: JSON.generate({ msg: msg, id: phone.id })
	end
	# ===========================================================
	# Изменение телефона
	def update
		if params[:phone].blank?
			raise ParamExcpt.new({phone: ['Телефон не передан.']}, 423)
		end
		
		if @phone.phone.to_i == params[:phone].to_i
			raise ParamExcpt.new({phone: ['Телефон не изменился.']}, 423)
		end

		@phone.update_attributes(:phone => params[:phone])

		if !@phone.errors.empty?
			raise ParamExcpt.new @phone.errors.messages, 423
		end
		msg =  "Телефон #{phone @phone.phone_plus7} отредактирован."
		notify 'Телефон изменен', msg, user_aadvs_path(current_user).ru, :admin, :phone_tag
		render json: JSON.generate({ msg: msg })
	end

	# ===========================================================
	# Удаление телефона
	def destroy
		# Удаляем телефон и все ссылки из объявлений на данный телефон с помощью транзакции:
		@phone.with_lock do
			if current_user.id == @phone.user_id
				owner = current_user
			else
				owner = @phone.user
			end
			owner.advs.where(phone_id: @phone.id).update_all(phone_id: nil)
			owner.active_advs.where(phone_id: @phone.id).update_all(phone_id: nil)
			@phone.destroy
		end
		msg = "Телефон #{phone @phone.phone_plus7} удален."
		notify 'Телефон удален', msg, user_aadvs_path(current_user).ru, :admin, :phone_tag
		render json: JSON.generate({ msg: msg })
	end
	# ===========================================================
	# Удаление телефонов
	def delete_all
		phones = current_user.phones
		# Удаляем телефоны и все ссылки из объявлений на данный телефон с помощью транзакции:
		for phone in phones
			phone.with_lock do
				if current_user.id == phone.user_id
					owner = current_user
				else
					owner = @phone.user
				end
				owner.advs.where(phone_id: phone.id).update_all(phone_id: nil)
				owner.active_advs.where(phone_id: phone.id).update_all(phone_id: nil)
				phone.destroy
			end
		end
		msg = 'Все телефоны удалены.'
		notify 'Телефоны удалены', msg, user_aadvs_path(current_user).ru, :admin, :phone_tag
		render json: JSON.generate({ msg: msg })
	end
private
	def find_phone
		raise StatusExcpt.new :locked, 'Телефон не передан.' if !params[:id]
		params.sanitize :id => {:type => :integer, :greater => 0}
		@phone = current_user.phones.where(:id => params[:id]).first
		raise StatusExcpt.new :forbidden, 'Телефон не принадлежит пользователю.' if !@phone
	end
end