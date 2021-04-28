class IncotexItem < ApplicationRecord
    belongs_to :user

	class << self
		def human_tax_systems
			[
				'Умолч.',
				'Общая',
				'УСН6',
				'УСН15',
				'ЕНВД',
				'ЕСХН',
				'Патент'
			]
		end
		def human_tax_codes
			[
				'20%',
				'10%',
				'20/120%',
				'10/110%',
				'0%',
				'Без'
			]
		end

		def human_type_codes
			[
				'Товар',
				'Подакцизный товар',
				'Работа',
				'Услуга',
				'Ставка азартной игры',
				'Выигрыш азартной игры',
				'Лотерейный билет',
				'Выигрыш лотереи',
				'Предоставление РИД',
				'Платеж',
				'Агентское вознаграждение',
				'Составной предмет расчета',
				'Иной предмет расчета',
				'Имущественное право',
				'Внереализационный доход',
				'Страховые взносы',
				'Торговый сбор',
				'Курортный сбор',
				'Залог',
			]
		end

		def short_type_codes
			[
				'Т',
				'ПА',
				'Р',
				'У',
				'САЗ',
				'ВАЗ',
				'ЛБИ',
				'ВЛО',
				'РИД',
				'ПЖ',
				'АВЖ',
				'СПР',
				'ИПР',
				'ИМП',
				'ВРД',
				'СТВ',
				'ТСР',
				'КСР',
				'ЗЛГ',
			]
		end

		def permitted
			[
				:tax_system,
				:tax_code,
				:section,
				:marking,
				:undivided,
				:barcode,
				:price,
				:agent,
				:name,
				:code,
				:type_code
			]
		end
	end

	validates :tax_system, numericality: { only_integer: true, 
		greater_than: -2,
		less_than: IncotexItem.human_tax_systems.size-1,
		message: 'выберите значение'}

	validates :tax_code, numericality: { only_integer: true, 
		greater_than: 0,
		less_than: IncotexItem.human_tax_codes.size+1,
		message: 'выберите значение'}

	validates :section, numericality: { only_integer: true, 
		greater_than: -1,
		less_than_or_equal_to: 16,
		message: 'выберите значение'}

	validates :marking, :undivided, 
		inclusion: { in: [true, false] }

	validate :barcode_validator

	def barcode_validator
		return if barcode.blank?
		if barcode.length != 13
			errors.add(:barcode, 'должен быть длиной 13 символов')
		end
		if !barcode.scan(/\D/).empty?
			errors.add(:barcode, 'должен содержать только цифры')
		end

		sum  = barcode[11].to_i
		sum += barcode[9].to_i
		sum += barcode[7].to_i
		sum += barcode[5].to_i
		sum += barcode[3].to_i
		sum += barcode[1].to_i
		sum *= 3

		sum += barcode[10].to_i
		sum += barcode[8].to_i
		sum += barcode[6].to_i
		sum += barcode[4].to_i
		sum += barcode[2].to_i
		sum += barcode[0].to_i

		sum %= 10

		chk = 10 - sum
		if barcode[12].to_i != chk
			errors.add(:barcode, 'неверная контрольная сумма')
		end
	end

	validates :price, numericality: { only_integer: false, 
		greater_than_or_equal_to: 0}

	validates :agent, numericality: { only_integer: true, 
		greater_than_or_equal_to: 0,  less_then: 100}

	validates :name, length: { minimum: 3, maximum: 56}, allow_blank: false

	validates :code, numericality: { only_integer: true, 
		greater_than_or_equal_to: 1,  less_then_or_equal_to: 10000}

	validates :type_code, numericality: { only_integer: true, 
		greater_than_or_equal_to: 1,  less_then_or_equal_to: 19,
		message: 'выберите значение'}


	def human_tax_system
		IncotexItem.human_tax_systems[tax_system+1]
	end

	def human_tax_code
		IncotexItem.human_tax_codes[tax_code-1]
	end

	def human_type_code
		IncotexItem.human_type_codes[type_code-1]
	end

	def short_type_code
		IncotexItem.short_type_codes[type_code-1]
	end

	def clean_barcode
		self.barcode.gsub '.0', ''
	rescue => e
		''
	end
	
	def to_json
		"{
		\"code\": #{code},
		\"barcode\": #{(barcode.blank?) ? '0' : clean_barcode},
		\"name\": \"#{name}\",
		\"price\": \"#{(price*100).to_i.to_s}\",
		\"marked\": #{marking},
		\"section\": #{section},
		\"typeCode\": #{type_code},
		\"undivided\": #{undivided},
		\"taxSystem\": #{tax_system},
		\"taxCode\": #{tax_code},
		\"agentNum\": 0
		}"
	end

	after_initialize :default_values, if: 'new_record?'
	def default_values
		self.price = 0
		self.barcode = ''
		self.marking = false
		self.section = 1
		self.type_code = 1
		self.undivided = true
		self.tax_system = -1
		self.tax_code = 6
		self.agent = 0
	end

end