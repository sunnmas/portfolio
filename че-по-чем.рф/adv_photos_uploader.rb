class AdvPhotosUploader < BasePhotoUploader
	include CarrierWave::Watermarker
	def initialize a, b
		@max_height = ENV['max_photo_height'].to_i
		@max_width  = ENV['max_photo_width'].to_i
		@min_height = ENV['min_photo_height'].to_i
		@min_width  = ENV['min_photo_width'].to_i
		@max_file_size = ENV['max_photo_size_mb'].to_i.megabytes

		super a, b
	end

	def crop
		if model.human_provider.in? [:avito, :avito_forced]
			val = 50
		elsif model.human_provider.in? [:irr, :irr_forced]
			val = 80
		elsif model.human_provider.in? [:cian, :cian_forced]
			val = 180
		else
			return
		end
		manipulate! do |img|
			img.crop "#{img.width}x#{img.height-val}+0+0"
			img
		end
	end

	def scale width, height
		if @img.height>height and
			@img.width<=width
			resize_to_fill @img.width, height
		elsif @img.width>width and
			@img.height<=height
			resize_to_fill width, @img.height
		elsif @img.width>width and
			@img.height>height
			resize_to_fill width, height	
		end
	end

	def compose_logo
		choise = rand 1..10
		corner = case choise
		when 1..4 then 'SouthEast'
		when 5..6 then 'SouthWest'
		when 7..8 then 'NorthEast'
		when 9..10 then 'NorthWest'
		end
		watermark 'app/assets/images/watermark.png', corner
	end

    process :size_overflow
    process :check_size
	process :auto_rotate
	process :crop
	process scale: [ENV['max_output_photo_width'].to_i, ENV['max_output_photo_height'].to_i]
	process :compose_logo
	process convert_to_webp: [{ quality: 85, method: 6 }]
	version :thumb do
		process :resize_to_fill => [ENV['thumb_width'].to_i, ENV['thumb_height'].to_i]
		process :convert_to_webp
	end

	def filename
		if original_filename
			@name ||= Digest::MD5.hexdigest(model.id.to_s)
			"#{@name}.#{file.extension}.webp"
		end
	end

	def store_dir
		return "test/pics/#{model.id}" if Rails.env.test?
		"pics/#{model.id}"
	end
end
