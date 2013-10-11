require 'nokogiri'
require 'open-uri'

namespace :operators do
  task :load [:threads_number] => :environment do |t, args|
    threads_number = args[:threads_number].nil? 10 : args[:threads_number]
    ThinkingSphinx.deltas_enabled = false
    start = Time.zone.now
    puts start.to_s
    peach threads_number, get_operator_pages, lambda { |path| load_operator_info_to_base(create_operator_info(path)) }
    puts (Time.zone.now - start).to_s
    puts Time.zone.now.to_s
  end

  def get_operator_pages
    doc = Nokogiri::HTML(open('http://reestr.russiatourism.ru/?ac=search&mode=1&ext=1&number=&name=&id_region=0&address=&fo_name='))
    paths = []
    doc.xpath('//table[@class="mra-l"]/tr/td/nobr/a').each do |tag|
      paths << "http://reestr.russiatourism.ru/?ac=view&id_reestr=#{tag[:href].split('=').last}"
    end
    paths
  end

  def peach(threads_number, collection, method)
    thrs = []
    threads_number.times { thrs << nil }
    puts thrs.length
    thrs.each_with_index do |thr, i|
      length = (collection.length / threads_number).to_i
      if i != (threads_number-1)
        coll = collection[ i*length .. ((i+1)*length-1) ]
      else
        coll = collection[ i*length .. (collection.length-1) ]
      end
      thrs[i] = Thread.new{coll.each { |item| method.call(item) }}
    end
    puts threads_number.to_s + " threads was started"
    thrs.each do |thr|
      thr.join
    end
  end

  def create_operator_info(path)
    info = {}
    puts "Open: #{path}"
    doc = Nokogiri::HTML(open(path))
    doc.xpath('//table[@class="mra-l"]/tr/td').each do |tag|
      case
      when tag.content.include?("Реестровый номер")
        info[:register_number] = tag.next_element.content.split(' ').last
        info[:register_series] = tag.next_element.content.split(' ').first
      when tag.content.include?("Сокращенное наименование")
        info[:name] = tag.next_element.content
      when tag.content.include?("ИНН:")
        info[:inn] = tag.next_element.content
      when tag.content.include?("ОГРН:")
        info[:ogrn] = tag.next_element.content
      when tag.content.include?("сайт")
        info[:site] = tag.next_element.content
      when tag.content.include?("Наименование организации, предоставившей финансовое обеспечение")
        info[:insurer] = tag.next_element.content
      when tag.content.include?("Адрес (место нахождения) организации, предоставившей финансовое обеспечение")
        info[:insurer_address] = tag.next_element.content
      when tag.content.include?("Размер финансового обеспечения")
        info[:insurer_provision] = tag.next_element.content
      when tag.content.include?("Документ:")
        content = tag.next_element.content
        date = content.last(10).split('/')
        info[:insurer_contract] = content.first(content.length - 14)
        info[:insurer_contract_date] = [date[2], date[1], date[0]].join('.')
      when tag.content.include?("Срок действия финансового обеспечения")
        content = tag.next_element.content
        date = content[2..11].split('/').map { |e| e.to_i }
        info[:insurer_contract_start] = [date[2], date[1], date[0]].join('.')
        date = content.last(10).split('/').map { |e| e.to_i }
        info[:insurer_contract_end] = [date[2], date[1], date[0]].join('.')
      when tag.content.include?("Адрес (место нахождения):")
        info[:joint_address] = tag.next_element.content
      end
    end
    info
  end

  def load_operator_info_to_base(operator_info)
    operators = Operator.where(:register_number => operator_info[:register_number],
      :register_series => operator_info[:register_series],
      :company_id => nil)
    if operators.blank?
      address = operator_info.delete(:joint_address)
      a = Address.create( parse_address(operator_info.delete(:joint_address)) )
      o = Operator.new(operator_info)
      o.address = a
      o.save
    else
      o = operators.first
      a = o.address
      Address.update(a.id, parse_address(operator_info.delete(:joint_address)) )
      Operator.update(o.id, operator_info)
    end
  end

  def parse_address(address_string)
    address = {
      "region" => nil,
      "street" => nil,
      "house_number" => nil,
      "housing" => nil,
      "office_number" => nil
    }
    address_array = address_string.split(',')
    address["zip_code"] = address_array[0]
    address
  end


end