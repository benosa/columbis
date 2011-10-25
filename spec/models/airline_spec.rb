require File.dirname(__FILE__) + '/../spec_helper'

describe Airline do
  it "should be valid" do
    Airline.new.should be_valid
  end
end
