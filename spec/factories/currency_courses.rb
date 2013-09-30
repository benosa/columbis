# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :currency_course do
    company
    user { factory_assoc :admin, company: company }
    on_date Time.zone.now
    course 35.5486
    currency 'eur'
  end
end
