namespace :demo do
  desc "seed data for demo company"
  task :seed, [:thinking_sphinx] => :environment do |t, args|
    args.with_defaults restart_sphinx: true

    # Original values of configuration parameters
    origin_config_values = {
      deltas_enabled: ThinkingSphinx.deltas_enabled?,
      support_delivery: CONFIG[:support_delivery]
    }
    ThinkingSphinx.deltas_enabled = false # Suppress delta indexing of thinking sphinx
    CONFIG[:support_delivery] = false # Turn off email sendings

    @res_comp_id = 8 # Mistral company
    @demo_comp_id = 2 # Permanent Demo company id
    puts 'Start seeding demo data...'

    # Remove all data of demo company
    puts 'Removing current demo data...'
    # tourist_claims hasn't company_id column
    ActiveRecord::Base.connection.execute %Q(
      DELETE FROM tourist_claims USING claims
      WHERE tourist_claims.claim_id = claims.id AND claims.company_id=#{@demo_comp_id})
    ActiveRecord::Base.connection.tables.each do |table|
      if ActiveRecord::Base.connection.column_exists?(table, 'company_id')
        ActiveRecord::Base.connection.execute "DELETE FROM #{table} WHERE company_id=#{@demo_comp_id}"
      end
    end
    Company.find(@demo_comp_id).destroy rescue nil
    puts 'All current demo data is removed'

    # Create demo company
    @company = Company.new(name: 'demo', email: 'demo@columbis.ru', subdomain: 'demo')
    @company.id = @demo_comp_id
    @company.save(validate: false)
    puts 'Demo company is created'

    # Offices
    @office1 = Office.new(name: 'Главный')
    @office2 = Office.new(name: 'Южный')
    @office1.company = @company
    @office2.company = @company
    @office1.save
    @office2.save
    puts 'Offices are created'

    # Users
    @boss = create_user(@company, @office1, 'boss', 'demo', '123456')
    @boss.update_column :subdomain, 'demo'
    @company.update_column :owner_id, @boss.id
    @manager1 = create_user(@company, @office1, 'manager')
    @manager2 = create_user(@company, @office2, 'manager')
    @accountant = create_user(@company, @office1, 'accountant')
    puts 'Users are created'

    # Tourists
    Tourist.where(company_id: @res_comp_id).reorder("id DESC").limit(100).each do |tourist|
      if rand(2) == 0
        tourist.first_name = Faker::Name.female_first_name
        tourist.middle_name = Faker::Name.female_middle_name
        tourist.last_name = Faker::Name.female_last_name
      else
        tourist.first_name = Faker::Name.male_first_name
        tourist.middle_name = Faker::Name.male_middle_name
        tourist.last_name = Faker::Name.male_last_name
      end
      tourist.email = Faker::Internet.email
      tourist.phone_number = Faker::PhoneNumber.phone_number
      tourist.date_of_birth = rand(tourist.date_of_birth - 3.months .. tourist.date_of_birth + 3.months) if tourist.date_of_birth
      tourist.passport_series = Faker::Number.number(2)
      tourist.passport_number = Faker::Number.number(7)
      tourist_new = Tourist.new(tourist.attributes)
      tourist_new.company = @company
      tourist_new.save
    end
    puts 'Tourists are created'

    # Operators
    50.times do |i|
      operator = Operator.new(name: Faker::Name.operator_name)
      operator.company = @company
      operator.save
    end
    puts 'Operators are created'

    # Addresses
    @company.create_address(address_attrs(@company.id))

    Tourist.where(company_id: @company.id).each do |tourist|
      tourist.create_address(address_attrs(@company.id))
    end

    Operator.where(company_id: @company.id).each do |operator|
      operator.create_address(address_attrs(@company.id))
    end
    puts 'Addresses are created'

    # DropdownValues
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
    puts 'DropdownValues are created'

    # Claims with Flights and Payments
    puts 'Creating Claims with Flights and Payments...'
    Claim.where(company_id: @res_comp_id,
      created_at: (Time.now - 3.month)..(Time.now - 1.month)).
      where('arrival_date is not NULL and departure_date is not NULL').each do |claim|

      if rand(2) == 0
        manager = @manager2
        assistant = @manager1
      else
        manager = @manager1
        assistant = @manager2
      end

      claim_new = Claim.new(claim.attributes)
      add_date_delta claim_new, %w[check_date arrival_date departure_date reservation_date visa_check]
      claim_new.company = @company
      claim_new.operator = Operator.where(company_id: @company.id).reorder('RANDOM()').first
      claim_new.user = manager
      claim_new.assistant = assistant if claim.assistant.present?
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

      # dropdown_create(@company, 'airport', claim_new.city.name)
      # dropdown_create(@company, 'airport', claim_new.resort.name)
      arrive_time = random_time(claim_new.arrival_date)
      depart_time = random_time(claim_new.departure_date)
      claim_new.flights << Flight.new(claim_id: claim_new.id, depart: arrive_time, arrive: arrive_time + (rand(4) + 2).hour,
        airport_from: claim_new.city.name, airport_to: claim_new.resort.name, airline: claim_new.airline)
      claim_new.flights << Flight.new(claim_id: claim_new.id, depart: depart_time, arrive: depart_time + (rand(4) + 2).hour,
        airport_from: claim_new.resort.name, airport_to: claim_new.city.name, airline: claim_new.airline)

      Payment.where(claim_id: claim.id).each do |pay|
        pay_new = Payment.new(pay.attributes)
        add_date_delta pay_new, :date_in
        pay_new.claim = claim_new
        pay_new.company = @company
        pay_new.recipient_id = switch_pay_type(pay_new.recipient_type, @company, claim_new.applicant, claim_new.operator)
        pay_new.payer_id = switch_pay_type(pay_new.payer_type, @company, claim_new.applicant, claim_new.operator)
        pay_new.form = DropdownValue.where(common: true, list: 'form').reorder('RANDOM()').limit(1).pluck(:value)[0]
        # pay_new.save
        if pay_new.recipient_type == 'Company'
          claim_new.payments_in << pay_new
        else
          claim_new.payments_out << pay_new
        end
      end

      claim_new.save
    end
    puts 'Claim with Flights and Payments are created'
    puts 'Stop seeding demo data'

    ThinkingSphinx.deltas_enabled = origin_config_values[:deltas_enabled]
    CONFIG[:support_delivery] = origin_config_values[:support_delivery]

    # Execute thinking_sphinx tasks
    if args[:thinking_sphinx]
      puts "Start thinking_sphinx:#{args[:thinking_sphinx]}"
      Rake::Task["thinking_sphinx:#{args[:thinking_sphinx]}"].invoke
      puts "Stop thinking_sphinx:#{args[:thinking_sphinx]}"
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

  def create_user(company, office, role, login = nil, password = '123456')
    user = User.new(first_name: Faker::Name.male_first_name, last_name: Faker::Name.male_last_name,
      password: password, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, color: Faker::Name.color)
    user.login = login || (Russian::translit(user.first_name)[0].downcase + Russian::translit(user.last_name).downcase)
    user.company = company
    user.office = office
    user.role = role
    user.screen_width = 1600
    user.confirmed_at = Time.zone.now
    user.save(validate: false)
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

  def add_date_delta(object, attrs, delta = 1.month)
    attrs = [attrs] unless attrs.kind_of?(Array)
    attrs.each do |attr|
      date = object.send(:"#{attr}")
      object.send(:"#{attr}=", date + delta) if !date.nil? && date.respond_to?(:to_date)
    end
  end
end