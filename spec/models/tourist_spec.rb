# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Tourist do
  it "has a valid factory" do
    FactoryGirl.create(:tourist).should be_valid
  end

  describe ".associtiations" do
    it { should belong_to :company }
    it { should have_many :tourist_claims }
    it { should have_many :claims }
    it { should have_many :payments }
    it { should have_one :address }
  end

  describe ".validations" do
    def message_for(attribute)
      "#{Tourist.human_attribute_name(attribute)} #{I18n.t('activerecord.errors.messages.blank')}"
    end

    context "when valid" do
      subject { FactoryGirl.create :tourist }
      # it { should validate_presence_of(:first_name).with_message(message_for :first_name) }
      # it { should validate_presence_of(:last_name).with_message(message_for :last_name) }
      it { should validate_presence_of(:full_name).with_message(message_for :full_name) }
      it { should validate_presence_of :company_id }
    end

    context "when invalid" do
      subject { FactoryGirl.build(:tourist) }
      # it { should_not allow_value(nil).for(:first_name).with_message(message_for :first_name) }
      # it { should_not allow_value(nil).for(:last_name).with_message(message_for :first_name) }
      it { should_not allow_value(nil).for(:full_name) }
      it { should_not allow_value(nil).for(:company_id) }
    end
  end
end
