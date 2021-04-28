require 'rubygems'
require 'cgi'
require 'uri'
require 'net/http'
require 'net/http/post/multipart'

module Incotex
class Server
	def login(login, password)
		url = 'https://rd.incotexkkm.ru/user/login'
		uri = URI url
		req = Net::HTTP::Get.new uri.request_uri
		@http = Net::HTTP.new('rd.incotexkkm.ru', 443)
		@http.use_ssl = true
		@http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		resp = @http.request req
		formBuildID = resp.body.slice(/value="form-.+"/)
		formBuildID = formBuildID[12..-2]
		# puts "Грабим id формы аутентификации: #{formBuildID}"

		req = Net::HTTP::Post.new uri.request_uri
		req.set_form_data( 
			'name' => login,
			'pass' => password,
			'form_build_id' => "form-#{formBuildID}",
			'form_id' => 'user_login',
			'op' => 'Вход')
		resp = @http.request req

		if resp['location'] = 'https://rd.incotexkkm.ru/users/sunlit943gmailcom'
			puts "authorized as #{login}"
		else
			# puts resp.body
			puts 'login error'
			return
		end
		all_cookies = resp.get_fields 'set-cookie'
		cookies_array = Array.new
		all_cookies.each { | cookie |
		    cookies_array.push(cookie.split('; ')[0])
		}
		@cookies = cookies_array.join '; '
		# puts @cookies		
	end

	def send_file(kkts, filename)
		for kkt in kkts do
			sndfl(kkt, filename)
		end
	end
private
	def sndfl(kkt, filename)
		url = "https://rd.incotexkkm.ru/device/#{kkt.id}/wares/upload"
		uri = URI url
		req = Net::HTTP::Get.new uri.request_uri
		req['cookie'] = @cookies
		resp = @http.request req

		formBuildID = resp.body.slice(/form_build_id" value="form-.+"/)
		formBuildID = formBuildID[27..-2]
		# puts "Грабим id формы отправки файла: #{formBuildID}"
		formToken = resp.body.slice(/form_token" value=".+"/)
		formToken = formToken[19..-2]
		# puts "Грабим токен формы отправки файла: #{formToken}"

		File.open(filename) do |file|
			params = {
		  	'form_build_id' => "form-#{formBuildID}",
			'form_token' => formToken,
			'form_id' => 'form_wares_file_upload',
			'op' => 'Загрузить в кассу'}
			params["files[file]"] = UploadIO.new(file, "application/octet-stream", File.basename(filename))
			req = Net::HTTP::Post::Multipart.new(uri.path, params)
			req['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
			req['Cookie'] = @cookies+'; adaptive_image=1680; has_js=1'
			req['authority'] = 'rd.incotexkkm.ru'
			resp = @http.request req
			# puts resp
		end
		puts "file #{filename} sended to #{kkt.id}##{kkt.sn} #{kkt.ip} [#{kkt.addr}]"
	end
end

class KKT
	attr_reader :id
	attr_reader :sn
	attr_reader :ip
	attr_reader :addr
	def initialize id, sn, ip, addr
		@id = id
		@sn = sn
		@ip = ip
		@addr = addr
	end
end
end