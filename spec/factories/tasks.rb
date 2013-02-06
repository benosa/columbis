# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :task do
    user { association :admin }
    body 'Task test'
    executer { association :admin }
    status 'new'
    comment { Faker::Lorem.sentence }
  end
end