# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'digest/md5'

describe RobokassaController do
  include ActiveMerchant::Billing::Integrations

  before(:all) do
    @boss = FactoryGirl.create(:boss)
    @company = @boss.company
    @payment = FactoryGirl.create(:user_payment, :company => @company, :user => @boss)
    @payment = UserPayment.find(@payment.id)
  end

  before do
    test_sign_in(@boss)
  end

  describe "paid action" do

    context "POST paid without secret key" do
      before { post :paid }
      it "should render bad message" do
        UserPayment.find(@payment.id).status.should_not == "approved"
        response.body.should == I18n.t('.user_payments.messages.robokassa_bad_key')
      end
    end

    context "POST paid with valid params" do
      before do
        post(:paid, :OutSum => @payment.amount, :InvId => @payment.invoice,
          :SignatureValue => Digest::MD5.hexdigest("#{@payment.amount}:#{@payment.invoice}:" +
          CONFIG[:robokassa_password2]).to_s)
      end
      it "should render ok message" do
        UserPayment.find(@payment.id).status.should == "approved"
        response.body.should == "OK#{@payment.invoice}"
      end
    end

    context "POST paid with invalid invoice" do
      before do
        post :paid, :OutSum => @payment.amount, :InvId => 123,
          :SignatureValue => Digest::MD5.hexdigest("#{@payment.amount}:#{123}:" +
          CONFIG[:robokassa_password2]).to_s
      end
      it "should render fail message" do
        UserPayment.find(@payment.id).status.should_not == "approved"
        response.body.should == I18n.t('.user_payments.messages.robokassa_bad_paid')
      end
    end

  end

  describe "success action" do
    context "POST success with invalid params" do
      before { get :success }
      it "should not be success message and redirect to edit company" do
        UserPayment.find(@payment.id).status.should_not == "success"
        response.should redirect_to user_payments_path
        flash[:alert].should eql(I18n.t('.user_payments.messages.robokassa_success_bad_key'))
      end
    end

    context "POST success with valid params" do
      before do
        get :success, :OutSum => @payment.amount, :InvId => @payment.invoice,
          :SignatureValue => Digest::MD5.hexdigest("#{@payment.amount}:#{@payment.invoice}:" +
          CONFIG[:robokassa_password1]).to_s
      end
      it "should be success message and redirect to edit company" do
        UserPayment.find(@payment.id).status.should == "success"
        response.should redirect_to user_payments_path
        flash[:notice].should eql(I18n.t('.user_payments.messages.robokassa_success'))
      end
    end

    context "POST success with invalid invoice" do
      before do
        get :success, :OutSum => @payment.amount, :InvId => 123,
          :SignatureValue => Digest::MD5.hexdigest("#{@payment.amount}:#{123}:" +
          CONFIG[:robokassa_password1]).to_s
      end
      it "should be success message and redirect to edit company" do
        UserPayment.find(@payment.id).status.should_not == "success"
        response.should redirect_to user_payments_path
        flash[:alert].should eql(I18n.t('.user_payments.messages.robokassa_bad_success'))
      end
    end
  end

  describe "fail action" do
    context "POST with invalid params" do
      before { get :fail }
      it "should not be fail message and redirect to edit company" do
        UserPayment.find(@payment.id).status.should_not == "fail"
        response.should redirect_to user_payments_path
        flash[:alert].should eql(I18n.t('.user_payments.messages.robokassa_fail_bad_id'))
      end
    end

    context "POST with valid params" do
      before do
        get :fail, :OutSum => @payment.amount, :InvId => @payment.invoice
      end
      it "should be success message and redirect to edit company" do
        UserPayment.find(@payment.id).status.should == "fail"
        response.should redirect_to user_payments_path
        flash[:notice].should eql(I18n.t('.user_payments.messages.robokassa_fail'))
      end
    end

    context "POST with invalid invoice" do
      before do
        get :fail, :OutSum => @payment.amount, :InvId => 123
      end

      it "should not be success message and redirect to edit company" do
        UserPayment.find(@payment.id).status.should_not == "fail"
        response.should redirect_to user_payments_path
        flash[:alert].should eql(I18n.t('.user_payments.messages.robokassa_bad_fail'))
      end
    end
  end
end