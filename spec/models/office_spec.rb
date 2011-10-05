require File.dirname(__FILE__) + '/../spec_helper'

describe Office do
  it "should be valid" do
    Office.new.should be_valid
  end
end
