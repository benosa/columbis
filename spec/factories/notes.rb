# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :note do
    association :item
    association :item_field
    value 'hello'
  end
end
