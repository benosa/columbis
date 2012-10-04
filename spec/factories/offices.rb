# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :office do
    association :company
    name 'office'
  end

  factory :alien_office, :class => Office do
    association :company
    name 'alien_office'
  end
end
