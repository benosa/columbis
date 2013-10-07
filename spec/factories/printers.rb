# -*- encoding : utf-8 -*-
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :printer do
    association :company

    factory :act do
      mode 'act'
      template { fixture_file_upload(Rails.root.join('app', 'views', 'printers', 'default_forms',
        'ru', 'act.html'), "text/html") }
    end

    factory :permit do
      mode 'permit'
      template { fixture_file_upload(Rails.root.join('app', 'views', 'printers', 'default_forms',
        'ru', 'permit.html'), "text/html") }
    end

    factory :memo do
      mode 'memo'
      association :country
      template { fixture_file_upload(Rails.root.join('app', 'views', 'printers', 'default_forms',
        'ru', 'memo.html'), "text/html") }
    end

    factory :warranty do
      mode 'warranty'
      template { fixture_file_upload(Rails.root.join('app', 'views', 'printers', 'default_forms',
        'ru', 'warranty.html'), "text/html") }
    end

    factory :contract do
      mode 'contract'
      template { fixture_file_upload(Rails.root.join('app', 'views', 'printers', 'default_forms',
        'ru', 'contract.html'), "text/html") }
    end
  end
end
