# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :office do
    association :company
    name 'office'
    default_password '123456'
  end

  factory :alien_office, :class => Office do
    association :company
    name 'alien_office'
  end
end
