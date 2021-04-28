class Cabinet::UserController < Cabinet::CabinetController
	# skip_before_action :confirm_email

	# Загрузка всех данных, необходимых frontend
	def init_profile
		sleep 1
		if current_user.deleted_at
			removing = true
		else
			removing = false
		end
		if current_user.avatar&.url
			avatar = :special
			avatar_path = current_user.avatar&.url
		else
			avatar = current_user.predefined_avatar
			avatar = 1 if !avatar or !([1,2,3,4].include? avatar)
			avatar_path = ActionController::Base.helpers.image_path "svg/avatar-#{avatar}.svg"
		end
		phones = current_user.phones.map{|phone|
			{id: phone.id, val: phone.phone, original: phone.phone, errors: []}
		}
		profile = {
					stat: {
						id: current_user.id,
						provider: current_user.human_provider,
						removing: removing,
						confirmed: current_user.confirmed?,
						user_agreement: current_user.user_agreement,
						created_at: format_date(current_user.created_at),
						last_sign_in_at: format_date(current_user.last_sign_in_at),
						last_sign_in_ip: current_user.last_sign_in_ip,
						sign_in_count: current_user.sign_in_count,
						unconfirmed_email: current_user.unconfirmed_email,
						active_advs_cnt: current_user.active_advs.where(accessible: true).count,
						advs_cnt: current_user.advs.where(empty: false, accessible: true).count
					},
					avatar: {avatar: avatar, path: avatar_path},
					settings: {
						name: current_user.name,
						email: current_user.clean_email,
						company: current_user.company,
						notify_comments: current_user.notify_comments,
						notify_petitions: current_user.notify_petitions,
						notify_incomings: current_user.notify_incomings,
						notify_publications: current_user.notify_publications,
						notify_blocks: current_user.notify_blocks,
						notify_discount: current_user.notify_discount,
						notify_expired: current_user.notify_expired,
						notify_service_expired: current_user.notify_service_expired,
						notify_messages: current_user.notify_messages,
						theme: current_user.theme,
						adv_list_type: current_user.adv_list_type,
						message_sound: current_user.message_sound,
						error_sound:current_user.error_sound
					},
					phones: phones,
					geo: {geo_places: current_user.geo_places, digest: GeoObjects.digest}
				}
		render json: JSON.generate(profile)
	end
	# Отображение настроек профиля Vue
	def edit
		@menu = :settings
		if params['tab'] == 'телефоны'
			@tab = 'phones'
		elsif params['tab'] == 'география'
			@tab = 'geo'
		else
			@tab = 'settings'
		end
		render 'cabinet/profile/profile'
	end

	# ===========================================================
	# Постановка в очередь на удаление аккаунта
	def remove
		if current_user.deleted_at
			raise StatusExcpt.new :locked, 'Аккаунт уже на очереди на удаление.'
		end
		current_user.touch :deleted_at
		msg = 'Аккаунт будет удален через неделю.'
		notify 'Удаление аккаунта', msg
		if current_user.confirmed?
			UserMailer.remove(current_user.id).deliver_later
		end
		notify 'Пользователь решил удалить аккаунт',
			'', user_aadvs_path(current_user), :admin
		render json: JSON.generate({msg: msg})
	end
	# ===========================================================
	# Снятие с очереди на удаление аккаунта
	def restore #ajax.post + простой запрос на восстановление из письма
		if !current_user.deleted_at
			raise StatusExcpt.new :locked, 'Аккаунт не в очереди на удаление.'
		end
		current_user.update deleted_at: nil
		msg = 'Аккаунт снят с очереди на удаление.'
		notify 'Восстановление аккаунта', msg
		if current_user.confirmed?
			UserMailer.restored(current_user.id).deliver_later
		end
		# Для возможности восстановления аккаунта из почты:
		respond_to do |format|
			format.json {render json: JSON.generate({msg: msg})}
			format.html {
				flash[:success] = msg
				redirect_to edit_user_path('основные')
			}
		end
	end
	# ===========================================================
	# JSON Обновление настроек пользователя
	def update
		prev_email = current_user.clean_email
		prev_theme = current_user.theme
		current_user.update_attributes user_params
		if !current_user.errors.empty?
			raise ParamExcpt.new current_user.errors.messages, 423
		end

		# Если пользователь изменил почтовый ящик, то нужно уведомить его
		# об успешном завершении запроса, но потребовать подтвердить
		# владение вновь указанным почтовым ящиком
		if params[:user][:email] && prev_email!=params[:user][:email]
			msg = "Настройки успешно сохранены. На указанный адрес #{params[:user][:email]} отправлено"
			msg << ' письмо для подтверждения Вашего нового почтового ящика.'
			msg << ' Изменения в настройках вашего профиля вступят в силу после'
			msg << ' после подтверждения указанного email.'
			msg_type = :info
		else
			msg = 'Настройки успешно сохранены.'
			msg_type = :success
		end
		ans = {
			msg: msg,
			type: msg_type,
			unconfirmed_email: current_user.unconfirmed_email,
			email: current_user.clean_email
		}
		# Передаем путь к файлу стилей, на случай, если была смена цветовой схемы:
		if prev_theme != current_user.theme
			css = Themes.new(current_user.theme).css
			css = ActionController::Base.helpers.asset_path css, type: :stylesheet
			ans[:css] = css
		end
		render json: JSON.generate(ans)
	end
	# ===========================================================
	# Изменение пароля
	def update_password
		if params[:user][:password] != params[:user][:password_confirmation]
			raise ParamExcpt.new({password: ['Пароли не совпадают'], password_confirmation: ['Пароли не совпадают']}, 423)
		end
		current_user.update_attributes user_params_for_update_password
		if !current_user.errors.empty?
			raise ParamExcpt.new current_user.errors.messages, 423
		end

		# Sign in the user by passing validation in case their password changed
		bypass_sign_in(current_user)
		render json: JSON.generate({msg: 'Пароль успешно изменен.', type: :success})
	end

	# ===========================================================
	# Отмена изменения email
	def reject_email_change #ajax.post
		current_user.update_attribute :unconfirmed_email, nil
		render json: JSON.generate({msg: 'Изменение email успешно отменено.', email: current_user.email})
	end
private
	def user_params
		params.require(:user).permit(User.AcceptAttrs)
	end

	def user_params_for_update_password
	  # NOTE: Using `strong_parameters` gem
	  params.require(:user).permit(:password, :password_confirmation)
	end
end