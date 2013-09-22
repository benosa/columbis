FactoryGirl.define do
  factory :dropdown_value do
  	association :company

    common false

  	list { DropdownValue.available_lists.first }
  	value { Faker::Lorem.sentence }

    factory :open_dropdown_value do
      common true
    end
  end
end