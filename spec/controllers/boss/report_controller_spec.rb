# -*- encoding : utf-8 -*-
require 'spec_helper'
  
describe Boss::ReportsController do
  include ActionView::Helpers
  before do
    company = FactoryGirl.create(:company, :time_zone => "Berlin")
    user = FactoryGirl.create(:admin, :company_id => company.id)
    create_claims(company, user)
    test_sign_in(user)
  end 
  
  describe "hotel stars report" do
    it "check stars" do
      get :hotelstars
      assigns(:count).data.map { |x| [ x["name"], x["count"] ] }.should == [ ["*", 1], ["**", 1], ["***", 1], ["****", 2], ["*****", 2] ]
    end
  end
  
  describe "tour duration report" do
    it "check stars" do
      get :tourduration
      assigns(:count).data.map { |x| x["count"] }.should == [ 2, 1, 1, 1, 2 ]
    end
  end
  
  describe "promotion channel report from iternet" do
    it "check stars" do
      get :promotionchannel
      assigns(:count).data.find_all { |x| x["name"] == "Интернет" }.first["count"].should == 1
    end
  end
  
  describe "promotion channel report from client" do
    it "check stars" do
      get :promotionchannel
      assigns(:count).data.find_all { |x| x["name"] == "Клиенты" }.first["count"].should == 2
    end
  end
end

