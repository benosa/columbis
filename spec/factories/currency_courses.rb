FactoryGirl.define do
  factory :currency_course do
    on_date Time.now
    course 35.5486
    currency 'rur'
    association :user
  end
end
