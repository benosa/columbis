require 'spec_helper'

describe 'Mailer' do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  describe "if user create" do

    before do
      @user = FactoryGirl.create(:admin)
    end

    context "should create confirmation mail" do
      subject { Mailer.confirmation_instructions(@user) }
      it { should deliver_to @user.email }
      it { should have_body_text(/#{@user.first_name}/) }
      it { should have_body_text(/#{@user.last_name}/) }
      it { should have_body_text(/#{@user.login}/) }
      it { should have_body_text(/#{@user.password}/) }
      it { should have_body_text(/#{@user.confirmation_token}/) }
    end

    describe "when mail to support" do
      before(:all) do
        @config_support_delivery = CONFIG[:support_delivery]
        CONFIG[:support_delivery] = true
      end
      after(:all) { CONFIG[:support_delivery] = @config_support_delivery }

      context "should create mail to support about user" do
        subject { Mailer.user_was_created(@user) }
        it { should deliver_to CONFIG[:support_email] }
        it { should have_body_text(/#{@user.full_name || @user.login}/) }
      end

      context "should create mail to support about compay" do
        subject { Mailer.company_was_created(@user.company) }
        it { should deliver_to CONFIG[:support_email] }
        it { should have_body_text(/#{@user.company.try(:name)}/) }
      end
    end
  end
end
