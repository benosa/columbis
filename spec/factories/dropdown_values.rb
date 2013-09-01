FactoryGirl.define do
  factory :dropdown_value do
  	association :company

  	list { DropdownValue.available_lists.first }
  	value { Faker::Lorem.sentence }
  end
end