require 'nokogiri'
require 'open-uri'

namespace :operators do
  task :load, [:threads_number] => :environment do |t, args|
    threads_number = args[:threads_number].nil? ? 10 : args[:threads_number].to_i
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
      a = Address.create( parse_address(operator_info.delete(:joint_address)) )
      o = Operator.new(operator_info)
      o.address = a
      o.save
      puts "Save operator: #{operator_info[:name]}"
    else
      o = operators.first
      a = o.address
      Address.update(a.id, parse_address(operator_info.delete(:joint_address)) )
      Operator.update(o.id, operator_info)
      puts "Update operator: #{operator_info[:name]}"
    end
  end

  def parse_address(address_string)
    address = {}
    address_array = address_string.gsub(/\,\s/, ',').split(',')
    # zip_code
    address["zip_code"] = address_array[0]
    address_array.delete_at(0)
    # street
    address_array.each do |elem|
      if elem.include?("ул.") || elem.include?("пр-кт") || elem.include?("пл.") || elem.include?("пр.")
        address["street"] = elem
        break
      end
    end
    # region
    region = []
    address_array.each do |elem|
      if elem.include?('Республик') ||
        elem.include?('г.') ||
        (elem.include?('д.') && (/[0-9]/=~ elem).nil?) ||
        elem.include?('край') ||
        elem.include?('г.') ||
        elem.include?('наб.') ||
        elem.include?('Санкт-Петербург') ||
        elem.include?('Москва')
        region << elem
      end
    end
    unless region == []
      address["region"] = region.join(',')
    end
    # office
    address_array.each do |elem|
      if elem.include?("оф.") || elem.include?("офис") || elem.include?("кв.") || elem.include?("пом.")
        address["office_number"] = elem
        break
      end
    end
    # housing
    address_array.each do |elem|
      if elem.include?("лит.") || elem.include?("корп.") || elem.include?("корпус") || elem.include?("стр.")
        address["housing"] = elem
        break
      end
    end
    # housing
    address_array.each do |elem|
      if (elem.include?("д.") && !(/[0-9]/=~ elem).nil? ) || (/^\d+$|\d+\/\d+$|\d+.$|\d+\/\d+.$/=~ elem) == 0
        address["house_number"] = elem
        break
      end
    end
    puts "Get address #{address.to_s} from address_string: #{address_string}"
    address
  end
end