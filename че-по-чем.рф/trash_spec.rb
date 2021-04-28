require 'rails_helper'
describe Cabinet::TrashController do
	render_views
	controller_methods = [	{name: :index, method: 'GET', params: {}},
							{name: :trash, method: 'GET', params: {id: 5}},
							{name: :restore, method: 'GET', params: {id: 6}}
						]

	error_not_authorized controller_methods

	context 'Подтвержденный авторизованный пользователь' do
		describe 'index action' do
			it 'Страница должна быть отображена для подтвержденного пользователя' do
				login_user
				get :index
				expect(response).to have_http_status(:ok)
				expect(response).to render_template(:index)

				expect(assigns(:menu)).to eq :trash
				expect(assigns(:advs).count).to eq 0
			end

			it 'Недоступные объявления не должны присутствовать на странице' do
				adv = FactoryBot.create :published_trashed_adv
				adv.update_attribute :accessible, false
				adv.update_attribute :title, 'not_accessible adv'

				login_user adv.user
				adv2 = FactoryBot.create :published_trashed_adv
				adv2.update_attributes title: 'accessible adv', user_id: adv.user.id
				adv2.save
				get :index
				expect(response).to have_http_status(:ok)
				expect(response).to render_template(:index)
				expect(response.body).to match 'accessible adv'
				expect(response.body).not_to match 'not_accessible adv'

				expect(assigns(:menu)).to eq :trash
				expect(assigns(:advs).count).to eq 1
			end
		end

		describe 'trash action' do
			it 'Активное объявление должно помещаться в корзину, становиться неактивным' do
				active_adv = FactoryBot.create :active_adv
				login_user active_adv.user
				request.env["HTTP_ACCEPT"] = 'application/json'
				post :trash, :params=> {id: active_adv.id}
				expect(response).to have_http_status(:ok)
				body = JSON.parse response.body
				expect(body['msg']).to eq 'Объявление помещено в корзину.'
		
				adv = Adv.where(id: active_adv.id).first
				expect(adv).not_to be_nil
				expect(adv.trashed).to be true
			end
			it 'Неактивное объявление должно помещаться в корзину' do
				adv = FactoryBot.create :adv
				expect(adv.trashed).to be false
				login_user adv.user
				request.env["HTTP_ACCEPT"] = 'application/json'
				post :trash, :params=> {id: adv.id}
				expect(response).to have_http_status(:ok)
				body = JSON.parse response.body
				expect(body['msg']).to eq 'Объявление помещено в корзину.'

				adv = Adv.where(id: adv.id).first
				expect(adv).not_to be_nil
				expect(adv.trashed).to be true
			end
			it 'должно бросать ошибку, если объявление уже в корзине' do
				adv = FactoryBot.create :adv
				adv.update_attribute :trashed, true
				login_user adv.user
				request.env["HTTP_ACCEPT"] = 'application/json'
				post :trash, :params=> {id: adv.id}
				expect(response.status).to eq 423
				body = JSON.parse response.body
				expect(body['msg']).to eq 'Объявление уже помещено в корзину.'

				adv = Adv.where(id: adv.id).first
				expect(adv).not_to be_nil
				expect(adv.trashed).to be true
			end
			it 'Недоступное объявление не должно помещаться в корзину' do
				adv = FactoryBot.create :not_accessible_adv
				expect(adv.trashed).to be false
				login_user adv.user
				request.env["HTTP_ACCEPT"] = 'application/json'
				post :trash, :params=> {id: adv.id}
				expect(response.status).to eq 404
				body = JSON.parse response.body
				expect(body['msg']).to eq 'Объявление не найдено.'
			end
			it 'должно бросать ошибку, если объявление не принадлежит пользователю' do
				adv = FactoryBot.create :adv
				login_user
				request.env["HTTP_ACCEPT"] = 'application/json'
				post :trash, :params=> {id: adv.id}
				expect(response.status).to eq 403
				body = JSON.parse response.body
				expect(body['msg']).to eq 'Объявление не принадлежит пользователю.'
		
				adv = Adv.where(id: adv.id).first
				expect(adv.trashed).to be false
			end
			it 'должно бросать ошибку, если объявление не существует' do
				login_user
				request.env["HTTP_ACCEPT"] = 'application/json'
				post :trash, :params=> {id: 100500}
				expect(response.status).to eq 404
				body = JSON.parse response.body
				expect(body['msg']).to eq 'Объявление не найдено.'
			end
		end

		describe 'restore action' do
			it 'Объявление должно восстанавливаться из корзины и становиться активным' do
				adv = FactoryBot.create :published_trashed_active_adv
				login_user adv.user
				request.env["HTTP_ACCEPT"] = 'application/json'
				post :restore, :params=> {id: adv.id}
				expect(response).to have_http_status(:ok)
				body = JSON.parse response.body
				expect(body['msg']).to eq 'Объявление восстановлено из корзины.'
		
				adv = ActiveAdv.where(id: adv.id).first
				expect(adv).not_to be_nil
				expect(adv.trashed).to be false
			end
			it 'Удаленное объявление не должно восстанавливаться из корзины' do
				adv = FactoryBot.create :not_accessible_adv
				expect(adv.trashed).to be false
				login_user adv.user
				request.env["HTTP_ACCEPT"] = 'application/json'
				post :trash, :params=> {id: adv.id}
				expect(response.status).to eq 404
				body = JSON.parse response.body
				expect(body['msg']).to eq 'Объявление не найдено.'
			end
			it 'должно бросать ошибку, если объявление вне в корзины' do
				adv = FactoryBot.create :adv
				login_user adv.user
				request.env["HTTP_ACCEPT"] = 'application/json'
				post :restore, :params=> {id: adv.id}
				expect(response.status).to eq 423
				body = JSON.parse response.body
				expect(body['msg']).to eq 'Объявление вне корзины.'
			end
			it 'должно бросать ошибку, если объявление не принадлежит пользователю' do
				adv = FactoryBot.create :published_trashed_adv
				login_user
				request.env["HTTP_ACCEPT"] = 'application/json'
				post :restore, :params=> {id: adv.id}
				expect(response.status).to eq 403
				body = JSON.parse response.body
				expect(body['msg']).to eq 'Объявление не принадлежит пользователю.'
		
				adv = Adv.where(id: adv.id).first
				expect(adv.trashed).to be true
			end
			it 'должно бросать ошибку, если объявление не существует' do
				login_user
				request.env["HTTP_ACCEPT"] = 'application/json'
				post :restore, :params=> {id: 100500}
				expect(response.status).to eq 404
				body = JSON.parse response.body
				expect(body['msg']).to eq 'Объявление не найдено.'
			end
		end
	end
end