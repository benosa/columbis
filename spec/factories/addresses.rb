FactoryGirl.define do
  factory :address do
    region 'kyrovscky'
    zip_code '123'
    house_number '22'
    housing '2'
    office_number '111'
    street 'steet'
    phone_number '1232323'
    #after_create {|a| Factory(:company, :addressable => a)}
    association :company
  end
end
