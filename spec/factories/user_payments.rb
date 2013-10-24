# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_payment do
    company
    user { factory_assoc :admin, company: company }

    amount "9.99"
    currency "rur"
    period nil
    description "MyString"
    tariff_id nil
    status 'new'

    factory :fail_user_payment do
      status 'fail'
    end

    factory :success_user_payment do
      status 'success'
    end

    factory :approved_user_payment do
      status 'approved'
    end

    factory :user_payment_with_tariff do
      association :tariff, factory: :tariff_plan
      period 1
    end
  end
end
