require 'digest'
require 'rails_helper'
describe Cabinet::GeoController do
	render_views
	controller_methods = [	{name: :create, method: 'POST', params: {}},
							{name: :update, method: 'POST', params: {}},
							{name: :remove, method: 'POST', params: {}},
							{name: :show, method: 'GET', params: {}}]
	error_not_authorized controller_methods

	context 'Подтвержденный авторизованный пользователь' do
		describe 'create' do
			it 'местоположение должно создаваться, должен возвращать id местоположения' do
				user = FactoryBot.create :user
				login_user user
				request.env['HTTP_ACCEPT'] = 'application/json'
				params = {'geo[geoname]': 'testGeoName',
							'geo[region]': 0, 'geo[city]': 0, 'geo[district]': 2,
							'geo[lattitude]': 55.9999, 'geo[longitude]': 45.0001,
							'geo[pan_lat]': 55.9989, 'geo[pan_lon]': 45.0014,
							'geo[bearing]': 14.7823, 'geo[pitch]': 5.0030}
				post :create, :params => params
				expect(response).to have_http_status :ok
				ans = JSON.parse(response.body)
				expect(ans['msg']).to eq 'Добавлено местоположение testGeoName.'
				geo = Geo.where(id: ans['id']).first
				expect(geo.user_id).to eq user.id
				expect(geo.geoname).to eq 'testGeoName'
				expect(geo.region).to eq 0
				expect(geo.city).to eq 0
				expect(geo.district).to eq 2
				expect(geo.lattitude).to eq 55.9999
				expect(geo.longitude).to eq 45.0001
				expect(geo.pan_lat).to eq 55.9989
				expect(geo.pan_lon).to eq 45.0014
				expect(geo.bearing).to eq 14.7823
				expect(geo.pitch).to eq 5.0030
			end
			it 'должно бросать ошибку, если параметры не обернуты в geo' do
				user = FactoryBot.create :user
				login_user user
				request.env['HTTP_ACCEPT'] = 'application/json'
				post :create, :params => {'notgeo[geoname]': 'testGeoName', 'region': 0, 'city': 0}
				expect(response.status).to eq 500
				expect(response.body).to match 'param is missing or the value is empty'
			end
			it 'должно бросать ошибку, если передано не верное местоположение' do
				user = FactoryBot.create :user
				login_user user
				request.env['HTTP_ACCEPT'] = 'application/json'
				post :create, :params => {'geo[geoname]': '', 'geo[region]': 0, 'geo[city]': 0}
				expect(response.body).to match 'не может быть пустым'
				expect(response.status).to eq 423
			end
			it "количество не должно превышать #{ENV['max_geos_count_per_user']} шт" do
				user = FactoryBot.create :user
				login_user user
				for i in 1..ENV['max_geos_count_per_user'].to_i do
					Geo.create geoname: "Местоположение №#{i}", user_id: user.id
				end
				expect(user.geos.count).to eq ENV['max_geos_count_per_user'].to_i
				request.env['HTTP_ACCEPT'] = 'application/json'
				post :create, :params => {'geo[geoname]': "Местоположение №#{ENV['max_geos_count_per_user'].to_i+1}"}
				expect(response.status).to eq(423)
				expect(response.body).to match "Допускается не более #{ENV['max_geos_count_per_user']} местоположений."
			end
		end
		describe 'update' do
			it 'местоположение по умолчанию должно редактироваться' do
				user = FactoryBot.create :user
				expect(user.geoname).to eq 'Мой склад'
				expect(user.region).to eq nil
				expect(user.city).to eq nil
				expect(user.district).to eq nil
				expect(user.lattitude).to eq nil
				expect(user.longitude).to eq nil
				expect(user.pan_lat).to eq nil
				expect(user.pan_lon).to eq nil
				expect(user.bearing).to eq nil
				expect(user.pitch).to eq nil
				login_user user
				request.env['HTTP_ACCEPT'] = 'application/json'
				params = {'id':0, 'user[geoname]': 'defailt geo',
							'user[region]': 0, 'user[city]': 0, 'user[district]': 2,
							'user[lattitude]': 55.9999, 'user[longitude]': 45.0001,
							'user[pan_lat]': 55.9989, 'user[pan_lon]': 45.0014,
							'user[bearing]': 14.7823, 'user[pitch]': 5.0030}
				post :update, :params => params
				expect(response).to have_http_status :ok
				ans = JSON.parse(response.body)
				expect(ans['msg']).to eq 'Местоположение defailt geo отредактировано.'
				user.reload
				expect(user.geoname).to eq 'defailt geo'
				expect(user.region).to eq 0
				expect(user.city).to eq 0
				expect(user.district).to eq 2
				expect(user.lattitude).to eq 55.9999
				expect(user.longitude).to eq 45.0001
				expect(user.pan_lat).to eq 55.9989
				expect(user.pan_lon).to eq 45.0014
				expect(user.bearing).to eq 14.7823
				expect(user.pitch).to eq 5.0030
			end
			it 'произвольное местоположение должно редактироваться' do
				user = FactoryBot.create :user, :with_geos, :n_count => 5
				geo = user.geos.first
				login_user user
				request.env['HTTP_ACCEPT'] = 'application/json'
				params = {'id':geo.id, 'geo[geoname]': 'geo test name',
							'geo[region]': 0, 'geo[city]': 0, 'geo[district]': 2,
							'geo[lattitude]': 55.9999, 'geo[longitude]': 45.0001,
							'geo[pan_lat]': 55.9989, 'geo[pan_lon]': 45.0014,
							'geo[bearing]': 14.7823, 'geo[pitch]': 5.0030}
				post :update, :params => params
				expect(response).to have_http_status :ok
				ans = JSON.parse(response.body)
				expect(ans['msg']).to eq 'Местоположение geo test name отредактировано.'
				geo.reload
				expect(geo.geoname).to eq 'geo test name'
				expect(geo.region).to eq 0
				expect(geo.city).to eq 0
				expect(geo.district).to eq 2
				expect(geo.lattitude).to eq 55.9999
				expect(geo.longitude).to eq 45.0001
				expect(geo.pan_lat).to eq 55.9989
				expect(geo.pan_lon).to eq 45.0014
				expect(geo.bearing).to eq 14.7823
				expect(geo.pitch).to eq 5.0030
			end
			it 'должен бросать ошибку, если не передан id местоположения' do
				user = FactoryBot.create :user
				login_user user
				request.env['HTTP_ACCEPT'] = 'application/json'
				post :update, :params => {'user[geoname]': 'test geo'}
				expect(response.body).to match 'Местоположение не передано.'
				expect(response.status).to eq(423)
			end
			it 'должен бросать ошибку, если id местоположения нецелое или отрицательное' do
				user = FactoryBot.create :user
				login_user user
				request.env['HTTP_ACCEPT'] = 'application/json'
				post :update, :params => {'id': -2, 'user[geoname]': 'test geo'}
				expect(response.body).to match 'не может быть меньше 0'
				expect(response.status).to eq(400)
			end
			it 'должен бросать ошибку, если местоположения нет в списке пользователя' do
				user = FactoryBot.create :user, :with_geos, :n_count => 1
				geo = user.geos.first
				login_user user
				request.env['HTTP_ACCEPT'] = 'application/json'
				post :update, :params => {'id': geo.id+1, 'user[geoname]': 'test geo'}
				expect(response.body).to match 'Объект не принадлежит пользователю.'
				expect(response.status).to eq(403)
			end
		end
		describe 'remove' do
			it 'местоположение должно удаляться' do
				user = FactoryBot.create :user, :with_geos, :n_count => 1
				geo = user.geos.first
				cnt = user.geos.count
				expect(cnt).to eq 1
				login_user user
				request.env['HTTP_ACCEPT'] = 'application/json'
				post :remove, :params => {'id': geo.id}
				expect(response.body).to match 'Местоположение удалено.'
				expect(response).to have_http_status :ok
				user.reload
				cnt = user.geos.count
				expect(cnt).to eq 0
			end
			it 'нельзя удалить местоположение по умолчанию' do
				user = FactoryBot.create :user
				login_user user
				request.env['HTTP_ACCEPT'] = 'application/json'
				post :remove, :params => {'id': 0}
				expect(response.body).to match 'Нельзя удалить местоположение по умолчанию.'
				expect(response.status).to eq(403)
			end
			it 'должен бросать ошибку, если не передан id местоположения' do
				login_user
				request.env['HTTP_ACCEPT'] = 'application/json'
				post :remove, :params => {}
				expect(response.body).to match 'Местоположение не передано.'
				expect(response.status).to eq(423)
			end
			it 'должен бросать ошибку, если id местоположения нецелое или отрицательное' do
				login_user
				request.env['HTTP_ACCEPT'] = 'application/json'
				post :remove, :params => {'id': -2}
				expect(response.body).to match 'не может быть меньше 0'
				expect(response.status).to eq(400)
			end
			it 'должен бросать ошибку, если местоположения нет в списке пользователя' do
				user = FactoryBot.create :user, :with_geos, :n_count => 1
				geo = user.geos.first
				login_user user
				request.env['HTTP_ACCEPT'] = 'application/json'
				post :remove, :params => {'id': geo.id+1}
				expect(response.body).to match 'Объект не принадлежит пользователю.'
				expect(response.status).to eq(403)
			end
		end
		describe 'show' do
			it 'должен отрендерить местоположение' do
				user = FactoryBot.create :user, :with_geos, :n_count => 1
				geo = user.geos.first
				login_user user
				request.env['HTTP_ACCEPT'] = 'plain/text,text/xml,text/html'
				get :show, :params => {'id': geo.id}
				expect(response.body).to match 'м. Тушинская'
				expect(response).to have_http_status :ok
			end
			it 'должен бросать ошибку, если не передан id местоположения' do
				login_user
				request.env['HTTP_ACCEPT'] = 'plain/text,text/xml,text/html'
				get :show, :params => {}
				expect(response.body).to match 'Местоположение не передано.'
				expect(response.status).to eq(423)
			end
			it 'должен бросать ошибку, если id местоположения нецелое или отрицательное' do
				login_user
				request.env['HTTP_ACCEPT'] = 'plain/text,text/xml,text/html'
				get :show, :params => {'id': -2}
				expect(response.body).to match 'не может быть меньше 0'
				expect(response.status).to eq(400)
			end
			it 'должен бросать ошибку, если местоположения нет в списке пользователя' do
				user = FactoryBot.create :user, :with_geos, :n_count => 1
				geo = user.geos.first
				login_user user
				request.env['HTTP_ACCEPT'] = 'plain/text,text/xml,text/html'
				get :show, :params => {'id': geo.id+1}
				expect(response.body).to match 'Объект не принадлежит пользователю.'
				expect(response.status).to eq(403)
			end
		end
	end
end