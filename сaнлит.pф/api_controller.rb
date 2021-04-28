class ApiController < ApplicationController
	skip_before_action :verify_authenticity_token

	def get_contragents
		user = User.first
		usr = {
			id: user.id,
			inn: user.inn,
			kpp: user.kpp,
			full_name: user.full_name,
			short_name: user.short_name,
			u_address: user.u_address,
			f_address: user.f_address,
			p_address: user.p_address,
			phone: user.phone,
			boss_name: user.boss_name
		}
		render json: usr.to_json
	end

	def create_contragent
		pwd = params['user']['password']
		params['user']['inn'] = params['user']['inn'].strip
		permitted = params.require(:user).permit(:email, :password, :password_confirmation, :inn, :kpp, :full_name,
		:short_name, :u_address, :f_address, :p_address, :phone, :boss_name)
		@user = User.new permitted
		@user.save
		if !@user.errors.empty?
			if @user.errors.include?('email') or @user.errors.include?('inn')
				render json: @user.errors.to_json
				return
			end
		end
		@user.save validate: false
		ApplicationMailer.account_created(@user.id, pwd).deliver! if !Rails.env.development?
		slack_user_account @user, pwd
		render json: {result: 'ok', user_id: @user.id, password: pwd}.to_json
	end

	def create_cash_register
		prm = CashRegister.permitted
		prm << 'user_id'
		prm << 'serial_number'
		prm << 'reg_number'
		prm << 'incotex_id'
		cr = CashRegister.new params.require(:cash_register).permit(prm)
		cr.incotex_id = nil if cr.incotex_id == 0
		cr.save validate: false
		cr.reload
		slack_feedback "*КАССА ДОБАВЛЕНА*\n`Модель #{cr.human_model}`\n`Серийный номер #{cr.serial_number}`"
		render json: {result: 'ok', id: cr.id}.to_json
	end
end