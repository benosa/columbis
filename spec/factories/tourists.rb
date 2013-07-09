# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :tourist do
    association :address
    association :company
    first_name 'Ivan'
    last_name  'Ivanov'
    middle_name 'Sergeevich'
    #address 'Dachniy prospekt'
    phone_number '89211231213'
    passport_series '1234'
    passport_number '145623'
    passport_valid_until '20.10.11'
    date_of_birth '12.12.12'
    email 'ivan.ivanov@test.mail.com'
  end
  
  factory :applicant, :class => Tourist do
    association :company
    association :address
    first_name 'Походов'
    last_name  'Иван'
    middle_name 'Акакиевич'
    #address 'Ленина, 13'
    phone_number '8-921-1231213'
    passport_series '322'
    passport_number '195963'
    passport_valid_until '20.10.11'
    date_of_birth '12.12.12'
    email 'ivan.pohodov@test.mail.com'
  end
end
