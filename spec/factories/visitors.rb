# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :visitor do
  	email
  	name { Faker::Name.first_name }
   	phone
  end
end
