require 'digest/md5'
class Cabinet::Balance::WalletoneController < Cabinet::CabinetController
	# Отключаем проверку CSRF
	skip_before_action :verify_authenticity_token, :only => [:result]
	skip_before_action :user_agreement, :only => [:result]
	skip_around_action :exception_handler, only: [:result]
	around_action :walletone_exception_handler, only: [:result]
	# ===========================================================
	#Пополнение счета
	def replenishment
		if current_user.phones.count == 0
			flash[:notice] = 'Добавьте контактный номер телефона'
			redirect_to edit_user_path(tab: 'телефоны')
			return
		end
		@menu = :wallet
		if Rails.env.production?
			@amount = 100
		else
			@amount = 10
		end
		@vouchers = current_user.vouchers.unburned
	end
	#'/подписать/платежную/форму'
	def signing
		# WMI_SIGNATURE = Base64(Byte(MD5(Windows1251(Sort(Params) + SecretKey))));
		ActiveRecord::Base.transaction do
			secure_code = rand 10000000..99999999
			pw = params[:WMI_PTENABLED]
			amount = params[:WMI_PAYMENT_AMOUNT]
			raise StatusExcpt.new 'Не задан способ расчета', :locked unless pw
			raise StatusExcpt.new 'Не задана сумма пополнения', :locked unless amount
			a = current_user.id.to_s
			(6-a.size).times {|i| a = '0'+a}
			b = current_user.incomings.count.to_s
			(6-b.size).times {|i| b = '0'+b}
			c = Digest::MD5.hexdigest(secure_code.to_s)
			orderN = "#{a}:#{b}:#{c[-6..-1]}"

			inc = Incoming.create(user_id: current_user.id,
				amount: amount.to_f,
				orderN: orderN,
				secure_code: secure_code,
				pay_way: pay_way(pw),
				pay_module: pay_module,
				expired_at: Time.now+30.day,
				status: 0)
			phone = current_user.phones.first
			fields = {
				'WMI_CUSTOMER_EMAIL' => current_user.email,
				'WMI_CURRENCY_ID' => '643',
				'WMI_CUSTOMER_PHONE' => "+7#{phone.phone}",
				'WMI_DESCRIPTION' => "BASE64:#{Base64.encode64("платеж на че.по.чем")[0..-2]}",
				'WMI_FAIL_URL' => "#{ENV["host_#{Rails.env}"]}#{payment_fail_path(inc_id: inc.id)}",
				'WMI_MERCHANT_ID' => Rails.application.credentials[Rails.env.to_sym][:walletone_merchant_id],
				'WMI_PAYMENT_AMOUNT' => amount,
				'WMI_PAYMENT_NO' => orderN,
				# 'WMI_CUSTOMER_FIRSTNAME' => 'UNKNOWN',
				# 'WMI_CUSTOMER_LASTNAME' => 'NAME',
				'WMI_PTENABLED' => pw,
				'WMI_SUCCESS_URL' => "#{ENV["host_#{Rails.env}"]}#{payment_success_path(inc_id: inc.id)}",
				'SC' => c[0..9]
			}

			signature = ''
			fields.keys.sort.each {|k| signature << fields[k]}
			signature << Rails.application.credentials[Rails.env.to_sym][:walletone_secret_key]
			signature.encode! 'cp1251'
			signature = Digest::MD5.base64digest signature
			fields['WMI_SIGNATURE'] = signature
			notify 'Подписана платежная форма',
				fields.inspect, user_aadvs_path(id: current_user.id), :admin
			render json: JSON.generate(fields)
		end
	end

	def success
		inc = Incoming.where(id: params[:inc_id]).first
		if inc
			if inc.status == 1
				flash[:success] = "Платеж прошел, Ваш баланс пополнен на сумму #{inc.amount} #{rub}!"
			elsif inc.status == 0
				flash[:success] = 'Платеж прошел, Ваш баланс будет пополнен в ближайшее время, как только будет получено уведомление об оплате.'
			else
				flash[:notice] = 'Возникли проблемы с платежем. Администрации направлено уведомление о проблеме.'
				notify "Необходимо разобраться с платежем #{inc.id}", 
				"Пользователь направлен на страницу успешного пополнения, но статус платежа равен #{inc.status}",
				user_aadvs_path(id: inc.user.id).ru, :admin
			end
		else
			flash[:alert] = "Платеж id:#{params[:inc_id]} не найден"
		end
		redirect_to replenishment_path
	end
	def fail
		inc = Incoming.where(id: params[:inc_id]).first
		if inc
			inc.update_attributes status: 2, params: params.inspect
			flash[:alert] = 'Платеж не прошел.'
			notify "Платеж #{inc.id} не прошел", 
				"Email: #{inc.user.email}",
				user_aadvs_path(id: inc.user.id).ru, :admin
		else
			flash[:alert] = "Платеж id:#{params[:inc_id]} не найден"
		end
		redirect_to replenishment_path
	end

	def result
		raise 'Не задан id получателя' unless params[:WMI_MERCHANT_ID]
		raise 'Не задано состояние заказа' unless params[:WMI_ORDER_STATE]
		raise 'Не задан номер заказа' unless params[:WMI_PAYMENT_NO]
		raise 'Не задан секретный код' unless params[:SC]
		raise 'Не задана сумма пополнения' unless params[:WMI_PAYMENT_AMOUNT]
		raise 'Не задана удержанная комиссия' unless params[:WMI_COMMISSION_AMOUNT]
		if params[:WMI_MERCHANT_ID] != Rails.application.credentials[Rails.env.to_sym][:walletone_merchant_id]
			raise 'Неверный id получателя'
		end

		#Вычислим подпись для поступивших данных
		# signature = ''
		# params.keys.sort.each {|k| signature << params[k] unless k == :WMI_SIGNATURE}
		# signature << Rails.application.secrets.walletone_secret_key
		# signature.encode! 'cp1251'
		# signature = Digest::MD5.base64digest signature
		# if signature != params[:WMI_SIGNATURE]
		# 	raise 'Не правильная цифровая подпись'
		# end
		inc = Incoming.where(orderN: params[:WMI_PAYMENT_NO]).first
		raise 'Не найден заказ' unless inc

		# Проверим секретный код платежа
		# secure = Digest::MD5.hexdigest inc.secure_code.to_s
		# raise "Не правильный секретный код #{secure}" if secure[0..9] != params[:SC]

		if params[:WMI_ORDER_STATE] == 'Accepted'
			# Если метод вызван повторно, то больше не начислять
			if inc.status != Incoming.pay_status(:payed)
				user = inc.user
				multiplier = 1
				if Time.now < ENV['promo_ends_at'].to_date &&
					user.registered_at
					multiplier = 2 if user.registered_at > 1.days.ago
				end

				sum = params[:WMI_PAYMENT_AMOUNT].to_f
				real_sum = sum - params[:WMI_COMMISSION_AMOUNT].to_f
				inc.with_lock do
					inc.update_attributes(status: Incoming.pay_status(:payed),
						real_sum: real_sum,
						sum: sum,
						amount: multiplier*sum
					)
					# inc.reload
					user.update_attribute :amount, user.amount+multiplier*sum
					Incomings_LOG user, inc.amount, inc.sum, inc.real_sum, params[:WMI_ORDER_STATE], params[:WMI_PAYMENT_NO]
					notify 'Баланс пополнен',
						"Баланс пополнен на сумму #{triade inc.sum} #{rub}. Зачислено #{triade inc.amount} #{rub}. Текущий баланс: #{triade user.amount} #{rub}",
						nil, user
					new_vip = '[+vip]' if user.first_pay?
					notify "+ #{triade inc.real_sum} #{rub} #{new_vip}",
						"Баланс пополнен на сумму #{triade inc.real_sum} #{rub}. Зачислено #{triade inc.amount} #{rub}.\n#{user.info}",
						user_aadvs_url(id: user.id).ru, :admin_slack

				end
				AdminMailer.new_money(user.id, inc.sum).deliver_later
				UserMailer.new_incoming(inc.id).deliver_later if user.notify_incomings
				RedisCounters.inc_by 'incomings', real_sum
			end
		else
			inc.update_attribute status: Incoming.pay_status(:failed)
			notify 'Баланс не пополнен',
					params.inspect,
					nil,:admin
		end
		render plain: 'WMI_RESULT=OK', status: 200
	ensure
		inc.update_attribute :params, params.inspect if inc
		log = "Был вызван метод result\r\n#{params}\r\n===========\r\n"
		File.open('log/incomings.log', 'a'){ |file| file.puts log}
	end
