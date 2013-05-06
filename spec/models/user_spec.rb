# -*- encoding : utf-8 -*-
require 'spec_helper'

describe User do
  it "has a valid factory" do
    FactoryGirl.create(:admin).should be_valid
    FactoryGirl.create(:boss).should be_valid
    FactoryGirl.create(:manager).should be_valid
    FactoryGirl.create(:alien_boss).should be_valid
    FactoryGirl.create(:accountant).should be_valid
  end

  describe ".associtiations" do
    it { should belong_to :company }
    it { should belong_to :office }
    it { should have_many :tasks }
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :admin }
      it { should validate_presence_of :login }
      it { should validate_presence_of :role }
      it { should validate_presence_of :last_name }
      it { should validate_presence_of :first_name }
    end
    context "when invalid admin" do
      subject { FactoryGirl.build(:admin) }
      it { should_not allow_value(nil).for(:login) }
      it { should_not allow_value(nil).for(:last_name) }
      it { should_not allow_value(nil).for(:first_name) }
    end
  end
end
