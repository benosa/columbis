# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Country do
  it "has a valid factory" do
    FactoryGirl.create(:country).should be_valid
    FactoryGirl.create(:open_country).should be_valid
  end

  describe ".associtiations" do
    it { should have_many :regions }
    it { should have_many :cities }
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :country }
      it { should validate_presence_of :name }

    end
    context "when invalid" do
      subject { FactoryGirl.build(:country) }
      it { should_not allow_value(nil).for(:name) }
    end
  end
end