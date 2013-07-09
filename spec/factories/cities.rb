# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :city do
    association :company
    # company { [ FactoryGirl.create(:company) ] }
    name { Faker::Lorem.sentence }
    common false

    factory :open_city do
      common true
      company nil
    end
  end

  factory :resort, :class => City do
    name { Faker::Lorem.sentence }
  end
end
