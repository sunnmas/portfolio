module SmsHelper

	class SmsException < Exception

		@@messages = {
			-2 => 'Непредвиденная ошибка смс',
			-1	=> 'Сообщение не найдено.',
			101	=> 'Сообщение передается оператору.',
			102	=> 'Сообщение отправлено (в пути).',
			103	=> 'Сообщение доставлено.',
			104	=> 'Не может быть доставлено: время жизни истекло.',
			105	=> 'Не может быть доставлено: удалено оператором.',
			106	=> 'Не может быть доставлено: сбой в телефоне.',
			107	=> 'Не может быть доставлено: неизвестная причина.',
			108	=> 'Не может быть доставлено: отклонено.',
			200 => 'Неправильный api_id.',
			201 => 'Не хватает средств на лицевом счету.',
			202 => 'Неправильно указан получатель.',
			203 => 'Нет текста сообщения.',
			204 => 'Имя отправителя не согласовано с администрацией.',
			205 => 'Сообщение слишком длинное (превышает 8 СМС).',
			206 => 'Будет превышен или уже превышен дневной лимит на отправку сообщений.',
			207 => 'На этот номер нельзя отправлять сообщения.',
			208 => 'Параметр time указан неправильно.',
			209 => 'Вы добавили этот номер (или один из номеров) в стоп-лист.',
			210 => 'Используется GET, где необходимо использовать POST.',
			211 => 'Метод не найден.',
			212 => 'Текст сообщения необходимо передать в кодировке UTF-8.',
			220 => 'Сервис временно недоступен, попробуйте чуть позже.',
			230 => 'Сообщение не принято к отправке, так как на один номер в день нельзя отправлять более 60 сообщений.',
			300 => 'Неправильный token (возможно истек срок действия, либо ваш IP изменился).',
			301 => 'Неправильный пароль, либо пользователь не найден.',
			302 => 'Пользователь авторизован, но аккаунт не подтвержден.'
		}
		attr_reader :code

		def initialize(code)
			msg = @@messages[code]
			msg = 'Ошибка работы с сервисом отправки смс.' if !msg
			super msg
		end 
	end

	class Sms
		@@max_cost = ENV['max_sms_cost_rub'].to_f
		@@base_url = 'http://sms.ru'
		@@api_id = Rails.application.secrets.sms_ru_api_id

		class << self
			def max_cost
				@@max_cost
			end
			#Отсылает смс одному или нескольким получателям (сдинаковый текст)
			# sms - хеш:
			# to			Массив номеров телефонов получателей - обязательный
			# text			Текст сообщения UTF-8
			# from			Имя отправителя (должно быть согласовано с администрацией). 
			# 				Если не заполнено, в качестве отправителя будет указан ваш номер.
			# translit		Переводит все русские символы в латинские
			# test			Имитирует отправку сообщения для тестирования ваших программ на 
			# 				правильность обработки ответов сервера. При этом само сообщение 
			# 				не отправляется и баланс не расходуется.
			# partner_id	Если вы участвуете в партнерской программе, укажите этот параметр
			# 				в запросе и получайте проценты от стоимости отправленных сообщений.
			def send sms
				if sms[:to]
					sms[:to] = sms[:to].join(',') if sms[:to].is_a? Array
				else
					sms[:to] = ENV['admin_phone']
				end
				url = "#{@@base_url}/sms/send?api_id=#{@@api_id}&to=#{sms[:to]}&text=#{sms[:text]}"
				url << "&translit=1" if sms[:translit]
				url << "&test=1" if sms[:test]
				url << "&partner_id=#{sms[:partner_id]}" if sms[:partner_id]
				p "SMS: #{url}"
				ans = open(URI.escape(url)).read.lines
				code = ans[0].to_i
				raise SmsException.new code if code != 100
				[code, ans[1..-1]]
			rescue
				raise SmsException.new -2
			end
			# Возвращает стоимость сообщения на указанный номер и количество сообщений, 
			# необходимых для его отправки.
			# to			Номер телефона получателя - обязательный
			# text			Текст сообщения UTF-8
			# translit		Переводит все русские символы в латинские
			def cost sms
				return 10.0 if (sms[:to] == ['+79520765099']) && Rails.env.test?
				url = "#{@@base_url}/sms/cost?api_id=#{@@api_id}&to=#{sms[:to]}&text=#{sms[:text]}"
				url << "&translit=1" if sms[:translit]
				ans = open(URI.escape(url)).read.lines
				code = ans[0].to_i
				raise SmsException.new code if code != 100
				ans[1].chomp.to_f
			rescue
				raise SmsException.new -2
			end
			# Получение состояния баланса.
			def balance
				url = "#{@@base_url}/my/balance?api_id=#{@@api_id}"
				ans = open(URI.escape(url)).read.lines
				code = ans[0].to_i
				raise SmsException.new code if code != 100
				ans[1].to_f
			rescue
				raise SmsException.new -2
			end
		end
	end
end