# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_payment do
    company
    user { factory_assoc :boss, company: company }
    association :tariff, :factory => :tariff_plan

    amount "9.99"
    currency "rur"
    period 1
    description "MyString"
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
  end

  factory :default_user_payment, :class => "UserPayment" do
    company
    user { factory_assoc :boss, company: company }
  end
end
