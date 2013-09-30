# -*- encoding : utf-8 -*-
FactoryGirl.define do
  sequence(:country_name) { |n| "Country#{n}" }

  factory :country do
    company
    name { generate :country_name }
    common false

    factory :open_country do
      company nil
      common true
    end
  end
end
