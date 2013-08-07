# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Boss::ClientsBaseReport do
  before(:all) do
    @company = FactoryGirl.create(:company)
    @count = 50
    create_claims_with_prerequisites(@company, :clientbase_claim, @count)
  end

  it 'should properly consider the amount' do
    report = Boss::ClientsBaseReport.new({
      :company => @company,
      :start_date => "#{Time.zone.now.year}.1.1".to_datetime,
      :end_date => Time.zone.now
    }).prepare
    amount = report.amount.data
    clients_percent20 = (@count * 0.2).to_i
    clients_percent30 = (@count * 0.3).to_i
    clients_percent50 = @count - clients_percent20 - clients_percent30
    clients_percent20 *= 10000
    clients_percent30 *= 10000
    clients_percent50 *= 10000
    (amount.any? {|value| value["amount"] == clients_percent20 and
        value["name"] == I18n.t(".clientsbase_report.amount", value: "20%") } and
      amount.any? {|value| value["amount"] == clients_percent30 and
        value["name"] == I18n.t(".clientsbase_report.amount", value: "30%") } and
      amount.any? {|value| value["amount"] == clients_percent50 and
        value["name"] == I18n.t(".clientsbase_report.amount", value: "50%") }).should == true
  end

  it 'should properly consider the count' do
    report = Boss::ClientsBaseReport.new({
      :company => @company,
      :start_date => "#{Time.zone.now.year}.1.1".to_datetime,
      :end_date => Time.zone.now
    }).prepare
    count = report.count.data
    payments_percent80 = (@count * 0.8).to_i
    payments_percent15 = (@count * 0.15).to_i
    payments_percent5  = @count - payments_percent80 - payments_percent15
    (count.any? {|value| value["count"] == payments_percent80 and
        value["name"] == I18n.t(".clientsbase_report.count", value: "80%") } and
      count.any? {|value| value["count"] == payments_percent15 and
        value["name"] == I18n.t(".clientsbase_report.count", value: "15%") } and
      count.any? {|value| value["count"] == payments_percent5 and
        value["name"] == I18n.t(".clientsbase_report.count", value: "5%") }).should == true
  end

  it 'should properly consider the total amounts' do
    report = Boss::ClientsBaseReport.new({
      :company => @company,
      :start_date => "#{Time.zone.now.year}.1.1".to_datetime,
      :end_date => Time.zone.now
    }).prepare
    count = report.count.data
    amount80 = report.amount80.select{|e| e["name"] == "0.80"}.length
    amount15 = report.amount15.select{|e| e["name"] == "0.15"}.length
    amount5  = report.amount5.select{|e| e["name"] == "0.05"}.length
    payments_percent80 = (@count * 0.8).to_i
    payments_percent15 = (@count * 0.15).to_i
    payments_percent5  = @count - payments_percent80 - payments_percent15
    (amount80 == payments_percent80 and
      amount15 == payments_percent15 and
      amount5 == payments_percent5).should == true
  end
end