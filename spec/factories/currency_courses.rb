# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :currency_course do
    on_date Time.zone.now
    course 35.5486
    currency 'eur'
    association :user
    association :company
  end
end
