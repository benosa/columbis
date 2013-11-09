require 'spec_helper'

describe Visitor do
  it "has a valid factory" do
    FactoryGirl.create(:visitor).should be_valid
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :visitor }
      it { should validate_presence_of :email }
      it { should validate_presence_of :phone }
      it { should validate_presence_of :name }
    end
    context "when invalid" do
      subject do
        @visitor = FactoryGirl.build(:visitor)
        @visitor
      end
      it { should_not allow_value(nil).for(:email) }
      it { should_not allow_value(nil).for(:name) }
      it { should_not allow_value(nil).for(:phone) }
      it { should_not allow_value('123').for(:phone) }
    end
  end

  describe "confirmation" do
    before do
      @visitor = create(:visitor, attributes_for(:visitor))
    end
    context "when not confirmed" do
      it do
      	@visitor.confirmation_token.should_not == nil
      	@visitor.confirmed?.should == false
        @visitor.confirm
        @visitor.confirmed?.should == true
      end
    end
  end
end
