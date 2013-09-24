FactoryGirl.define do
  factory :dropdown_value do
  	association :company

    common false

  	list { DropdownValue.available_lists.first.to_a[0] }
  	value { Faker::Lorem.sentence }

    factory :open_dropdown_value do
      company nil
      common true
    end
  end
end