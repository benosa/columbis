# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Boss::ReportsController do

  before(:all) do
    @company = FactoryGirl.create(:company)
    @admin = FactoryGirl.create(:admin, :company => @company)
    @boss = FactoryGirl.create(:boss, :company => @admin.company, :office => @admin.office)
    @accountant = FactoryGirl.create(:accountant, :company => @admin.company, :office => @admin.office)
    @supervisor = FactoryGirl.create(:supervisor, :company => @admin.company, :office => @admin.office)
    @manager = FactoryGirl.create(:manager, :company => @admin.company, :office => @admin.office)
  end

  let(:user) { @admin }

  before do
    test_sign_in(user)
  end

  describe "client base report" do
    before(:all) do
      create_claims_with_prerequisites(@company, :clientbase_claim, 5)
      #@claims = create_list(:claim, 20, company: @company, office: @admin.office)
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

  describe "users availability" do
    def actions
      [ :operators, :directions, :tourprice, :repurchase, :income, :offices_income,
        :managers_income, :margin, :offices_margin, :managers_margin, :tourduration, :hotelstars,
        :clientsbase, :normalcheck, :increaseclients, :promotionchannel, :salesfunnel
      ]
    end
    context "when admin" do
      it do
        actions.each do |action|
          get action
          should respond_with :success
        end
      end
    end
    context "when boss" do
      let(:user) { @boss }
      it do
        actions.each do |action|
          get action
          should respond_with :success
        end
      end
    end
    context "when accountant" do
      let(:user) { @accountant }
      it do
        actions.each do |action|
          get action
          should_not respond_with :success
        end
      end
    end
    context "when supervisor" do
      let(:user) { @supervisor }
      it do
        actions.each do |action|
          get action
          should_not respond_with :success
        end
      end
    end
    context "when manager" do
      let(:user) { @manager }
      it do
        actions.each do |action|
          get action
          should_not respond_with :success
        end
      end
    end
  end
end

