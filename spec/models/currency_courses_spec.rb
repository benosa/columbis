require File.dirname(__FILE__) + '/../spec_helper'

describe CurrencyCourses do
  it "should be valid" do
    CurrencyCourses.new.should be_valid
  end
end
