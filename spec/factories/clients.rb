# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :client do
    association :company
    first_name 'Sergey'
    last_name  'Smirnov'
    middle_name 'Ivanovich'
    address 'Prospekt Veteranov'
    phone_number '89211231212'
    passport_series '1234'
    passport_number '145623'
    passport_valid_until '20.10.11'
    date_of_birth '12.12.12'
  end
end
