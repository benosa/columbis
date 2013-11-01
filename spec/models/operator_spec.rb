# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Operator do
  it "has a valid factory" do
    FactoryGirl.create(:operator).should be_valid
    FactoryGirl.create(:common_operator).should be_valid
    FactoryGirl.create(:operator_with_claims).should be_valid
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

  describe ".synchronization with common operator" do
    let(:operator) { FactoryGirl.create :operator }
    let(:common_operator) do
      FactoryGirl.create :common_operator, register_number: operator.register_number, register_series: operator.register_series
    end
    before do
      common_operator
      operator.check_and_load_common_operator!
    end
    it "common_operator attribute should be present and equal to persisted" do
      operator.common_operator.should == common_operator
    end
    it "operator should not be synchronized with common operator" do
      operator.inn = Faker::Number.number(9)
      operator.synced_with_common_operator?.should be_false
    end
    it "operator should be synchronized with common operator" do
      operator.inn = Faker::Number.number(9)
      operator.sync_with_common_operator!
      operator.synced_with_common_operator?.should be_true
    end
  end
end
