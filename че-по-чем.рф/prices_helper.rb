require 'yaml'
module PricesHelper
	class PriceItem
		attr_accessor :service_description
		attr_accessor :service_name
		attr_accessor :service_short_name
		attr_accessor :price
		attr_accessor :id
	end
	class PriceList
		puts 'Считываю цены'
		@@up = YAML.load_file(Rails.root+'lib/assets/prices/up.yaml')
		@@prolongation = YAML.load_file(Rails.root+'lib/assets/prices/prolongation.yaml')
		@@select = YAML.load_file(Rails.root+'lib/assets/prices/select.yaml')
		@@turbo = YAML.load_file(Rails.root+'lib/assets/prices/turbo.yaml')
		@@constant = YAML.load_file(Rails.root+'lib/assets/prices/constant.yaml')
		@@vip = YAML.load_file(Rails.root+'lib/assets/prices/vip.yaml')
		@@url_share = YAML.load_file(Rails.root+'lib/assets/prices/url_share.yaml')

		@@up.id = 1
		@@prolongation.id = 2
		@@select.id = 3
		@@turbo.id = 4
		@@constant.id = 5
		@@vip.id = 6
		@@url_share.id = 7

		def initialize
			@up = @@up.clone
			@prolongation = @@prolongation.clone
			@select = @@select.clone
			@turbo = @@turbo.clone
			@constant = @@constant.clone
			@vip = @@vip.clone
			@url_share = @@url_share.clone
		end

		def each
			i = 1
			while PriceList[i] != nil
				yield PriceList[i]
				i += 1
			end
		end
		class << self
			def [](id)
				case id
					when 1 then @@up
					when 2 then @@prolongation
					when 3 then @@select
					when 4 then @@turbo
					when 5 then @@constant
					when 6 then @@vip
					when 7 then @@url_share
					else nil
				end
			end
			def up
				@@up
			end
			def prolongation
				@@prolongation
			end
			def select
				@@select
			end
			def turbo
				@@turbo
			end
			def constant
				@@constant
			end
			def vip
				@@vip
			end
			def url_share
				@@url_share
			end
		end
	end
end