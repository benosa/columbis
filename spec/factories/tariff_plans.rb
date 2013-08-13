# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tariff_plan do
    price 1
    name { Faker::Name.name }
    active false
    users_count 1
    place_size { Faker::Name.name }
    back_office false
    documents_flow false
    claims_base false
    crm_system false
    managers_reminder false
    analytics false
    boss_desktop false
    sms_sending false
    currency 'rur'
  end
end
