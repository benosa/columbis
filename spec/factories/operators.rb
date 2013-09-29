# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :operator do
    company
    address { factory_assoc :address, company: company }

    name { Faker::Lorem.sentence }

    factory :operator_with_claims do
      ignore { claim_count 2 }
      after(:create) do |operator, evaluator|
        FactoryGirl.create_list(:claim, evaluator.claim_count, operator: operator)
      end
    end
  end
end
