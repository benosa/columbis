require File.dirname(__FILE__) + '/../spec_helper'

describe CurrencyCourse do
  it "should be valid" do
    CurrencyCourse.new.should be_valid
  end
end
