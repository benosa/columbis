require 'spec_helper'

describe 'confirmation' do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before do
    @user = FactoryGirl.create :user
  end

  subject { Mailer.confirmation_instructions(@user) }

  describe "Email should have" do
    it { should deliver_to @user.email }
    it { should have_body_text(/#{@user.first_name}/) }
    it { should have_body_text(/#{@user.last_name}/) }
    it { should have_body_text(/#{@user.login}/) }
    it { should have_body_text(/#{@user.password}/) }
    it { should have_body_text(/#{@user.confirmation_token}/) }
  end
end
