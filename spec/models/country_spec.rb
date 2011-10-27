require File.dirname(__FILE__) + '/../spec_helper'

describe Country do
  it "should be valid" do
    Country.new.should be_valid
  end
end
