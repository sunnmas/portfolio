class Cabinet::AvatarController < Cabinet::CabinetController
	# ===========================================================
	# Изменение аватара
	def change
		raise StatusExcpt.new :locked, 'Файл не передан.' if !params[:file] and !params[:id]
		if params[:file]
			file = params[:file]
			current_user.avatar = file
			current_user.save
			if !current_user.errors.empty?
				raise ParamExcpt.new current_user.errors.messages, 423
			end
			avatar = :special
			current_user.reload
			path = current_user.avatar.url
		else
			id = params[:id].to_i
			id = 1 if ![1,2,3,4].include? id
			current_user.predefined_avatar = id
			FileUtils.rm current_user.avatar.current_path rescue nil
			current_user.remove_avatar!
			current_user.save
			avatar = current_user.predefined_avatar
			path = ActionController::Base.helpers.image_path "svg/avatar-#{avatar}.svg"
		end

		msg = 'Аватар успешно загружен.'
		render json: JSON.generate({msg: msg, avatar: avatar, path: path})
	ensure
		begin
			# Удаляем временные файлы
			CarrierWave.clean_cached_files! 0
			path = file.path
			file.close
			FileUtils.rm path
			puts "Удален временный файл: #{path}"
		rescue => e
		end
	end
	# ===========================================================
	# Удаление аватара
	def destroy #ajax.post
		# Сначала проверим все ли поля у юзера валидны, потом удаляем
		current_user.save
		if !current_user.errors.empty?
			raise ParamExcpt.new current_user.errors.messages, 423
		end
		if ![1,2,3,4].include? current_user.predefined_avatar
			current_user.update_attribute :predefined_avatar, 1
		end
		FileUtils.rm current_user.avatar.current_path rescue nil
		current_user.remove_avatar!
		current_user.save
		avatar = current_user.predefined_avatar
		path = ActionController::Base.helpers.image_path "svg/avatar-#{avatar}.svg"

		msg = 'Аватар успешно удален.'
		render json: JSON.generate({msg: msg, avatar: avatar, path: path})
	end
end