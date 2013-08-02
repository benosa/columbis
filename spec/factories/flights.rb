# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :flight do
    airline ""
    airport_from ""
    airport_to ""
    flight_number ""
    depart "2013-07-26 17:40:23"
    arrive "2013-07-26 17:40:23"
  end
end
