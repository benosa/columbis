# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Operator do
  it "has a valid factory" do
    FactoryGirl.create(:operator).should be_valid
  end

  describe ".associtiations" do
    it { should belong_to :company }
    it { should have_many :claims }
    it { should have_many :payments }
    it { should have_one :address }
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :operator }
      it { should validate_presence_of :name }
    end
    context "when invalid" do
      subject { FactoryGirl.build(:operator) }
      it { should_not allow_value(nil).for(:name) }
    end
  end
end
