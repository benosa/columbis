# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :note do
    association :item
    association :item_field
    association :company
    value 'hello'
  end
end
