# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :payment do
    association :claim, factory: :claim
    association :company

    currency 'rur'
  end

  factory :clientbase_payment, parent: :payment do
      association :payer, factory: :random_tourist
      form 'nal'
      payer_type 'Tourist'
      recipient_type 'Company'
      approved true
      canceled false
      amount 10000

      before(:create) do |payment|
        payment.payer = FactoryGirl.create(:random_tourist, :company => payment.company)
      end
    end
end
