# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :flight do
    airline "MyString"
    airport_from "MyString"
    airport_to "MyString"
    flight_number "MyString"
    depart "2013-07-26 17:40:23"
    arrive "2013-07-26 17:40:23"
  end
end
