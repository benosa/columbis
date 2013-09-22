# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :office do
    association :company
    name { Faker::Name.name }
    default_password '123456'
  end

  factory :alien_office, :class => Office do
    association :company
    name { Faker::Name.name }
  end
end
