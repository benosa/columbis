# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :payment do
    association :claim, factory: :claim
    association :company

    currency 'rur'
  end

  factory :clientbase_payment, parent: :payment do
      association :payer, factory: :tourist
      form 'nal'
      payer_type 'Tourist'
      recipient_type 'Company'
      approved true
      canceled false
      amount 10000
    end
end
