# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Boss::ReportsController do
  include ActionView::Helpers

  before(:all) do
    @company = FactoryGirl.create(:company)
    @user = FactoryGirl.create(:admin, :company => @company)
  end

  before do
    test_sign_in(@user)
  end

  describe "client base report" do
    before(:all) do
      create_claims_with_prerequisites(@company, :clientbase_claim, 10)
    end

    it "should be exist count" do
      get :clientsbase
      assigns(:count).data.should_not be_nil
    end

    it "should be exist amount" do
      get :clientsbase
      assigns(:amount).data.should_not be_nil
    end

    it "should be exist total amounts" do
      get :clientsbase
      ( assigns(:amount80).blank? and
        assigns(:amount15).blank? and
        assigns(:amount5).blank?).should == false
    end
  end
end

