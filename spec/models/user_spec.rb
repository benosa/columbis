# -*- encoding : utf-8 -*-
require 'spec_helper'

describe User do
  it "has a valid factory" do
    FactoryGirl.create(:admin).should be_valid
    FactoryGirl.create(:boss).should be_valid
    FactoryGirl.create(:manager).should be_valid
    FactoryGirl.create(:alien_boss).should be_valid
    FactoryGirl.create(:accountant).should be_valid
  end

  describe ".associtiations" do
    it { should belong_to :company }
    it { should belong_to :office }
    it { should have_many :tasks }
  end

  describe ".validations" do
    context "when valid" do
      subject { FactoryGirl.create :boss }
      it { should validate_presence_of :login }
      it { should validate_presence_of :role }
      it { should validate_presence_of :last_name }
      it { should validate_presence_of :first_name }
      it { should validate_presence_of :phone }
    end
    context "when invalid" do
      subject { FactoryGirl.build(:boss) }
      it { should_not allow_value(nil).for(:last_name) }
      it { should_not allow_value(nil).for(:first_name) }
      it { should_not allow_value(nil).for(:phone) }
      it { should_not allow_value('123').for(:phone) }
      it { should_not allow_value('123').for(:password) }
    end
  end

  describe ".registration" do
    context "when registered" do
      before do
        @user = FactoryGirl.create :user
      end
      it { @user.login.should == (Russian.transliterate(@user.first_name)[0] + Russian.transliterate(@user.last_name)).downcase }
    end

    context "when not registered" do
      before do
        @user = FactoryGirl.create(:user, email: 'test@test.ru', first_name: 'lol', last_name: 'ogin', phone: '77777777')
        @user2 = FactoryGirl.build(:user, first_name: 'lol', last_name: 'ogin', phone: '77777777')
      end
      it { @user.login.should == 'login' }
      it { @user2.should_not allow_value('test@test.ru').for(:email) }
      it { @user2.should_not allow_value('77777777').for(:phone) }
      it do
        @user2.send(:generate_login)
        @user2.login.should == 'login1'
      end
    end
  end
end
