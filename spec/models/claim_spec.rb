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

    it { should have_many :tourist_claims }
    it { should have_many :payments_in }
    it { should have_many :payments_out }


    it { should have_one :tourist_claim }
    it { should have_one :applicant }
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :claim }
      it { should validate_presence_of :user_id }
      it { should validate_presence_of :operator_id }
      it { should validate_presence_of :check_date }
      it { should validate_presence_of :arrival_date }

    end
    context "when invalid" do
      subject { FactoryGirl.build(:claim) }
      it { should_not allow_value(nil).for(:user_id) }
    end
  end
end