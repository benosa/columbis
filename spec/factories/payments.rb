# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :payment do
    company
    claim { factory_assoc :claim, company: company }

    currency 'rur'
  end

  factory :clientbase_payment, parent: :payment do
    payer { factory_assoc :tourist, company: company }

    form 'nal'
    payer_type 'Tourist'
    recipient_type 'Company'
    approved true
    canceled false
    amount 10000

    before(:create) do |payment|
      payment.payer = FactoryGirl.create(:tourist, :company => payment.company)
    end
  end
end
