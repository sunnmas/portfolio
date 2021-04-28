class SitemapWorker
	include Sidekiq::Worker
	def perform
		n = 49900
		i = count = 0
		index = XmlSitemap::Index.new secure: true
		while true do
			cnt = 0
			map = XmlSitemap::Map.new 'че-по-чем.рф', secure: true, group: 'sitmap4e4o/sitemap'
			ActiveAdv.select(:id, :secure, :updated_at).limit(n).offset(i*n).each do |a|
				map.add "объявление/#{a.secure}", {:updated => a.updated_at.to_time}
				cnt += 1
			end
			break if cnt == 0 
			count += cnt
			# Add a map to the index
			map.render_to "#{Rails.root}/public/sitmap4e4o/sitemap-#{i}.xml", :gzip => false
			index.add map
			i += 1
		end

		map = XmlSitemap::Map.new 'че-по-чем.рф', secure: true, group: 'sitmap4e4o/sitemap'
		Category.groups_routes.each do |route|
			map.add route, {:updated => Time.now}
			GeoObjects.regions.each do |region|
				map.add "#{route}/#{region.route}", {:updated => Time.now}
				region.cities.each do |city|
					if city.big? or city.capital?
						map.add "#{route}/#{city.route}", {:updated => Time.now}
					end
				end
			end
		end
		Category.routes.each do |route|
			map.add route, {:updated => Time.now}
			GeoObjects.regions.each do |region|
				map.add "#{route}/#{region.route}", {:updated => Time.now}
				region.cities.each do |city|
					if city.big? or city.capital?
						map.add "#{route}/#{city.route}", {:updated => Time.now}
					end
				end
			end
		end

		GeoObjects.regions.each do |region|
			map.add "объявления/#{region.route}", {:updated => Time.now}
			region.cities.each do |city|
				if city.big? or city.capital?
					map.add "объявления/#{city.route}", {:updated => Time.now}
				end
			end
		end

		Flat.base_slice_routes.each do |route|
			map.add route, {:updated => Time.now}
			GeoObjects.regions.each do |region|
				map.add "#{route}/#{region.route}", {:updated => Time.now}
				region.cities.each do |city|
					if city.big? or city.capital?
						map.add "#{route}/#{city.route}", {:updated => Time.now}
					end
				end
			end
		end
		map.render_to "#{Rails.root}/public/sitmap4e4o/sitemap-#{i}.xml", :gzip => false
		index.add map


		# Render XML to the output file
		index.render_to "#{Rails.root}/public/sitmap4e4o/index.xml", :gzip => false
	end
end
