# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :item_field do
    name 'surname'
    association :catalog
    association :company
  end
end

FactoryGirl.define do
  factory :item_field_one, :parent => :item_field do
    name 'surname'
  end
end

FactoryGirl.define do
  factory :item_field_two, :parent => :item_field do
    name 'name'
  end
end
