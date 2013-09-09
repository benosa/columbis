namespace :test_data do
  desc "copy and fake data"
  task :step1 => :environment do
    #Faker::Config.locale = :en
    @company = Company.create(name: 'testcompany', email: Faker::Internet.email,
      oficial_letter_signature: 'bye', subdomain: Faker::Lorem.sentence)
    @office1 = Office.new(name: Faker::Lorem.sentence)
    @office2 = Office.new(name: Faker::Lorem.sentence)
    @office1.company = @company
    @office2.company = @company
    @office1.save
    @office2.save
    @boss = User

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
    puts @company.id
    #end
  end
end