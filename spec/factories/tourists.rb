FactoryGirl.define do
  factory :tourist do
    first_name 'Ivan'
    last_name  'Ivanov'
    middle_name 'Sergeevich'
    address 'Dachniy prospekt'
    phone_number '89211231213'
    passport_series '1234'
    passport_number '145623'
    passport_valid_until '20.10.11'
    date_of_birth '12.12.12'
  end
end
