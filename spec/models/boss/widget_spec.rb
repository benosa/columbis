require 'spec_helper'

describe Boss::Widget do
  it "has a valid factory" do
    FactoryGirl.create(:widget).should be_valid
  end
end