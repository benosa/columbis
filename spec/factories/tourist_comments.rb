# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tourist_comment, :class => 'TouristComments' do
    user_id 1
    tourist_id 1
    body "MyText"
  end
end
