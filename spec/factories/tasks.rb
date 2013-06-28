# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :task do
    association :user, factory: :admin
    body { Faker::Lorem.sentence }
    bug true

    factory :new_task do
      status 'new'
    end

    factory :worked_task do
      association :executer, factory: :admin
      status 'work'
      start_date { Time.zone.now }

      factory :finished_task do
        status 'finish'
        comment { Faker::Lorem.sentence }
        end_date { Time.zone.now + 1.week }
      end

      factory :canceled_task do
        status 'cancel'
        comment { Faker::Lorem.sentence }
        end_date { Time.zone.now + 1.week }
      end
    end

    trait :not_bug do
      bug false
    end
  end
end