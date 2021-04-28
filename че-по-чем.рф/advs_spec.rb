require 'rails_helper'
describe AdvsController do
	render_views
	controller_methods = [{name: :show, method: 'GET', params: {}}]

	context 'Неавторизованный пользователь' do
		describe 'show' do
			it 'Просмотр должен быть доступен' do
				adv = FactoryBot.create :active_adv
				adv.update_attribute :title, 'Просматриваемое объявление'
				get :show, :params => {secure: adv.secure}
				expect(response.status).to eq 200
				expect(response.body).to match 'Просматриваемое объявление'
			end

			it 'Просмотр недоступного объявления должен быть запрещен' do
				adv = FactoryBot.create :active_adv
				adv.update_attribute :title, 'Просматриваемое объявление'
				adv.update_attribute :accessible, false
				get :show, :params => {secure: adv.secure}
				expect(response.status).to eq 403
				expect(response.body).not_to match 'Просматриваемое объявление'
			end
		end
	end
end