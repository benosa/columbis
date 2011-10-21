FactoryGirl.define do
  factory :currency_course do
    on_date Time.now
    course '12.03'
    currency 'rur'
    association :user
  end
end
