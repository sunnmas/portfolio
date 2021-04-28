class RedisCountersDailyWorker
	include Sidekiq::Worker
	def perform
		total_amount = User.all.sum(:amount) - User.where(admin: true).first.amount
		RedisCounters.inc_by 'total_amount', total_amount

		inc_day = Incoming.where("created_at > '#{30.day.ago.to_s}'").where(status: 1).sum :real_sum
		inc_day /= 30
		RedisCounters.inc_by 'incomings_day', eval(sprintf('%8.2f', inc_day))

		RedisCounters.inc_by 'active_advs', ActiveAdv.count
		
		RedisCounters.inc_by 'active_accounts', User.active.count

		RedisCounters.inc_by 'vip_advs', ActiveAdv.vips.count
		RedisCounters.inc_by 'turbo_advs', ActiveAdv.turbos.count
		
		live_accounts = User.live.count
		RedisCounters.inc_by 'live_accounts', live_accounts
		
		vip_accounts = User.select(:id).vip.count
		RedisCounters.inc_by 'vip_accounts', vip_accounts
		
		live_vip_accounts = User.select(:id).live.vip.count
		RedisCounters.inc_by 'live_vip_accounts', live_vip_accounts

		dead_accounts = User.select(:id).dead.count
		RedisCounters.inc_by 'dead_accounts', dead_accounts

		poor_accounts = User.select(:id).poor.count
		RedisCounters.inc_by 'poor_accounts', poor_accounts

		RedisCounters.inc_by 'disk_space', Health.usedHDD

		u_cnt = ScrapyImport.new.unprocessed_cnt
		RedisCounters.inc_by 'scrapy_unpocessed', u_cnt

		act_vouch = Voucher.active.sum :value
		RedisCounters.inc_by 'active_vouchers', act_vouch
		
		RedisCounters.pack 'daily'
	rescue => e
		slack e
	end
end

