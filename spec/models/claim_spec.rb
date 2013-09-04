# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Claim do
  it "has a valid factory" do
    FactoryGirl.create(:claim).should be_valid
  end

  describe ".associtiations" do
    it { should belong_to :company }
    it { should belong_to :user }
    it { should belong_to :office }
    it { should belong_to :operator }
    it { should belong_to :country }
    it { should belong_to :city }
    it { should belong_to :editor }

    it { should have_many :tourist_claims }
    it { should have_many :payments_in }
    it { should have_many :payments_out }
    it { should have_many :flights }


    it { should have_one :tourist_claim }
    it { should have_one :applicant }
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :claim }
      it { should validate_presence_of :user_id }
      it { should validate_presence_of :check_date }
      it { should validate_presence_of :arrival_date }
      it { should validate_presence_of :num }
    end
    context "when invalid" do
      before do
        @company = FactoryGirl.create(:company)
        FactoryGirl.create(:claim, company: @company, num: 1)
      end
      subject { FactoryGirl.build(:claim, company: @company) }
      it { should_not allow_value(nil).for(:user_id) }
      it { should_not allow_value(0).for(:num) }
      it { should_not allow_value(1).for(:num) }
    end
  end

  describe ".generate_num" do
    before do
      @companies = FactoryGirl.create_list(:company, 2)
      @c1 = FactoryGirl.create(:claim, company: @companies[0], num: 1)
      @c2 = FactoryGirl.create(:claim, company: @companies[1], num: 2)
      @claim = FactoryGirl.build(:claim, company: @companies[0])
      @claim.generate_num
    end
    it { @claim.num.should == 2 }
  end

  describe ".locked" do
    before do
      @editor, @another_editor = create(:user), create(:user)
      @claim = FactoryGirl.create(:claim)
      @claim.lock(@editor)
    end

    context "when locked" do
      it do
        @claim.current_editor = @another_editor
        @claim.locked?.should == true
      end
    end
    context "when not locked" do
      it do
        @claim.unlock
        @claim.locked?.should == false
      end
      it do
        @claim.update_attribute(:locked_at, Time.zone.now - 31.minutes)
        @claim.locked?.should == false
      end
    end
  end
end