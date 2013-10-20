# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_payment do
    amount "9.99"
    currency "MyString"
    invoice 1
    period "MyString"
    description "MyString"
    approved false
    company_id 1
    user_id 1
    tariff_id 1
  end
end
