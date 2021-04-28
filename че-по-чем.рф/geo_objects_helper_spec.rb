require 'rails_helper'

describe GeoObjects do
	it "тестируем поиск региона" do
		city = GeoObjects.city nil, nil
		expect(city).to eq nil

		region = GeoObjects.find_region 'Москва'
		expect(region).to eq nil

		region = GeoObjects.find_region 'Московская область'
		expect(region.clean_name).to eq 'Москва и Московская область'

		region = GeoObjects.find_region 'Севастополь'
		expect(region).to eq nil

		region = GeoObjects.find_region 'Республика Крым'
		expect(region.clean_name).to eq 'Севастополь и Крым'

		region = GeoObjects.find_region 'Севастополь и Крым'
		expect(region.clean_name).to eq 'Севастополь и Крым'

		region = GeoObjects.find_region 'Крым'
		expect(region.clean_name).to eq 'Севастополь и Крым'

		region = GeoObjects.find_region 'респ. Крым'
		expect(region.clean_name).to eq 'Севастополь и Крым'

		region = GeoObjects.find_region 'Ленинград'
		expect(region).to eq nil

		region = GeoObjects.find_region 'Санкт-Петербург'
		expect(region).to eq nil

		region = GeoObjects.find_region 'республика Адыгея'
		expect(region.clean_name).to eq 'Адыгея'

		region = GeoObjects.find_region 'респ. Адыгея'
		expect(region.clean_name).to eq 'Адыгея'

		region = GeoObjects.find_region 'Алтайский край'
		expect(region.clean_name).to eq 'Алтайский край'

		region = GeoObjects.find_region 'Волгоградская область'
		expect(region.clean_name).to eq 'Волгоградская область'

		region = GeoObjects.find_region 'Ленинградская область'
		expect(region.clean_name).to eq 'Санкт-Петербург и Ленинградская область'

		region = GeoObjects.find_region 'Калужская обл.'
		expect(region.clean_name).to eq 'Калужская область'

		region = GeoObjects.find_region 'Краснодарский кр.'
		expect(region.clean_name).to eq 'Краснодарский край'

		region = GeoObjects.find_region 'Ханты-Мансийский автономный округ'
		expect(region.clean_name).to eq 'Ханты-Мансийский АО'

		region = GeoObjects.find_region 'Ханты-Мансийский а.о.'
		expect(region.clean_name).to eq 'Ханты-Мансийский АО'

		region = GeoObjects.find_region 'Ханты-Мансийский А.О.'
		expect(region.clean_name).to eq 'Ханты-Мансийский АО'

		region = GeoObjects.find_region 'Ханты-Мансийский авт.окр.'
		expect(region.clean_name).to eq 'Ханты-Мансийский АО'

		region = GeoObjects.find_region 'Ханты-Мансийский авт. окр.'
		expect(region.clean_name).to eq 'Ханты-Мансийский АО'

		region = GeoObjects.find_region 'Ханты-Мансийский авт. округ'
		expect(region.clean_name).to eq 'Ханты-Мансийский АО'

		region = GeoObjects.find_region 'ханты-мансийский ао'
		expect(region.clean_name).to eq 'Ханты-Мансийский АО'
	end
	it "тестируем разбор адреса" do
		address = GeoObjects.find_address 'Москва'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Москва'

		address = GeoObjects.find_address 'г. Санкт-Петербург'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Санкт-Петербург'

		address = GeoObjects.find_address 'Ленинград'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Санкт-Петербург'

		address = GeoObjects.find_address 'г. Ленинград'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Санкт-Петербург'

		address = GeoObjects.find_address 'Севастополь и Крым, Симферополь'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Симферополь'

		address = GeoObjects.find_address 'Республика Крым, Симферополь'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Симферополь'

		address = GeoObjects.find_address 'Республика Крым, г. Симферополь'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Симферополь'

		address = GeoObjects.find_address 'Челябинск, Советский р-н'
		expect(address[2]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Челябинск'
		expect(address[3]).to eq 'Советский р-н'

		address = GeoObjects.find_address 'Смоленск, Ленинский р-н'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Смоленск'
		expect(district.clean_name).to eq 'Ленинский'

		address = GeoObjects.find_address 'Ростов-на-Дону, Кировский район'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Ростов-на-Дону'
		expect(district.clean_name).to eq 'Кировский'

		address = GeoObjects.find_address 'Барнаул'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Барнаул'

		address = GeoObjects.find_address 'Волгодонск'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Волгодонск'

		address = GeoObjects.find_address 'Уфа'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Уфа'

		address = GeoObjects.find_address 'Волжский'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Волжский'

		address = GeoObjects.find_address 'Республика Крым, г. Симферополь, ул. Ленина'
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Симферополь'
		expect(address[3]).to eq 'ул. Ленина'

		address = GeoObjects.find_address 'Крым, Ялта, ул. Ленина'
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Ялта'
		expect(address[3]).to eq 'ул. Ленина'

		address = GeoObjects.find_address 'Ялта, улица Пржвальского, д. 35'
		city2 = GeoObjects.city address[0], address[1]
		expect(city2.id).to eq city.id
		expect(address[3]).to eq 'ул. Пржвальского, д. 35'

		address = GeoObjects.find_address 'Москва, м. Театральная'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Москва'
		expect(district.clean_name).to eq 'м. Театральная'

		address = GeoObjects.find_address 'Москва, м. юго-западная'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Москва'
		expect(district.clean_name).to eq 'м. Юго-Западная'

		address = GeoObjects.find_address 'Самара, м. Советская'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Самара'
		expect(district.clean_name).to eq 'м. Советская'

		address = GeoObjects.find_address 'Нижний Тагил, Ленинский р-н'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Нижний Тагил'
		expect(district.clean_name).to eq 'Ленинский'

		address = GeoObjects.find_address 'Нижний Ломов, проспект 60 лет Октября'
		expect(address[2]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Нижний Ломов'
		expect(address[3]).to eq 'пр-т 60 лет Октября'

		address = GeoObjects.find_address 'Нижний Новгород, район Сормовский, улица Луговая, д. 131, 2 этаж'
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Нижний Новгород'
		expect(district.clean_name).to eq 'Сормовский'
		expect(address[3]).to eq 'ул. Луговая, д. 131, 2 этаж'

		address = GeoObjects.find_address 'Череповец, Индустриальный р-н'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Череповец'
		expect(district.clean_name).to eq 'Индустриальный'

		address = GeoObjects.find_address 'Санкт-Петербург, м. Гражданский проспект'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Санкт-Петербург'
		expect(district.clean_name).to eq 'м. Гражданский проспект'

		address = GeoObjects.find_address 'Санкт-Петербург, м. Звездная'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Санкт-Петербург'
		expect(district.clean_name).to eq 'м. Звездная'

		address = GeoObjects.find_address 'Москва, м. Марьина Роща'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Москва'
		expect(district.clean_name).to eq 'м. Марьина Роща'

		address = GeoObjects.find_address 'Москва, метро Орехово'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Москва'
		expect(district.clean_name).to eq 'м. Орехово'

		address = GeoObjects.find_address 'метро , Москва'
		expect(address[2]).to eq nil
		expect(address[3]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Москва'

		address = GeoObjects.find_address 'метро , Москва, Комсомольская'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Москва'
		expect(district.clean_name).to eq 'м. Комсомольская'

		address = GeoObjects.find_address 'Москва, Беляево'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Москва'
		expect(district.clean_name).to eq 'м. Беляево'

		address = GeoObjects.find_address 'Москва, пражская'
		expect(address[3]).to eq nil
		district = GeoObjects.district address[0], address[1], address[2]
		expect(district.city.clean_name).to eq 'Москва'
		expect(district.clean_name).to eq 'м. Пражская'

		address = GeoObjects.find_address 'Фестивальный микрорайон, Краснодар, улица Тургенева, 144'
		expect(address[2]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Краснодар'
		expect(address[3]).to eq 'Фестивальный микрорайон, ул. Тургенева, 144'

		address = GeoObjects.find_address 'Фестивальный микрорайон, Краснодар, улица Тургенева, 144, Краснодарский край'
		expect(address[2]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Краснодар'
		expect(address[3]).to eq 'Фестивальный микрорайон, ул. Тургенева, 144'

		address = GeoObjects.find_address 'Пермь, улица Куйбышева, 9'
		expect(address[2]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Пермь'
		expect(address[3]).to eq 'ул. Куйбышева, 9'

		address = GeoObjects.find_address 'Курская область, Курский район, Ушаковский пруд'
		expect(address[1]).to eq nil
		expect(address[2]).to eq nil
		region = GeoObjects.region address[0]
		expect(region.clean_name).to eq 'Курская область'
		expect(address[3]).to eq 'Курский район, Ушаковский пруд'

		address = GeoObjects.find_address 'Омск, Кировский округ'
		expect(address[2]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.clean_name).to eq 'Омск'
		expect(address[3]).to eq 'Кировский округ'

		address = GeoObjects.find_address 'респ. Мордовия, поселок Ичалки, улица Красная Горка, д.4'
		expect(address[2]).to eq nil
		city = GeoObjects.city address[0], address[1]
		expect(city.region.clean_name).to eq 'Мордовия'
		expect(city.clean_name).to eq 'Ичалки'
		expect(address[3]).to eq 'ул. Красная Горка, д.4'

		address = GeoObjects.find_address 'Химки, м. Хорвино'
		expect(address[2]).to eq nil
		city = GeoObjects.city address[0], address[1]
		district = GeoObjects.district address[0], address[1], address[2]
		expect(city.region.clean_name).to eq 'Москва и Московская область'
		expect(city.clean_name).to eq 'Химки'
		expect(district).to eq nil
		expect(address[3]).to eq 'м. Хорвино'

		address = GeoObjects.find_address 'Мордовия респ., Саранск, Веселовского, 43'
		expect(address[2]).to eq nil
		city = GeoObjects.city address[0], address[1]
		district = GeoObjects.district address[0], address[1], address[2]
		expect(city.region.clean_name).to eq 'Мордовия'
		expect(city.clean_name).to eq 'Саранск'
		expect(district).to eq nil
		expect(address[3]).to eq 'Веселовского, 43'


		address = GeoObjects.find_address 'Татарстан респ., Казань, р-н Советский, мкр. Азино-1, ул. Рашида Вагапова, 23/18'
		city = GeoObjects.city address[0], address[1]
		district = GeoObjects.district address[0], address[1], address[2]
		expect(city.region.clean_name).to eq 'Татарстан'
		expect(city.clean_name).to eq 'Казань'
		expect(district.clean_name).to eq 'Азино-1'
		expect(address[3]).to eq 'р-н Советский, ул. Рашида Вагапова, 23/18'

		address = GeoObjects.find_address 'Алтайский край, Барнаул, р-н Индустриальный, мкр. Октябрьский, Власиха село, ул. Беловежская'
		city = GeoObjects.city address[0], address[1]
		district = GeoObjects.district address[0], address[1], address[2]
		expect(city.region.clean_name).to eq 'Алтайский край'
		expect(city.clean_name).to eq 'Барнаул'
		expect(district.clean_name).to eq 'Индустриальный'
		expect(address[3]).to eq 'мкр. Октябрьский, Власиха село, ул. Беловежская'

		address = GeoObjects.find_address 'Ярославская обл., Ярославль, р-н Фрунзенский, мкр. Ямская Слобода, Московский просп., 35'
		city = GeoObjects.city address[0], address[1]
		district = GeoObjects.district address[0], address[1], address[2]
		expect(city.region.clean_name).to eq 'Ярославская область'
		expect(city.clean_name).to eq 'Ярославль'
		expect(district.clean_name).to eq 'Ямская Слобода'
		expect(address[3]).to eq 'р-н Фрунзенский, Московский просп., 35'

		address = GeoObjects.find_address 'Новосибирская область, Новосибирск, р-н Калининский, мкр. Бабушкина, Университетская набережная ул., 32'
		city = GeoObjects.city address[0], address[1]
		district = GeoObjects.district address[0], address[1], address[2]
		expect(city.region.clean_name).to eq 'Новосибирская область'
		expect(city.clean_name).to eq 'Новосибирск'
		expect(district.clean_name).to eq 'Калининский'
		expect(address[3]).to eq 'мкр. Бабушкина, Университетская набережная ул., 32'


		address = GeoObjects.find_address 'Россия, Калининградская область, Васильково, Гурьевский городской округ, Шатурская ул., 1Г'
		city = GeoObjects.city address[0], address[1]
		expect(city.region.clean_name).to eq 'Калининградская область'
		expect(city.clean_name).to eq 'Васильково'
		expect(address[3]).to eq 'Гурьевский городской округ, Шатурская ул., 1Г'


		address = GeoObjects.find_address 'Орёл, ул. Ленина, 19'
		city = GeoObjects.city address[0], address[1]
		expect(city.region.clean_name).to eq 'Орловская область'
		expect(city.clean_name).to eq 'Орел'
		expect(address[3]).to eq 'ул. Ленина, 19'

		address = GeoObjects.find_address 'Марий Эл респ., Йошкар-Ола г., Йывана-Кырлы ул., д.5'
		city = GeoObjects.city address[0], address[1]
		expect(city.region.clean_name).to eq 'Марий Эл'
		expect(city.clean_name).to eq 'Йошкар-Ола'
		expect(address[3]).to eq 'Йывана-Кырлы ул., д.5'

		address = GeoObjects.find_address 'Москва, метро пр-т Вернадского'
		city = GeoObjects.city address[0], address[1]
		district = GeoObjects.district address[0], address[1], address[2]
		expect(city.region.clean_name).to eq 'Москва и Московская область'
		expect(city.clean_name).to eq 'Москва'
		expect(district.clean_name).to eq 'м. Проспект Вернадского'
		expect(address[3]).to eq nil

		
		address = GeoObjects.find_address 'Санкт-Петербург,, м. Девяткино'
		city = GeoObjects.city address[0], address[1]
		district = GeoObjects.district address[0], address[1], address[2]
		expect(city.region.clean_name).to eq 'Санкт-Петербург и Ленинградская область'
		expect(city.clean_name).to eq 'Санкт-Петербург'
		expect(district.clean_name).to eq 'м. Девяткино'
		expect(address[3]).to eq nil
	end
	it "тестируем склонение в родительном падеже" do
		expect(GeoObjects.find_region('Смоленская область').genitive).to eq 'Смоленской области'
		expect(GeoObjects.find_region('Калининградская область').genitive).to eq 'Калининградской области'
		expect(GeoObjects.find_region('Краснодарский край').genitive).to eq 'Краснодарского края'
		expect(GeoObjects.find_region('Марий Эл').genitive).to eq 'Марий Эл'
		expect(GeoObjects.find_region('Москва и Московская область').genitive).to eq 'Москвы и Московской области'
		expect(GeoObjects.find_region('Еврейская АО').genitive).to eq 'Еврейской АО'
		expect(GeoObjects.find_region('Ненецкий АО').genitive).to eq 'Ненецкого АО'
		expect(GeoObjects.find_region('Татарстан').genitive).to eq 'Татарстана'
		expect(GeoObjects.find_region('Мордовия').genitive).to eq 'Мордовии'
		expect(GeoObjects.find_region('Чувашия').genitive).to eq 'Чувашии'
		expect(GeoObjects.find_region('Карачаево-Черкесия').genitive).to eq 'Карачаево-Черкесии'
		expect(GeoObjects.find_region('Республика Алтай').genitive).to eq 'Республики Алтай'
		expect(GeoObjects.find_region('Алтайский край').genitive).to eq 'Алтайского края'
		expect(GeoObjects.find_region('Северная Осетия').genitive).to eq 'Северной Осетии'
		expect(GeoObjects.find_region('Чеченская республика').genitive).to eq 'Чеченской республики'

		expect(GeoObjects.find_city('Казань').genitive).to eq 'Казани'
		expect(GeoObjects.find_city('Набережные Челны').genitive).to eq 'Набережных Челнов'
		expect(GeoObjects.find_city('Ростов-на-Дону').genitive).to eq 'Ростова-на-Дону'
		expect(GeoObjects.find_city('Санкт-Петербург').genitive).to eq 'Санкт-Петербурга'
		expect(GeoObjects.find_city('Москва').genitive).to eq 'Москвы'
		expect(GeoObjects.find_city('Нижний Тагил').genitive).to eq 'Нижнего Тагила'
		expect(GeoObjects.find_city('Нижний Новгород').genitive).to eq 'Нижнего Новгорода'
		expect(GeoObjects.find_city('Великий Новгород').genitive).to eq 'Великого Новгорода'
		expect(GeoObjects.find_city('Калининград').genitive).to eq 'Калининграда'
		expect(GeoObjects.find_city('Екатеринбург').genitive).to eq 'Екатеринбурга'
		expect(GeoObjects.find_city('Балашиха').genitive).to eq 'Балашихи'
		expect(GeoObjects.find_city('Биробиджан').genitive).to eq 'Биробиджана'
		expect(GeoObjects.find_city('Орел').genitive).to eq 'Орла'
		expect(GeoObjects.find_city('Йошкар-Ола').genitive).to eq 'Йошкар-Олы'
		expect(GeoObjects.find_city('Тверь').genitive).to eq 'Твери'
		expect(GeoObjects.find_city('Тюмень').genitive).to eq 'Тюмени'
		expect(GeoObjects.find_city('Рязань').genitive).to eq 'Рязани'
		expect(GeoObjects.find_city('Нарьян-Мар').genitive).to eq 'Нарьян-Мара'
		expect(GeoObjects.find_city('Чебоксары').genitive).to eq 'Чебоксар'
	end

	it "тестируем склонение в предложном падеже" do
		expect(GeoObjects.find_region('Смоленская область').prepositional).to eq 'Смоленской области'
		expect(GeoObjects.find_region('Калининградская область').prepositional).to eq 'Калининградской области'
		expect(GeoObjects.find_region('Краснодарский край').prepositional).to eq 'Краснодарском крае'
		expect(GeoObjects.find_region('Марий Эл').prepositional).to eq 'Марий Эл'
		expect(GeoObjects.find_region('Москва и Московская область').prepositional).to eq 'Москве и Московской области'
		expect(GeoObjects.find_region('Еврейская АО').prepositional).to eq 'Еврейской АО'
		expect(GeoObjects.find_region('Ненецкий АО').prepositional).to eq 'Ненецком АО'
		expect(GeoObjects.find_region('Татарстан').prepositional).to eq 'Татарстане'
		expect(GeoObjects.find_region('Мордовия').prepositional).to eq 'Мордовии'
		expect(GeoObjects.find_region('Чувашия').prepositional).to eq 'Чувашии'
		expect(GeoObjects.find_region('Карачаево-Черкесия').prepositional).to eq 'Карачаево-Черкесии'
		expect(GeoObjects.find_region('Республика Алтай').prepositional).to eq 'Республике Алтай'
		expect(GeoObjects.find_region('Алтайский край').prepositional).to eq 'Алтайском крае'
		expect(GeoObjects.find_region('Северная Осетия').prepositional).to eq 'Северной Осетии'
		expect(GeoObjects.find_region('Чеченская республика').prepositional).to eq 'Чеченской республике'

		
		expect(GeoObjects.find_city('Казань').prepositional).to eq 'Казани'
		expect(GeoObjects.find_city('Набережные Челны').prepositional).to eq 'Набережных Челнах'
		expect(GeoObjects.find_city('Ростов-на-Дону').prepositional).to eq 'Ростове-на-Дону'
		expect(GeoObjects.find_city('Санкт-Петербург').prepositional).to eq 'Санкт-Петербурге'
		expect(GeoObjects.find_city('Москва').prepositional).to eq 'Москве'
		expect(GeoObjects.find_city('Нижний Тагил').prepositional).to eq 'Нижнем Тагиле'
		expect(GeoObjects.find_city('Нижний Новгород').prepositional).to eq 'Нижнем Новгороде'
		expect(GeoObjects.find_city('Великий Новгород').prepositional).to eq 'Великом Новгороде'
		expect(GeoObjects.find_city('Калининград').prepositional).to eq 'Калининграде'
		expect(GeoObjects.find_city('Екатеринбург').prepositional).to eq 'Екатеринбурге'
		expect(GeoObjects.find_city('Балашиха').prepositional).to eq 'Балашихе'
		expect(GeoObjects.find_city('Биробиджан').prepositional).to eq 'Биробиджане'
		expect(GeoObjects.find_city('Орел').prepositional).to eq 'Орле'
		expect(GeoObjects.find_city('Йошкар-Ола').prepositional).to eq 'Йошкар-Оле'
		expect(GeoObjects.find_city('Тверь').prepositional).to eq 'Твери'
		expect(GeoObjects.find_city('Тюмень').prepositional).to eq 'Тюмени'
		expect(GeoObjects.find_city('Рязань').prepositional).to eq 'Рязани'
		expect(GeoObjects.find_city('Нарьян-Мар').prepositional).to eq 'Нарьян-Маре'
		expect(GeoObjects.find_city('Чебоксары').prepositional).to eq 'Чебоксарах'
    end
end
