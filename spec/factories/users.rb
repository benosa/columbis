FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@factory.com"
  end

  factory :admin, :class => User do
    login 'ivanov'
    email { Factory.next(:email) }
    last_name 'Иванов'
    first_name 'Иван'
    middle_name 'Иванович'
    role 'admin'
    password 'secret'
    password_confirmation 'secret'
  end

  factory :manager, :class => User do
    login 'smirnov'
    email { Factory.next(:email) }
    last_name 'Смирнов'
    first_name 'Сергей'
    middle_name 'Алексеевич'
    role 'manager'
    password 'secret'
    password_confirmation 'secret'
  end

  factory :accountant, :class => User do
    login 'petrova'
    email { Factory.next(:email) }
    last_name 'Петрова'
    first_name 'Мария'
    middle_name 'Ивановна'
    role 'accountant'
    password 'secret'
    password_confirmation 'secret'
  end
end
