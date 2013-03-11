# -*- encoding : utf-8 -*-
FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@factory.com"
  end

  sequence :login do |n|
    "login#{n}"
  end

  factory :admin, :class => User do
    association :company
    association :office

    email { Faker::Internet.email }
    login { Faker::Name.name }
    last_name 'Иванов'
    first_name 'Иван'
    middle_name 'Иванович'
    role 'admin'
    password 'secret'
    password_confirmation 'secret'
    delta false
  end

  factory :boss, :class => User do
    association :company
    association :office

    email { Faker::Internet.email }
    login { Faker::Name.name }
    last_name { Faker::Name.name }
    first_name { Faker::Name.name }
    middle_name { Faker::Name.name }
    role 'boss'
    password 'secret'
    password_confirmation 'secret'
  end

  factory :alien_boss, :class => User do
    association :company
    association :office

    email { Faker::Internet.email }
    login { Faker::Name.name }
    last_name 'Чужой'
    first_name 'Чужак'
    middle_name 'Чужакович'
    role 'boss'
    password 'secret'
    password_confirmation 'secret'
  end

  factory :manager, :class => User do
    association :company
    association :office

    email { Faker::Internet.email }
    login { Faker::Name.name }
    last_name { Faker::Name.name }
    first_name { Faker::Name.name }
    middle_name { Faker::Name.name }
    role 'manager'
    password 'secret'
    password_confirmation 'secret'
  end

  factory :accountant, :class => User do
    association :company
    association :office

    email { Faker::Internet.email }
    login { Faker::Name.name }
    last_name 'Петрова'
    first_name 'Мария'
    middle_name 'Ивановна'
    role 'accountant'
    password 'secret'
    password_confirmation 'secret'
  end
end
