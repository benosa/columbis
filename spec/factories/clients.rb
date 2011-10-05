FactoryGirl.define do
  factory :client do
    first_name 'Sergey'
    last_name  'Smirnov'
    middle_name 'Ivanovich'
    address 'Prospekt Veteranov'
    phone_number '89211231212'
    passport_series '0000'
    passport_number '123123'
    passport_valid_until '00.00.00'
    date_of_birth '00.00.00'
  end
end
