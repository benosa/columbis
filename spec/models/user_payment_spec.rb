# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserPayment do
  it "has a valid factory" do
    FactoryGirl.create(:user_payment).should be_valid
    FactoryGirl.create(:fail_user_payment).should be_valid
    FactoryGirl.create(:success_user_payment).should be_valid
    FactoryGirl.create(:approved_user_payment).should be_valid
    FactoryGirl.create(:user_payment_with_tariff).should be_valid
  end

  describe ".associtiations" do
    it { should belong_to :company }
    it { should belong_to :user }
    it { should belong_to :tariff }
  end

  describe ".validations" do
    let(:payment) { FactoryGirl.create :user_payment }
    subject { payment }

    context "when valid" do
      it { should validate_presence_of :amount }
      it { should validate_presence_of :currency }
      it { should validate_presence_of :description }
      it { should validate_presence_of :company_id }
      it { should validate_presence_of :user_id }
      it { should validate_uniqueness_of :invoice }
      it do
        CurrencyCourse::CURRENCIES.each do |currency|
          should allow_value(currency).for :currency
        end
      end
      it do
        UserPayment::STATUSES.each do |status|
          should allow_value(status).for :status
        end
      end
    end

    context "when invalid" do
      it { should_not allow_value(nil).for :amount }
      it { should_not allow_value(nil).for :currency }
      it { should_not allow_value(nil).for :description }
      it { should_not allow_value(nil).for :company_id }
      it { should_not allow_value(nil).for :user_id }
      it { should_not allow_value('nil').for :currency }
      it { should_not allow_value('nil').for :status }
    end
  end
end
