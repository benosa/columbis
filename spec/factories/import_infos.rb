# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :import_info do
    company_id 1
    num "MyString"
    integer "MyString"
    load_date "2014-01-13 16:33:38"
    filename "MyString"
    success_count 1
    count 1
  end
end
