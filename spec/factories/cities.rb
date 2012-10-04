# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :city do
    name 'Москва'
  end

  factory :resort, :class => City do
    name 'Хургада'
  end
end
