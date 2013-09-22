# -*- encoding : utf-8 -*-
FactoryGirl.define do
  sequence(:subdomain) { |n| "subdomain#{n}" }

  factory :company do
    name Faker::Lorem.sentence
    email Faker::Internet.email
    subdomain
    # subdomain do
    #   options = Company.validators_on(:subdomain).select{|v| v.instance_of? ActiveModel::Validations::LengthValidator }.first.try(:options) || {}
    #   minmax = options[:minimun] || 3..options[:maximum] || 20
    #   subdomain = Faker::Internet.domain_word until minmax.cover?(subdomain.to_s.length)
    #   subdomain
    # end
  end
end
