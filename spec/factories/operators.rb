# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :operator do
    company
    address { factory_assoc :address, company: company }

    name { Faker::Lorem.sentence }
    common false
    register_number { Faker::Number.number(6) }
    register_series { Faker::Lorem.characters(3) }
    inn { Faker::Number.number(10) }

    factory :common_operator do
      company nil
      common true
    end

    factory :operator_with_claims do
      ignore { claim_count 2 }
      after(:create) do |operator, evaluator|
        FactoryGirl.create_list(:claim, evaluator.claim_count, operator: operator)
      end
    end
  end
end
