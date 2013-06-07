# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ApplicationController do
  include ActionView::Helpers
  
  describe "time zone" do
    
    it "Time.zone when user isn't login == UTC" do
      Time.zone.name.should == "UTC"
    end
    
    it "Time.zone when user is login == Moscow" do
      login_as_admin
      Time.zone.name.should == "Moscow"
    end
    
    it "Rechoising Time.zone to Berlin" do
      company = FactoryGirl.create(:company, :time_zone => "Berlin")
      user = FactoryGirl.create(:admin, :company_id => company.id)
      login(user)
      Time.zone.name.should == "Berlin"
    end
  end
end