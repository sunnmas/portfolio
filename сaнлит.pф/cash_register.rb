class CashRegister < ApplicationRecord
	belongs_to :user
	has_many :queries, dependent: :destroy

	class << self
		def human_plans
			['МИНИ','СТАНДАРТ', 'МАКСИМУМ', 'БЕЗ ДОГОВОРА']
		end

		def human_gsm_operators
			['Билайн', 'Мегафон', 'Теле2', 'МТС']
		end

		def human_ofds
			[
			'Без ОФД',
			'Такском',
			'ПЕТЕР-СЕРВИС Спецтехнологии',
			'Энергетические системы и коммуникации',
			'Эвотор ОФД',
			'Ярус',
			'Яндекс.ОФД',
			'Электронный экспресс',
			'КАЛУГА АСТРАЛ',
			'Тензор',
			'КОРУС Консалтинг СНГ',
			'СКБ Контур',
			'Тандер',
			'ИнитПро',
			'ГРУППА ЭЛЕМЕНТ',
			'ЭнвижнГруп',
			'Вымпел-Коммуникации',
			'МультиКарта',
			'Дримкас',
			'Контур НТТ']
		end

		def human_models
			[
				'Меркурий-130Ф',
				'Меркурий-180Ф',
				'АТОЛ FPrint-22ПТК',
				'АТОЛ 30Ф',
				'АТОЛ 55Ф',
				'АМС-100Ф',
				'ЭВОТОР СТ2Ф',
				'Меркурий-115Ф',
				'Меркурий-185Ф',
				'ШТРИХ-ФР-02Ф',
				'ЭЛВЕС-МФ',
				'РИТЕЙЛ-01Ф',
				'АТОЛ 11Ф',
				'ВИКИ ПРИНТ 57 Ф',
				'ШТРИХ-ON-LINE',
				'РР-01Ф',
				'ШТРИХ-ЛАЙТ-01Ф',
				'ШТРИХ-МИНИ-01Ф',
				'ШТРИХ-ФР-01Ф',
				'АТОЛ 77Ф',
				'ПИРИТ 2Ф',
				'ВИКИ МИНИ Ф',
				'АТОЛ 25Ф',
				'АТОЛ 52Ф',
				'АТОЛ 90Ф',
				'ШТРИХ-М-01Ф',
				'ШТРИХ-М-02Ф',
				'ВИКИ ПРИНТ 57 ПЛЮС Ф',
				'ПИРИТ 1Ф',
				'РР-02Ф',
				'ШТРИХ-ЛАЙТ-02Ф',
				'ПТК«MSTAR-TK»',
				'ПТК«MSPOS-K»',
				'ПТК«АЛЬФА-ТК»',
				'ПТК«IRAS 900 K»',
				'ЯРУС М2100Ф',
				'PAYONLINE-01-ФА',
				'ЭКР 2102К-Ф',
				'ВИКИ ПРИНТ 80 ПЛЮС Ф',
				'ПИРИТ 2СФ',
				'РР-03Ф',
				'РР-04Ф',
				'ПРИМ 07-Ф',
				'ПРИМ 21-ФА',
				'ПРИМ 08-Ф',
				'ПРИМ 88-Ф',
				'Пионер-114Ф',
				'ЯРУС ТФ',
				'Viki Tower F',
				'ШТРИХ-МИНИ-02Ф',
				'МИНИКА 1102МК-Ф',
				'ШТРИХ-МПЕЙ-Ф',
				'МК 35-Ф',
				'СПАРК-115-Ф',
				'PAY VKP-80K-ФА',
				'РП Система 1ФА',
				'POSprint FP510-Ф',
				'POSprint FP410-Ф',
				'ОРИОН-100Ф',
				'Меркурий-119Ф',
				'КАЗНАЧЕЙ ФА',
				'СП402-Ф',
				'СП101-Ф',
				'СП802-Ф',
				'ЧекВей77-Ф',
				'АТОЛ 42ФС',
				'ШТРИХ-МОБАЙЛ-Ф',
				'ЭЛВЕС-ФР-Ф',
				'WNJI-003Ф',
				'МИКРО 35G-Ф',
				'ПКТФ',
				'NCR-001Ф',
				'ЭЛВЕС-МИКРО-Ф',
				'АТОЛ 60Ф',
				'АТОЛ 15Ф',
				'Дримкас-Ф',
				'Терминал-ФА',
				'Касби-02Ф',
				'ЭВОТОР СТ3Ф',
				'CUSTOM Q3X-Ф',
				'РП Система 1ФС',
				'АМС-300Ф',
				'УМКА-01-ФА',
				'МЕЩЕРА-01-Ф',
				'ПРИМ 06-Ф',
				'ОКА-102Ф',
				'ars.mobile Ф',
				'К1-Ф',
				'МЁБИУС.NET.H21-Ф',
				'СП801-Ф',
				'NETPAY-ФС',
				'FIT-ONLINE-Ф',
				'ZEBRA-EZ320-Ф',
				'МЁБИУС.NET.T18-Ф',
				'АГАТ 1Ф',
				'ars.vera 01Ф',
				'ars.evo 01Ф',
				'Меркурий-МФ',
				'ЭЛВЕС-МИНИ-Ф',
				'АМС-300.1Ф',
				'ФЕЛИКС-РМФ',
				'FIT-NEWLINE-F',
				'АТОЛ 20Ф',
				'АТОЛ 50Ф',
				'SKY-PRINT 54-F',
				'КИТ Онлайн-Ф',
				'FN-1.online/ФАС',
				'Ока МФ',
				'Кассир 57Ф',
				'АТОЛ 91Ф',
				'ПОРТ-100Ф',
				'ПОРТ-1000Ф',
				'МТ01-Солитон mPOS-Ф',
				'ПТК«АЛЬФА-ТК-Ф»',
				'Эвотор СТ5Ф',
				'НЕВА-01-Ф',
				'АЗУР-01Ф',
				'МИКРО 106-Ф',
				'Кассатка-1Ф',
				'АТОЛ 92Ф',
				'АТОЛ 150Ф',
				'КИТ ШОП-Ф',
				'MicroPay-ФАС',
				'Касса Ф',
				'ШТРИХ-НАНО-Ф',
				'ШТРИХ-СМАРТПОС-Ф',
				'КАССИР 80Ф',
				'AQSI5-Ф',
				'АМС-700Ф',
				'СПЕКТР-ПС-Ф',
				'TZ Pro-F',
				'САЛЮТ-08Ф',
				'САЛЮТ-10Ф',
				'POSCENTER-Ф7L-Ф',
				'Уникум-ФА',
				'МИНИКА 1105К-Ф',
				'НКР-01-Ф',
			]
		end

		def human_ofd_interfaces
			['нет','SIM','WIFI','Ethernet','USB']
		end

		def human_pc_interfaces
			['нет','Ethernet','USB','COM','Bluetouth', 'RNDIS', 'WIFI']
		end

		def human_snos
			['Основная', 'Упрощенная доход', 'Упрощенная доход минус расход', 'ЕНВД', 'ЕСХН', 'Патент']
		end

		def permitted
			[
				:title,
				{:sno => []},
				:plan,
				:address,
				:place,
				:model,
				:ofd,
				:ofd_interface,
				:pc_interface,
				:wifi_ssid,
				:wifi_password,
				:gsm_operator,
				:lottery,
				:gamble,
				:bank_pay_agent,
				:pay_agent,
				:automat,
				:automat_number,
				:internet,
				:service,
				:bco,
				:excisable,
				:kassirs,
				:contact
			]
		end

		def bools
			[
				:lottery,
				:gamble,
				:bank_pay_agent,
				:pay_agent,
				:automat,
				:automat_number,
				:internet,
				:service,
				:bco,
				:excisable
			]
		end
	end

	validates :title, :plan, :address, :place,
		:model, :ofd, :contact,
		presence: true, allow_blank: false

	validates :address, format: { with: /[.]?[\d]{6}[.]?/, message: "должен содержать почтовый индекс" }

	validates :ofd, numericality: { only_integer: true, 
		greater_than_or_equal_to: 0,
		less_than_or_equal_to: CashRegister.human_ofds.size,
		message: 'выберите значение'}
	validates :ofd, numericality: { only_integer: true, greater_than: 0,
		message: 'ОФД обязан быть выбран в населенном пункте наслением более 10000 человек'},
		if: :big_city?
	def big_city?
		address.match('Саранск') or address.match('Зубова-Поляна') or
		address.match('Ковылкино') or address.match('Комсомольский') or 
		address.match('Рузаевка')
	rescue
		false
	end

	validates :plan, numericality: { only_integer: true, 
		greater_than_or_equal_to: 0,
		less_than_or_equal_to: CashRegister.human_plans.size,
		message: 'выберите значение'}

	validates :model, numericality: { only_integer: true, 
		greater_than_or_equal_to: 0,
		less_than_or_equal_to: CashRegister.human_models.size,
		message: 'выберите значение'}

	validates :ofd_interface, numericality: { only_integer: true, 
		greater_than_or_equal_to: 0,
		less_than_or_equal_to: CashRegister.human_ofd_interfaces.size,
		message: 'выберите значение'}, if: :ofd?
	def ofd?
		(1..CashRegister.human_ofds.size).include? ofd
	end

	validates :sno, numericality: { only_integer: true, 
		greater_than: 0,
		less_than_or_equal_to: 2**CashRegister.human_snos.size,
		message: 'должна быть выбрана хотя бы одна'}

	validates :automat_number, :reg_number, :serial_number,
		numericality: { only_integer: true,
		greater_than: 0}, allow_blank: true

	validates :lottery, :gamble, :bank_pay_agent, :pay_agent,
		:automat, :internet, :service, :bco, :excisable,
		inclusion: { in: [true, false] }

	validates :automat_number, presence: true, numericality: { only_integer: true, 
		greater_than: 0}, allow_blank: false, if: :automat?
	def automat?
		automat
	end

	validates :wifi_password, :wifi_ssid, presence: true, allow_blank: false, if: :wifi?
	validates :wifi_password, length: { minimum: 8 }, if: :wifi?
	def wifi?
		int1 = CashRegister.human_ofd_interfaces[ofd_interface] if ofd_interface >= 0
		int2 = CashRegister.human_pc_interfaces[pc_interface] if pc_interface >= 0
		return ((int1=='WIFI') or (int2=='WIFI'))
	rescue
		false
	end

	validates :gsm_operator, presence: true, allow_blank: false, if: :gsm?
	def gsm?
		int = CashRegister.human_ofd_interfaces[ofd_interface] if ofd_interface >= 0
		return (int=='SIM' && ofd > 0)
	rescue
		false
	end

	def human_plan
		CashRegister.human_plans[self.plan]
	rescue
		'Тариф не задан'
	end

	def human_model
		CashRegister.human_models[self.model]
	rescue
		'Модель не задана'
	end

	def human_ofd
		CashRegister.human_ofds[self.ofd]
	rescue
		'ОФД не задан'
	end

	def human_ofd_interface
		CashRegister.human_ofd_interfaces[self.ofd_interface]
	rescue
		'Интерфейс ОФД не задан'
	end

	def human_pc_interface
		CashRegister.human_pc_interfaces[self.pc_interface]
	rescue
		'Интерфейс ПК не задан'
	end

	def human_gsm_operator
		CashRegister.human_gsm_operators[self.gsm_operator]
	rescue
		'Оператор сотовой связи не задан'
	end

	def title
		tt = self.read_attribute :title
		return "Касса без названия #{serial_number}" if tt.blank?
		tt
	end

	def sno= sno_list
		result_sno = 0
		sno_list.each do |item|
			result_sno +=
				case item
				when '0' then 1
				when '1' then 2
				when '2' then 4
				when '3' then 8
				when '4' then 16
				when '5' then 32
				end 
		end
		super result_sno
	end

	def human_sno
		result = []
		return result unless self.sno
		h = CashRegister.human_snos
		(0..5).each do |i|
			result << h[i] if (self.sno >> i).odd?
		end
		result
	end

	CashRegister.bools.each do |boo|
		define_method("human_#{boo}") do
			if method(boo).call
				'✔'
			else
				'✗'
			end
		end
	end
end