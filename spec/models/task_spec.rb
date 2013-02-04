require 'spec_helper'

describe Task do
  it "has a valid factory" do
    FactoryGirl.create(:task).should be_valid
  end

  describe ".associtiations" do
    it { should belong_to :user }
    it { should belong_to :executer }
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :task }
      it { should validate_presence_of :body }
    end
    context "when invalid" do
      subject { FactoryGirl.build(:task) }
      it { should_not allow_value(nil).for(:body) }
    end
  end
end
