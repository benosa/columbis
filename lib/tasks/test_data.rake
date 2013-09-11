namespace :test_data do
  desc "copy and fake data"
  task :step1 => :environment do
    @res_comp_id = 8
    #Faker::Config.locale = :en
    @company = Company.find(121)#Company.create(name: 'testcompany', email: Faker::Internet.email,
      #oficial_letter_signature: 'bye', subdomain: Faker::Lorem.sentence)

    @office1 = Office.find(71)#Office.new(name: Faker::Lorem.sentence)
    @office2 = Office.find(72)#Office.new(name: Faker::Lorem.sentence)
    #@office1.company = @company
   # @office2.company = @company
    #@office1.save
    #@office2.save
    @boss = User.new(first_name: Faker::Name.male_first_name, last_name: Faker::Name.male_last_name,
      login: 'demo', password: '123456', role: 'boss', email: Faker::Internet.email)
    @boss.company = @company
    #@boss.save

    @manager1 = User.find(172)#User.new(first_name: Faker::Name.female_first_name, last_name: Faker::Name.female_last_name,
      #login: 'demoman1', password: '123457', role: 'manager', email: Faker::Internet.email,
     # confirmed_at: Time.now)
    #@manager1.company = @company
    #@manager1.office = @office1
    #@manager1.save


    @manager2 = User.find(173)#User.new(first_name: Faker::Name.male_first_name, last_name: Faker::Name.male_last_name,
     # login: 'demoman2', password: '123458', role: 'manager', email: Faker::Internet.email,
     # confirmed_at: Time.now)
    #@manager2.office = @office2
    #@manager2.company = @company
    #@manager2.save

    @accountant = User.new(first_name: Faker::Name.female_first_name, last_name: Faker::Name.female_last_name,
      login: 'accountant', password: '123459', role: 'accountant', email: Faker::Internet.email)
    @accountant.company = @company
    @accountant.office = @office2
    #@accountant.save

    Tourist.where(company_id: @res_comp_id).unscoped.order("id DESC").limit(10).each do |tourist|
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

    #@company.create_address(address_attrs(@company.id))

    Tourist.where(company_id: @company.id).each do |tourist|
     # tourist.create_address(address_attrs(@company.id))
    end

    Operator.where(company_id: @company.id).each do |operator|
     # operator.create_address(address_attrs(@company.id))
    end

    dropdowns = ['hotel', 'airport', 'airline']

    dropdowns.each do |dropdown|
      20.times do |i|
        dropdown_create(@company, dropdown, Faker::Name.send((dropdown.to_s + '_name').to_sym))
      end
    end

    services = ['Эконом', 'Бизнес', 'СВ']
    relocations = ['Нет', 'Авиа', 'ЖД', 'Автобус']

    services.each do |service|
      dropdown_create(@company, 'service_class', service)
    end

    relocations.each do |relocation|
      dropdown_create(@company, 'relocation', relocation)
    end

    tourists = Tourist.where(company_id: @company.id).all.map(&:id)
    operators = Operator.where(company_id: @company.id).all.map(&:id)
    hotels = dropdown_get(@company, 'hotel')
    #puts hotels

    #puts tourists
    Claim.where(company_id: @res_comp_id,
      created_at: (Time.now.midnight - 2.month)..Time.now.midnight).limit(2).each do |claim|
      claim_new = Claim.new(claim.attributes)
      #puts claim.attributes
      claim_new.company = @company
      claim_new.operator = Operator.find(operators[rand(operators.length)])
      claim_new.user = rand_obj(@manager1, @manager2)
      claim_new.office = rand_obj(@office1, @office2)
      claim_new.applicant = Tourist.find(tourists[rand(tourists.length)])
      claim_new.hotel = hotels[rand(hotels.length)]
     # claim_new.applicant_attributes(Tourist.find(tourists[rand(tourists.length)]).attributes)
      claim_new.save
     # puts claim_new.id
     # puts claim_new.errors.full_messages
     # TouristClaim.create(tourist_id: tourists[rand(tourists.length)], claim_id: claim_new.id)
    end
    #Address.new(address_attrs(@company.id))
    #Address.addressable_id = @company
    #Address.addressable_type = @company
    #Address.save
     # puts @attrs
   #   tourist_new = Tourist.new(@attrs)
   #   tourist_new.company = @company
    #  tourist_new.save
        #company = Company.create(:name => 'fghfgh', :email => 'hhhh@ddd.ty',
    #  :oficial_letter_signature => 'bye')
   #company_one = FactoryGirl.create(:company)
   # @company.save
   # @office1 = Office.create(:name => 'testoffice1', :company_id => @company.id)
   # @office2 = Office.create(:name => 'testoffice2', :company_id => @company.id)
   # @boss = FactoryGirl.create(:boss, :company_id => @company.id)
   # @manager1 = FactoryGirl.create(:manager, :office_id => @office1.id, :company_id => @company.id)
   # @manager2 = FactoryGirl.create(:manager, :office_id => @office2.id, :company_id => @company.id)
   # @accountant = FactoryGirl.create(:accountant, :company_id => @company.id)
    #Tourist.where(created_at: (Time.now.midnight - 2.month)..Time.now.midnight).limit(10).each do |tourist|
    #  tourist.first_name = Faker::Name.name
    #set_company(@company)
    #end
    #address_attrs('Company', @company.id, @company.id)

  end

  def rand_obj(obj1, obj2)
    if rand(2) == 0
        obj1
      else
        obj2
      end
  end

  def dropdown_get(company, list)
    DropdownValue.where(company_id: @company.id, list: list).all.map(&:value)
  end

  def dropdown_create(company, list, value)
    dropdown = DropdownValue.new(list: list, value: value)
    dropdown.company = company
    #dropdown.save
    #puts dropdown.attributes
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