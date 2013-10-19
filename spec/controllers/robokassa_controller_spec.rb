# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'digest/md5'

describe RobokassaController do
  include ActiveMerchant::Billing::Integrations

  before(:all) do
    @admin = FactoryGirl.create(:admin)
    @company = @admin.company
  end

  before do
    test_sign_in(@admin)
    method
  end

  let(:method) { nil }

  context "GET paid with invalid params" do
    let(:method) { get :paid }

    it "should render bad message" do
      response.body.should == "Не верный вызов"
    end
  end

  context "GET paid with valid params" do
    let(:method) { get :paid, :OutSum => 10000, :InvId => 0,
      :SignatureValue => Digest::MD5.hexdigest(
        "10000:0:" + CONFIG[:robokassa_secret].to_s
      )
    }

    it "should render ok message" do
      response.body.should == "Выполнено действие"
    end
  end

  context "GET success" do
    let(:method) { get :success }

    it "should be success message and redirect to edit company" do
      response.should redirect_to edit_dashboard_company_path(@company)
      flash[:notice].should eql("Оплата произведена успешно")
    end
  end

  context "GET fail" do
    let(:method) { get :fail }

    it "should be fail message and redirect to edit company" do
      response.should redirect_to edit_dashboard_company_path(@company)
      flash[:notice].should eql("Оплата не произведена")
    end
  end
end