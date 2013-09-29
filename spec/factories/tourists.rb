# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :tourist do
    company
    address { factory_assoc :address, company: company }

    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    middle_name Faker::Name.first_name
    # full_name { "#{last_name} #{first_name} #{middle_name}".strip }
    #address 'Dachniy prospekt'
    phone_number
    passport_series Faker::Number.number(2)
    passport_number Faker::Number.number(6)
    passport_valid_until { 1.year.since }
    date_of_birth { 30.years.ago }
    email

    factory(:applicant, :class => Tourist) {}
  end
end