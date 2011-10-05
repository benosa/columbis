FactoryGirl.define do
  factory :user do
    login 'smirnov'
    email 'serega@rambler.ru'
    last_name 'smirnov'
    first_name 'sergey'
    middle_name 'alekseevich'
    role 'admin'
  end
end
