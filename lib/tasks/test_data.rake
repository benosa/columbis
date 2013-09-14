namespace :test_data do
  desc "copy and fake data"
  task :step1 => :environment do
    @res_comp_id = 8

    Company.destroy_all(name: 'testcompany')

    @company = Company.create(name: 'testcompany', email: Faker::Internet.email,
      oficial_letter_signature: 'bye', subdomain: Faker::Lorem.sentence)

    @office1 = Office.new(name: 'Офис1')
    @office2 = Office.new(name: 'Офис2')
    @office1.company = @company
    @office2.company = @company
    @office1.save
    @office2.save
    @boss = create_user(@company, @office1, 'boss', 'demo', '123456')
    @manager1 = create_user(@company, @office1, 'manager', 'demoman1', '123456')
    @manager2 = create_user(@company, @office2, 'manager', 'demoman2', '123456')
    @accountant = create_user(@company, @office1, 'accountant', 'demoac', '123456')

    Tourist.where(company_id: @res_comp_id).reorder("id DESC").limit(50).each do |tourist|
      if rand(2) == 0
        tourist.first_name = Faker::Name.female_first_name
        tourist.middle_name = Faker::Name.female_middle_name
        tourist.last_name = Faker::Name.female_last_name
      else
        tourist.first_name = Faker::Name.male_first_name
        tourist.middle_name = Faker::Name.male_middle_name
        tourist.last_name = Faker::Name.male_last_name
      end
      tourist.phone_number = Faker::PhoneNumber.phone_number
      tourist_new = Tourist.new(tourist.attributes)
      tourist_new.company = @company
      tourist_new.save
    end

    50.times do |i|
      operator = Operator.new(name: Faker::Name.operator_name)
      operator.company = @company
      operator.save
    end

    @company.create_address(address_attrs(@company.id))

    Tourist.where(company_id: @company.id).each do |tourist|
      tourist.create_address(address_attrs(@company.id))
    end

    Operator.where(company_id: @company.id).each do |operator|
      operator.create_address(address_attrs(@company.id))
    end

    dropdowns = ['hotel', 'airport', 'airline']

    dropdowns.each do |dropdown|
      20.times do |i|
        dropdown_create(@company, dropdown, Faker::Name.send((dropdown.to_s + '_name').to_sym))
      end
    end

    dropdowns2 = {}
    dropdowns2['tourist_stat'] = ['Знакомые', 'Клиенты', 'Рекомендации', 'Телевизор']
    dropdowns2['transfer'] = ['Да']
    dropdowns2['service_class'] = ['Эконом', 'Бизнес', 'СВ']
    dropdowns2['relocation'] = ['Нет', 'Авиа', 'ЖД', 'Автобус']
    dropdowns2.each do |key, value|
      value.each do |drop|
        dropdown_create(@company, key, drop)
      end
    end

    Claim.where(company_id: @res_comp_id,
      created_at: (Time.now - 3.month)..(Time.now - 1.month)).
      where('arrival_date is not NULL and departure_date is not NULL').each do |claim|

      if rand(2) == 0
        manager = @manager2
      else
        manager = @manager1
      end

      claim_new = Claim.new(claim.attributes)
      claim_new.check_date += 1.month
      claim_new.arrival_date += 1.month
      claim_new.departure_date += 1.month
      claim_new.reservation_date += 1.month
      claim_new.visa_check += 1.month
      claim_new.company = @company
      claim_new.operator = Operator.where(company_id: @company.id).reorder('RANDOM()').first
      claim_new.user = manager
      claim_new.office = manager.office
      claim_new.applicant = Tourist.where(company_id: @company.id).reorder('RANDOM()').first
      claim_new.hotel = DropdownValue.where(company_id: @company.id, list: 'hotel').reorder('RANDOM()').limit(1).pluck(:value)[0]
      claim_new.airline = DropdownValue.where(company_id: @company.id, list: 'airline').reorder('RANDOM()').limit(1).pluck(:value)[0]
      claim_new.service_class = dropdowns2['service_class'].shuffle[0]
      claim_new.relocation = dropdowns2['relocation'].shuffle[0]
      claim_new.city = City.where(name: Faker::Name.from_city_name, common: true).first
      claim_new.transfer = dropdowns2['transfer'].shuffle[0]
      claim_new.tourist_stat = dropdowns2['tourist_stat'].shuffle[0]
      claim_new.country = Country.where(name: Faker::Name.to_country_name, common: true).first
      claim_new.resort =  City.where(country_id: claim_new.country.id).reorder('RANDOM()').first
      claim_new.save
      arrive_time = random_time(claim_new.arrival_date)
      depart_time = random_time(claim_new.departure_date)
      Flight.create(claim_id: claim_new.id, depart: arrive_time, arrive: arrive_time + (rand(4) + 2).hour,
        airport_from: claim_new.city.name, airport_to: claim_new.resort.name, airline: claim_new.airline)
      Flight.create(claim_id: claim_new.id, depart: depart_time, arrive: depart_time + (rand(4) + 2).hour,
        airport_from: claim_new.resort.name, airport_to: claim_new.city.name, airline: claim_new.airline)
      Payment.where(claim_id: claim.id).each do |pay|
        pay_new = Payment.new(pay.attributes)
        pay_new.date_in += 1.month
        pay_new.claim = claim_new
        pay_new.company = @company
        pay_new.recipient_id = switch_pay_type(pay_new.recipient_type, @company, claim_new.applicant, claim_new.operator)
        pay_new.payer_id = switch_pay_type(pay_new.payer_type, @company, claim_new.applicant, claim_new.operator)
        pay_new.save
      end
    end
  end

  def switch_pay_type(type, company, tourist, operator)
    if type == 'Company'
      company.id
    elsif type == "Tourist"
      tourist.id
    elsif type == "Operator"
      operator.id
    end
  end

  def create_user(company, office, role, login, password)
    user = User.new(first_name: Faker::Name.male_first_name, last_name: Faker::Name.male_last_name,
      login: login, password: password, role: role, email: Faker::Internet.email, confirmed_at: Time.now)
    user.company = company
    user.office = office
    user.save
    user
  end

  def dropdown_create(company, list, value)
    dropdown = DropdownValue.new(list: list, value: value)
    dropdown.company = company
    dropdown.save
  end

  def random_time(date)
    rand(date.to_time..(date.to_time + 12.hour))
  end

  def address_attrs(company_id)
    address_attrs = {
      company_id: company_id,
      region: Faker::Address.city_name,
      house_number: Faker::Address.building_number,
      office_number: Faker::Address.building_number,
      street: Faker::Address.street_name
    }
  end
end