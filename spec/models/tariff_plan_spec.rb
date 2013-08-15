require 'spec_helper'

describe TariffPlan do
  it "has a valid factory" do
    FactoryGirl.create(:tariff_plan).should be_valid
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :tariff_plan }
      it { should allow_value('rur').for(:currency) }
      it { should allow_value('eur').for(:currency) }
      it { should allow_value('usd').for(:currency) }
      it { should validate_presence_of :name }
      it { should validate_presence_of :place_size }
      it { should validate_presence_of :price }
      it { should validate_presence_of :users_count }
    end

    context "when invalid" do
      subject { FactoryGirl.build(:tariff_plan) }
      it { should_not allow_value(nil).for(:currency) }
      it { should_not allow_value('asd').for(:currency) }
      it { should_not allow_value(nil).for(:name) }
      it { should_not allow_value(nil).for(:place_size) }
      it { should_not allow_value(nil).for(:price) }
      it { should_not allow_value(nil).for(:users_count) }
    end
  end
end
