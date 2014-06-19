# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tourist_task do
    name "MyString"
    state "MyString"
    tourist_id 1
    user_id 1
  end
end
