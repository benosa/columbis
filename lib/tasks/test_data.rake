namespace :test_data do
  desc "copy and fake data"
  task :step1 => :environment do
    @res_comp_id = 8
    #Faker::Config.locale = :en
    @company = Company.create(name: 'testcompany', email: Faker::Internet.email,
      oficial_letter_signature: 'bye', subdomain: Faker::Lorem.sentence)

    @office1 = Office.new(name: Faker::Lorem.sentence)
    @office2 = Office.new(name: Faker::Lorem.sentence)
    @office1.company = @company
    @office2.company = @company
    #@office1.save
    #@office2.save
    @boss = User.new(first_name: Faker::Name.male_first_name, last_name: Faker::Name.male_last_name,
      login: 'demo', password: '123456', role: 'boss', email: Faker::Internet.email)
    @boss.company = @company
    #@boss.save

    @manager1 = User.new(first_name: Faker::Name.female_first_name, last_name: Faker::Name.female_last_name,
      login: 'demoman1', password: '123456', role: 'manager', email: Faker::Internet.email)
    @manager1.company = @company
    #@manager1.save
    @manager2 = User.new(first_name: Faker::Name.male_first_name, last_name: Faker::Name.male_last_name,
      login: 'demoman2', password: '123456', role: 'manager', email: Faker::Internet.email)
    @manager2.company = @company
    #@manager2.save

    @accountant = User.new(first_name: Faker::Name.female_first_name, last_name: Faker::Name.female_last_name,
      login: 'accountant', password: '123456', role: 'manager', email: Faker::Internet.email)
    @accountant.company = @company
    #@accountant.save

    Tourist.where(company_id: @res_comp_id).unscoped.order("id DESC").limit(60).each do |tourist|
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

    50.times do |i|
      operator = Operator.new(name: Faker::Name.operator_name)
      operator.company = @company
      #operator.save
    end

    address = @company.create_address(address_attrs(@company.id))

    Tourist.where(company_id: @company.id).each do |tourist|
      address = tourist.create_address(address_attrs(@company.id))
    end

    Operator.where(company_id: @company.id).each do |operator|
      address = operator.create_address(address_attrs(@company.id))
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
  def address_attrs (company_id)
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