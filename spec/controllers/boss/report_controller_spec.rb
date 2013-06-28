# -*- encoding : utf-8 -*-
require 'spec_helper'
  
describe Boss::ReportsController do
  include ActionView::Helpers
  
  def create_claims(company, user)
    [
      FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "Интернет", hotel: "5*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-02"),
      FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "Клиенты", hotel: "5*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-02"),
      FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "Клиенты", hotel: "1*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-07"),
      FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "Рекомендации", hotel: "2*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-9"),
      FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "Интернет", hotel: "3*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-12"),
      FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "Телевизор", hotel: "4*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-20"),
      FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "Журналы/Газеты", hotel: "4*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-20"),
      FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "Вывеска", hotel: "4*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-20")
    ]
  end
  
  def create_payment(claim, company, tourist)
    FactoryGirl.create(:payment, claim: claim, company_id: company.id, recipient_id: company.id, payer_type: 'Tourist', recipient_type: 'Company', amount: 100, date_in: Time.zone.now,
      payer_id: tourist.id, form: "Наличные"
    )
  end
  
  before do
    company = FactoryGirl.create(:company, :time_zone => "Berlin")
    user = FactoryGirl.create(:admin, :company_id => company.id)
    tourist = FactoryGirl.create(:tourist)
    create_claims(company, user).each do |claim|
      create_payment(claim, company, tourist)
    end
    
    test_sign_in(user)
  end 
  
  describe "hotel stars report" do
    it "check stars" do
      get :hotelstars
      assigns(:count).data.map { |x| [ x["name"], x["count"] ] }.should == [ ["1*", 1], ["2*", 1], ["3*", 1], ["4*", 3], ["5*", 2] ]
    end
  end
  
  describe "tour duration report" do
    it "check stars" do
      get :tourduration
      assigns(:count).data.map { |x| x["count"] }.should == [ 2, 1, 1, 1, 3 ]
    end
  end
  
  describe "promotion channel report from iternet" do
    it "check stars" do
      get :promotionchannel
      count = assigns(:count).data.find_all { |x| x["name"] == "Интернет" }.first["count"]
      amount = assigns(:amount).data.find_all { |x| x["name"] == "Интернет" }.first["amount"]
      [count, amount].should == [2, 200]
    end
  end
  
  describe "promotion channel report from client" do
    it "check stars" do
      get :promotionchannel
      count = assigns(:count).data.find_all { |x| x["name"] == "Клиенты" }.first["count"]
      amount = assigns(:amount).data.find_all { |x| x["name"] == "Клиенты" }.first["amount"]
      [count, amount].should == [2, 200]
    end
  end
  
  describe "promotion channel report from signboard" do
    it "check stars" do
      get :promotionchannel
      count = assigns(:count).data.find_all { |x| x["name"] == "Вывеска" }.first["count"]
      amount = assigns(:amount).data.find_all { |x| x["name"] == "Вывеска" }.first["amount"]
      [count, amount].should == [1, 100]
    end
  end
end

