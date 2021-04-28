require 'rails_helper'
require 'chunky_png'
describe "Фото" do
	it "1. Должно создаваться
		2. Файл изображения должен существовать
		3. Файл иконки должен существовать" do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		File.open(Rails.root+'spec/photos/bike1.jpg') do |f|
			photo.pic = f
		end
		photo.save
		expect(photo.valid?).to be true
		file = photo.pic.current_path
		expect(File.exist? file).to be true
		file = photo.pic.thumb.current_path
		expect(File.exist? file).to be true
		photo.destroy
	end
	it 'не должно создаваться без ссылки на объявление' do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.active_adv_id = adv.id
		File.open(Rails.root+'spec/photos/bike1.jpg') do |f|
			photo.pic = f
		end
		expect{photo.save}.to raise_exception(ActiveRecord::StatementInvalid)
	end
	it 'не должно создаваться без ссылки на активное объявление' do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		File.open(Rails.root+'spec/photos/bike1.jpg') do |f|
			photo.pic = f
		end
		expect{photo.save}.to raise_exception(ActiveRecord::StatementInvalid)
	end
	it 'описание не должно содержать ссылок' do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		photo.description = 'описание содержит ссылку: http://arjanvandergaag.nl/blog'
		File.open(Rails.root+'spec/photos/bike1.jpg') do |f|
			photo.pic = f
		end
		photo.save
		expect(photo.valid?).to be false
		expect(photo.errors[:description][0]).to match('не должно содержать ссылок и IP адресов')
	end
	it 'описание не должно содержать номеров телефонов' do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		photo.description = 'описание содержит ссылку: 9520765032'
		File.open(Rails.root+'spec/photos/bike1.jpg') do |f|
			photo.pic = f
		end
		photo.save
		expect(photo.valid?).to be false
		expect(photo.errors[:description][0]).to match('не должно содержать номеров телефонов')
	end 
	it 'описание не должно содержать матерных выражений' do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		photo.description = 'описание мат: охуеть'
		File.open(Rails.root+'spec/photos/bike1.jpg') do |f|
			photo.pic = f
		end
		photo.save
		expect(photo.valid?).to be false
		expect(photo.errors[:description][0]).to match('не должно содержать матерных выражений')
	end 
	it "описание не должно превышать #{ENV['max_photo_description_chars']} символов" do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		photo.description = 'просто длинное описание, содержащее 161 символл л фажфа жа жфаофожфа жфа жфыва жфважж жфа о ывжаоф фыважы ж жфы аж оо фжыа ожфа о ожф о жфоа жфа о ожфа ожжфыавлл'
		File.open(Rails.root+'spec/photos/bike1.jpg') do |f|
			photo.pic = f
		end
		photo.save
		expect(photo.valid?).to be false
		expect(photo.errors[:description]).not_to be_nil
	end
	it "изображение по ширине не должно превышать #{ENV['max_photo_width']} пикселов" do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		expect{
			File.open(Rails.root+'spec/photos/6017.png') do |f|
				photo.pic = f
			end
		}.to raise_error(/превышена максимальная ширина/)
	end
	it "изображение по высоте не должно превышать #{ENV['max_photo_height']} пикселов" do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		expect{
			File.open(Rails.root+'spec/photos/4001.png') do |f|
				photo.pic = f
			end
		}.to raise_error(/превышена максимальная высота/)
	end
	it "изображение по ширине не должно быть меньше #{ENV['min_photo_width']} пикселов" do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		expect{
			File.open(Rails.root+'spec/photos/319.png') do |f|
				photo.pic = f
			end
		}.to raise_error(/Минимальная ширина/)
	end
	it "изображение по высоте не должно быть меньше #{ENV['min_photo_height']} пикселов" do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		expect{
			File.open(Rails.root+'spec/photos/239.png') do |f|
				photo.pic = f
			end
		}.to raise_error(/Минимальная высота/)
	end
	it "изображение не должно превышать #{ENV['max_photo_size_mb']} Мб" do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		expect{
			File.open(Rails.root+'spec/photos/bigfile.jpg') do |f|
				photo.pic = f
			end
		}.to raise_error(/Превышен максимальный размер файла/)
	end
	it "изображение не должно иметь формат, отличный от: #{ENV['photos_ext']}" do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		expect{
			File.open(Rails.root+'spec/photos/car.pdf') do |f|
				photo.pic = f
			end
		}.to raise_error(/Ошибка при загрузке содержимого файла изображения./)
	end
	it "изображение должно иметь верное внутреннее содержание" do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		expect{
			File.open(Rails.root+'spec/photos/txtas.jpg') do |f|
				photo.pic = f
			end
		}.to raise_error(/Ошибка при загрузке содержимого файла изображения/)
	end
	it "PNG должно быть развернуто на 90 против часовой стрелки, если exif = 8" do
		# Точка в левом верхнем левой углу должна быть черной
		original_path = Rails.root+'spec/photos/orient8.png'
		original_image = ChunkyPNG::Image.from_file original_path
		w = original_image.dimension.width-1
		# читаем правую верхнюю точку, должна быть черной
		r = ChunkyPNG::Color.r(original_image[w,0])
		expect(r).to eq(0)
		# читаем левую верхнюю точку, должна быть белой
		r = ChunkyPNG::Color.r(original_image[0,0])
		expect(r).to eq(255)

		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		File.open(original_path) do |f|
			photo.pic = f
		end
		photo.save
		expect(photo.valid?).to be true
		file = photo.pic.current_path
		image = ChunkyPNG::Image.from_file file

		#Скопируем повернутый файл, чтобы посмотреть визуально
		File.copy(file, Rails.root+'spec/photos/orient8_rotated_watermarked.png')

		# Левая верхняя должна быть черной
		r = ChunkyPNG::Color.r image[0,0]
		expect(r).to eq(0)

		# Правая верхняя белой
		w = image.dimension.width-1
		r = ChunkyPNG::Color.r image[w,0]
		expect(r).to eq(255)
	end
	it 'фото 1365x2048 должно быть обрезано до 1080x1920' do
		original_path = Rails.root+'spec/photos/big_format_image.jpg'
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		File.open(original_path) do |f|
			photo.pic = f
		end
		photo.save
		expect(photo.valid?).to be true
		file = photo.pic.current_path
		
		result_image = MiniMagick::Image.open file
		expect(result_image.width).to eq(ENV['max_output_photo_width'].to_i)
		expect(result_image.height).to eq(ENV['max_output_photo_height'].to_i)
	end
	it 'фото размера меньше 1024x768 должно быть не обрезано и ужато по весу' do
		original_path = Rails.root+'spec/photos/1024_768.jpg'
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		File.open(original_path) do |f|
			photo.pic = f
		end
		photo.save
		expect(photo.valid?).to be true
		file = photo.pic.current_path
		
		result_image = MiniMagick::Image.open file
		expect(result_image.width).to eq(1024)
		expect(result_image.height).to eq(768)
		expect(File.size(original_path)).to be > File.size(file)
	end
	it 'фото с палитрой cmyk должно перевариваться' do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		File.open(Rails.root+'spec/photos/cmyk.jpg') do |f|
			photo.pic = f
		end
		photo.save
		expect(photo.valid?).to be true
	end
	it '1. должно удаляться вместе с объявлением.
		2. Файлы изображений так же должны быть удалены.
		3. Директория тоже' do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		File.open(Rails.root+'spec/photos/bike1.jpg') do |f|
			photo.pic = f
		end
		photo.save
		expect(photo.valid?).to be true
		file = photo.pic.current_path
		expect(File.exist? file).to be true
		adv.destroy
		photo = Photo.where(id: photo.id).first
		expect(photo).to be_nil
		expect(File.exist? file).to be false
		expect(Dir.exist? File.dirname(file)).to be false
	end

	it '1. должно удаляться вместе напрямую.
		2. Файлы изображений так же должны быть удалены.
		3. Директория тоже' do
		adv = FactoryBot.create :adv
		photo = Photo.new
		photo.adv_id = adv.id
		photo.active_adv_id = adv.id
		File.open(Rails.root+'spec/photos/bike1.jpg') do |f|
			photo.pic = f
		end
		photo.save
		expect(photo.valid?).to be true
		file = photo.pic.current_path
		expect(File.exist? file).to be true
		photo.destroy
		photo = Photo.where(id: photo.id).first
		expect(photo).to be_nil
		expect(File.exist? file).to be false
		expect(Dir.exist? File.dirname(file)).to be false
	end
end