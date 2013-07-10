# -*- encoding : utf-8 -*-
require 'spec_helper'

describe City do
  it "has a valid factory" do
    FactoryGirl.create(:city).should be_valid
    FactoryGirl.create(:open_city).should be_valid
  end

  describe ".associtiations" do
    it { should have_many :city_companies }
    it { should belong_to :country }
    it { should belong_to :company }
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :city }
      it { should validate_presence_of :name }

    end
    context "when invalid" do
      subject { FactoryGirl.build(:city) }
      it { should_not allow_value(nil).for(:name) }
    end
  end
end