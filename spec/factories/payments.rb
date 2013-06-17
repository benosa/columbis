# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :payment do
    association :claim, factory: :claim
    association :company

    currency 'rur'
  end
end