private
	def walletone_exception_handler
		yield
	rescue => e
		slack "*Платеж прошел. Баланс пользователя не пополнен* \r\n#{e.message}\r\n#{e.backtrace[0]}"
		log = "Платеж прошел. Баланс пользователя не пополнен\r\n#{e.message}\r\n#{e.backtrace[0]}\r\n#{params}\r\n===========\r\n"
		File.open('log/incomings.log', 'a'){ |file| file.puts log}
		render plain: "WMI_RESULT=RETRY&WMI_DESCRIPTION=#{URI::encode e.message}", status: 500
	end
	def pay_way x
		case x
		when 0 then 'CreditCardRUB'
		when 1 then 'QiwiWalletRUB'
		when 2 then 'AlfaclickRUB'
		when 3 then 'PsbRetailRUB'
		when 4 then 'EurosetRUB'
		when 5 then 'SvyaznoyRUB'
		when 6 then 'RussianPostRUB'
		when 7 then 'LiderRUB'
		when 8 then 'YandexMoneyRUB'
		when 'CreditCardRUB' then 0
		when 'QiwiWalletRUB' then 1
		when 'AlfaclickRUB' then 2
		when 'PsbRetailRUB' then 3
		when 'EurosetRUB' then 4
		when 'SvyaznoyRUB' then 5
		when 'RussianPostRUB' then 6
		when 'LiderRUB' then 7
		when 'YandexMoneyRUB' then 8
		end
	end
	def pay_module
		if ENV['payment_module'] == 'walletone'
			return 1
		else
			return 0
		end
	end
end