namespace :test_data do
  desc "copy and fake data"
  task :step1 => :environment do
    @res_comp_id = 8
    #Faker::Config.locale = :en
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
    @manager2 = create_user(@company, @office1, 'manager', 'demoman2', '123456')
    @accountant = create_user(@company, @office1, 'accountant', 'demoac', '123456')
   # @boss = User.new(first_name: Faker::Name.male_first_name, last_name: Faker::Name.male_last_name,
   #   login: 'demo', password: '123456', role: 'boss', email: Faker::Internet.email)
   # @boss.company = @company
    #@boss.save

   # @manager1 = User.find(172)#User.new(first_name: Faker::Name.female_first_name, last_name: Faker::Name.female_last_name,
      #login: 'demoman1', password: '123457', role: 'manager', email: Faker::Internet.email,
     # confirmed_at: Time.now)
    #@manager1.company = @company
    #@manager1.office = @office1
    #@manager1.save


   # @manager2 = User.find(173)#User.new(first_name: Faker::Name.male_first_name, last_name: Faker::Name.male_last_name,
     # login: 'demoman2', password: '123458', role: 'manager', email: Faker::Internet.email,
     # confirmed_at: Time.now)
    #@manager2.office = @office2
    #@manager2.company = @company
    #@manager2.save

  #  @accountant = User.new(first_name: Faker::Name.female_first_name, last_name: Faker::Name.female_last_name,
  #    login: 'accountant', password: '123459', role: 'accountant', email: Faker::Internet.email)
  #  @accountant.company = @company
   # @accountant.office = @office2
    #@accountant.save

    Tourist.where(company_id: @res_comp_id).reorder("id DESC").limit(10).each do |tourist|
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
      #tourist_new.save
    end

    10.times do |i|
      operator = Operator.new(name: Faker::Name.operator_name)
      operator.company = @company
      #operator.save
    end

  # @company.create_address(address_attrs(@company.id))

    Tourist.where(company_id: @company.id).each do |tourist|
    #  tourist.create_address(address_attrs(@company.id))
    end

    Operator.where(company_id: @company.id).each do |operator|
     # operator.create_address(address_attrs(@company.id))
    end

    dropdowns = ['hotel', 'airport', 'airline']

    dropdowns.each do |dropdown|
      20.times do |i|
       # dropdown_create(@company, dropdown, Faker::Name.send((dropdown.to_s + '_name').to_sym))
      end
    end

    dropdowns2 = {}
    dropdowns2['tourist_stat'] = ['Знакомые', 'Клиенты', 'Рекомендации', 'Телевизор']
    dropdowns2['transfer'] = ['Да']
    dropdowns2['service_class'] = ['Эконом', 'Бизнес', 'СВ']
    dropdowns2['relocation'] = ['Нет', 'Авиа', 'ЖД', 'Автобус']
    dropdowns2.each do |key, value|
      value.each do |drop|
       #  dropdown_create(@company, key, drop)
      end
    end

    tourists = Tourist.where(company_id: @company.id).all.map(&:id)
    operators = Operator.where(company_id: @company.id).all.map(&:id)
    hotels = dropdown_get(@company, 'hotel')
    airlines = dropdown_get(@company, 'airline')
   # airports = dropdown_get(@company, 'airport')
      #puts hotels

    #puts tourists
    Claim.where(company_id: @res_comp_id,
      created_at: (Time.now.midnight - 2.month)..Time.now.midnight).limit(2).each do |claim|
      #country = Country.where(name: Faker::Name.to_country_name, common: true).first
      #Country.find(name: Faker::Name.to_country_name)
      claim_new = Claim.new(claim.attributes)
      #puts claim.attributes
      claim_new.company = @company
      claim_new.operator = Operator.find(operators[rand(operators.length)])
      claim_new.user = rand_obj(@manager1, @manager2)
      claim_new.office = rand_obj(@office1, @office2)
      claim_new.applicant = Tourist.find(tourists[rand(tourists.length)])
      claim_new.hotel = hotels[rand(hotels.length)]
      claim_new.airline = airlines[rand(airlines.length)]
      #claim_new.airport = airports[rand(airports.length)]
      claim_new.service_class = services[rand(services.length)]
      claim_new.relocation = relocations[rand(relocations.length)]
      claim_new.city = City.where(name: Faker::Name.from_city_name, common: true).first
      claim_new.transfer = dropdowns2['transfer'].shuffle[0]
      #find(name: Faker::Name.from_city_name)
      claim_new.tourist_stat = dropdowns2['tourist_stat'].shuffle[0]
      claim_new.country = Country.where(name: Faker::Name.to_country_name, common: true).first
      claim_new.resort =  City.where(country_id: claim_new.country.id).reorder('RANDOM()').first
       # claim_new.applicant_attributes(Tourist.find(tourists[rand(tourists.length)]).attributes)
   #   claim_new.save
      arrive_time = random_time(claim_new.arrival_date)
      depart_time = random_time(claim_new.departure_date)
    #  Flight.create(claim_id: claim_new.id, depart: arrive_time, arrive: arrive_time + (rand(4) + 2).hour,
     #   airport_from: claim_new.city.name, airport_to: claim_new.resort.name, airline: claim_new.airline)
    #  Flight.create(claim_id: claim_new.id, depart: depart_time, arrive: depart_time + (rand(4) + 2).hour,
     #   airport_from: claim_new.resort.name, airport_to: claim_new.city.name, airline: claim_new.airline)
      puts claim_new.id
      puts claim_new.errors.full_messages
     # TouristClaim.create(tourist_id: tourists[rand(tourists.length)], claim_id: claim_new.id)
    end
  end

  def rand_obj(obj1, obj2)
    if rand(2) == 0
        obj1
      else
        obj2
      end
  end

  def create_flight(claim)
    Flight
  end

  def dropdown_get(company, list)
    DropdownValue.where(company_id: @company.id, list: list).all.map(&:value)
  end

  def create_user(company, office, role, login, password)
    user = User.new(first_name: Faker::Name.male_first_name, last_name: Faker::Name.male_last_name,
      login: login, password: password, role: role, email: Faker::Internet.email)
    user.company = company
    user.office = office
    user.save
    user
  end

  def dropdown_create(company, list, value)
    dropdown = DropdownValue.new(list: list, value: value)
    dropdown.company = company
    dropdown.save
    #puts dropdown.attributes
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
  def set_company(company)
    puts company.id
  end
end