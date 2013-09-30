# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :country do
    company
    name { Faker::Address.country }
    common false

    factory :open_country do
      company nil
      common true
    end
  end
end
