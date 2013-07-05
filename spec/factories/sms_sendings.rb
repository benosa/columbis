# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sms_sending do
    company_id 1
    send_an "2013-07-05 11:24:53"
    signature "MyString"
    contact_group_id 1
    content "MyString"
    count 1
    status_id 1
    sending_priority false
    user_id 1
    delivered_count 1
  end
end
