FactoryGirl.define do
  sequence :email do |n|
    'email#{n}@factory.com'
  end

  factory :user do
    login 'smirnov'
    email { Factory.next(:email) }
    last_name 'smirnov'
    first_name 'sergey'
    middle_name 'alekseevich'
    role 'admin'
    password 'secret'
    password_confirmation 'secret'
  end
end
