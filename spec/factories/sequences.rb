FactoryGirl.define do

  sequence(:subdomain) { |n| "subdomain#{n}" }
  sequence(:email) { |n| "email#{n}@factory.com" }
  sequence(:phone, 1000, aliases: [:phone_number]) { |n| "+71234#{n}" }
  sequence(:login) { |n| "login#{n}" }

end