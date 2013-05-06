# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :city do
    association :company
    # company { [ FactoryGirl.create(:company) ] }
    name { Faker::Lorem.sentence }
  end

  factory :resort, :class => City do
    name { Faker::Lorem.sentence }
  end
end
