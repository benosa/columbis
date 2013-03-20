# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Company do
  it "has a valid factory" do
    FactoryGirl.create(:company).should be_valid
  end

  describe ".associtiations" do
    it { should have_many :payments_in }
    it { should have_many :payments_out }
    it { should have_many :users }
    it { should have_many :offices }
    it { should have_many :tourists }
    it { should have_many :operators }
    it { should have_many :dropdown_values }
    it { should have_many :city_companies }
    it { should have_many :cities }
    it { should have_many :countries }
    it { should have_many :printers }
    it { should have_one :address }
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :company }
      it { should validate_presence_of :name }
    end
    context "when invalid" do
      subject { FactoryGirl.build(:company) }
      it { should_not allow_value(nil).for(:name) }
    end
  end
end
