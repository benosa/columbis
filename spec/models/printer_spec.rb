# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Printer do
  it "has a valid factory" do
    FactoryGirl.create(:act).should be_valid
    FactoryGirl.create(:permit).should be_valid
    FactoryGirl.create(:memo).should be_valid
    FactoryGirl.create(:warranty).should be_valid
    FactoryGirl.create(:contract).should be_valid
  end

  describe ".associtiations" do
    it { should belong_to :company }
    it { should belong_to :country }
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :memo }
      it { should validate_presence_of :country_id }
    end
  end
end
