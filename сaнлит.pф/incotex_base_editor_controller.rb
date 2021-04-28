require 'json'
require 'json/minify'
require 'spreadsheet'

class IncotexBaseEditorController < SignedInController
	def index
		@items = current_user.incotex_items.order 'code ASC'
		render 'incotex_base_editor/index'
	end

   def create
      item = current_user.incotex_items.where(code: params[:incotex_item][:code]).first
      if item
         render json: JSON.generate({ msg: 'Товарная позиция с таким номером уже существует' }), status: 500
         return
      end

      params[:incotex_item][:user_id] = current_user.id
      permitted = params.require(:incotex_item).permit(IncotexItem.permitted << 'user_id')
      item = IncotexItem.create permitted
      if !item.errors.empty?
         msg = 'Ошибка создания товарной позиции. Запрос содержит следующие ошибки: '
         msg << item.errors.full_messages.to_s
         ans = {msg: msg}.to_json
         render json: ans, status: 500
         return
      end

      render json: JSON.generate({ msg: 'Создана товарная позиция', id: item.id})
   end

   def update
      if !params[:id]
         render json: JSON.generate({ msg: 'Не передан id товара' }), status: 500
         return
      else
         id = params[:id]
      end

      item = current_user.incotex_items.where(id: id).first
      if !item
         render json: JSON.generate({ msg: 'Товарная позиция не найдена' }), status: 500
         return
      end

      other_item = current_user.incotex_items.where(code: params[:incotex_item][:code]).first
      if other_item and other_item.id != item.id
         render json: JSON.generate({ msg: 'Дублирование кода товарной позиции' }), status: 500
         return
      end
      
      permitted = params.require(:incotex_item).permit IncotexItem.permitted
      item.update_attributes permitted
      if !item.errors.empty?
         msg = 'Ошибка правки товарной позиции. Запрос содержит следующие ошибки: '
         msg << item.errors.full_messages.to_s
         ans = {msg: msg}.to_json
         render json: ans, status: 500
         return
      end

      render json: JSON.generate({ msg: 'Изменение товарной позиции успешно' })
   end

   def destroy
      if !params[:id]
         render json: JSON.generate({ msg: 'Не передан id товара' }), status: 500
         return
      else
         id = params[:id]
      end

      item = current_user.incotex_items.where(id: id).first
      if !item
         render json: JSON.generate({ msg: 'Товарная позиция не найдена' }), status: 500
         return
      end

      item.destroy

      render json: JSON.generate({ msg: 'Товарная позиция удалена' })
   end

   def destroy_all
      current_user.incotex_items.destroy_all
      render json: JSON.generate({ msg: 'Все товары удалены' })
   end

	def send_to_kkt
      json_file = "#{Rails.root}/tmp/#{current_user.id}.json"
		build_json_file json_file

      login = Rails.application.secrets.incotex_login
      pwd = Rails.application.secrets.incotex_password
		is = Incotex::Server.new
		is.login login, pwd
      kkts = []
      current_user.cash_registers.where("\"cash_registers\".\"incotex_id\" IS NOT NULL").each do |cs|
         kkts << Incotex::KKT.new(
            cs.incotex_id,
            cs.serial_number,
            current_user.short_name,
            cs.address)
      end

		is.send_file kkts, json_file
      ApplicationMailer.goods_copy(current_user.short_name, json_file, 'json').deliver
      render json: JSON.generate({ msg: "Список товаров был отослан"})
   ensure
      File.delete json_file if File.exist? json_file
	end

	def load_from_file
		if !params[:file]
			flash[:error] = 'Выберите файл json или xls'
			render 'incotex_base_editor/index'
			return
		end
      current_user.incotex_items.destroy_all
      ext = File.extname params[:file].path
      if ext == '.json'
         load_from_json params[:file].path
      else
         load_from_xls params[:file].path
      end
		flash[:success] = 'Товары были загружены'
		redirect_to :incotex_base_editor_index
   rescue => e
      flash[:error] = e.message
      redirect_to :incotex_base_editor_index      
	end

   def assign_incotex_id
      incotex_id = params[:id]
      kkt_id = params[:kkt]
      kkt = current_user.cash_registers.where(id: kkt_id).first
      kkt.incotex_id = incotex_id
      kkt.save
      render json: JSON.generate({ msg: 'id присвоен' })
   end
private
	def build_json_file fname
      json = []
      items = current_user.incotex_items.all.each {|item|
         json << item.to_json
      }
      json = JSON.minify "{\"base\":[#{json.join ','}]}";
      slack_feedback "#{current_user.id}:#{current_user.short_name}: #{json}"
		File.open(fname, 'w') { |file| file.write(json) }
	end

   def load_from_json fname
      json = IO.read fname
      json.delete! "\r\n"
      base = JSON.parse(json)
      base['base'].each do |item|
         ii = IncotexItem.new
         ii.user        = current_user
         ii.code        = item['code']
         ii.barcode     = item['barcode']
         ii.name        = item['name']
         ii.name = ii.name[0..55] if ii.name.length > 56
         ii.price       = item['price'].to_f/100
         ii.marking     = item['marked']
         ii.section     = item['section']
         ii.undivided   = item['undivided']
         ii.type_code = item['typeCode'] if item['typeCode']
         ii.tax_code = item['taxСode'] if item['taxСode']
         ii.tax_system = item['taxSystem'] if item['taxSystem']
         ii.agent = item['agentNum'] if item['agentNum']

         if !ii.save
            raise "Ошибка формата файла. Товар #{ii.code}: #{ii.errors.full_messages}"
         end
      end
   end

   def load_from_xls fname
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet.open fname
      sheet = book.worksheet 0
      code = 1
      sheet.each do |item|
         raise "Ошибка формата файла. #{item}" if !item[0]
         ii = IncotexItem.new
         ii.user        = current_user
         ii.code        = code
         ii.name        = item[0]
         ii.name = ii.name[0..55] if ii.name.length > 56
         ii.barcode     = item[1] if !item[1].blank?
         ii.marking     = item[2] if !item[2].blank?
         ii.price       = item[3].to_f if !item[3].blank?
         ii.section     = item[4] if !item[4].blank?
         ii.type_code   = item[5] if !item[5].blank?
         ii.tax_code    = item[6] if !item[6].blank?
         ii.undivided   = item[7] if !item[7].blank?
         ii.tax_system  = item[8] if !item[8].blank?
         ii.agent       = item[9] if !item[9].blank?

         if !ii.save
            puts "#{code} item with error:"
            puts ii.inspect
            raise "Ошибка формата файла. Товар #{ii.code}: #{ii.errors.full_messages}"
         end
         code += 1
      end
   end
end