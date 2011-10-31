require File.dirname(__FILE__) + '/../spec_helper'

describe TouristClaim do
  it "should be valid" do
    TouristClaim.new.should be_valid
  end
end
