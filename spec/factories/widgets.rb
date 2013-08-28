# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :widget, :class => Boss::Widget do
    association :company
    association :user
    name "claim"
    title "MyString"
    position 1
    view "small"
    settings {}
    widget_type "factor"
  end
end
