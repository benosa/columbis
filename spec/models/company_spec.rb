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
    it { should have_many :user_payments }
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

  describe ".counters" do
    before do
      @company = create(:company)
    end
     context "when locked" do
      it do
        @office = create(:office, company: @company)
        @user = create(:manager, company: @company, office: @office)
        @tourist = create(:tourist, company: @company)
        @task = create(:task, company: @company)
        @claim = create(:claim, company: @company, user: @user, office: @office, applicant: @tourist)
        @company.reload
        @company.users_count.should == 1
        @company.tourists_count.should == 1
        @company.tasks_count.should == 1
        @company.offices_count.should == 1
        @company.claims_count.should == 1
        @claim.destroy
        @task.destroy
        @tourist.destroy
        @user.destroy
        @office.destroy
        @company.reload
        @company.claims_count.should == 0
        @company.users_count.should == 0
        @company.tourists_count.should == 0
        @company.tasks_count.should == 0
        @company.offices_count.should == 0
      end
    end
  end

  describe "tariff end mails" do
    include EmailSpec::Helpers
    include EmailSpec::Matchers
    before do
      @company = create(:company, tariff_end: Time.zone.now)
      @company.owner = create(:user)
      @company.save
      @company2 = create(:company, tariff_end: Time.zone.now + CONFIG[:days_before_tariff_end].days)
      @company2.owner = create(:user)
      @company2.save
    end
    context "when tariff end" do
       it do
        Company.just_become_inactive.mail_tariff_end
        last_user_email = open_last_email_for(@company.owner.email)
        last_user_email.should have_body_text(/#{@company.name}/)
      end
    end

    context "when tariff end soon" do
       it do
        Company.just_soon_become_inactive.mail_tariff_end_soon
        last_user_email = open_last_email_for(@company2.owner.email)
        last_user_email.should have_body_text(/#{@company2.name}/)
      end
    end
  end

end
