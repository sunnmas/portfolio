include ApplicationHelper
class ActiveAdv < ActiveRecord::Base
	include GeoAttrs
	include BaseAdv
	searchable :auto_index => false, :auto_remove => false do
		integer :id

		text :title
		integer :price
		text :description
		text :photos do
			photos.map { |photo| photo.description }
		end
		integer :category
		boolean :trade
		boolean :bulk
		boolean :warranty
		boolean :immidiately
		boolean :cash
		boolean :order

		time :last_up_at
		time :vip_at
		time :turbo_at

		integer :region
		integer :city
		integer :district

		latlon(:location) { Sunspot::Util::Coordinates.new(self.lattitude, self.longitude) }

		for i in 1...Category.count
			model = Category.model i-1
			symbol = Category.symbol(i-1).to_s
	
			model.IntegerAttrs.each do |x|
				join(x[0], :prefix => symbol, :target => model, :type => :integer, 
					:join => { :from => :active_adv_id, :to => :id })
			end
	
			model.FloatAttrs.each do |x|
				join(x[0], :prefix => symbol, :target => model, :type => :float, 
					:join => { :from => :active_adv_id, :to => :id })
			end
		
			model.BoolAttrs.each do |x|
				join(x[0], :prefix => symbol, :target => model, :type => :boolean, 
					:join => { :from => :active_adv_id, :to => :id })
			end
	
			model.EnumAttrs.each do |x|
				join(x[0], :prefix => symbol, :target => model, :type => :integer, 
					:join => { :from => :active_adv_id, :to => :id })
			end
	
			model.TreeAttrs.each do |x|
				for j in 0..x[1].count do
					join("#{x[0]}#{j}".to_sym, :prefix => symbol, :target => model, :type => :integer, 
						:join => { :from => :active_adv_id, :to => :id })
				end
			end

			model.DateAttrs.each do |x|
				join(x[0], :prefix => symbol, :target => model, :type => :time, 
					:join => { :from => :active_adv_id, :to => :id })
			end
		end
	end

	def self.vips
		not_null = 'NOT NULL'
		not_null = 'IS NOT NULL' if !Rails.env.development? and !Rails.env.test?

		where('vip_at '+not_null)
	end

	def self.turbos
		not_null = 'NOT NULL'
		not_null = 'IS NOT NULL' if !Rails.env.development? and !Rails.env.test?

		where('turbo_at '+not_null)
	end

	def self.selected
		not_null = 'NOT NULL'
		not_null = 'IS NOT NULL' if !Rails.env.development? and !Rails.env.test?

		where('selected_at '+not_null)
	end

	def with_photo?
		self.photos.count > 0
	end
end