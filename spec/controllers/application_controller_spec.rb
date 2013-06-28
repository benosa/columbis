# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ApplicationController do
  include ActionView::Helpers

  describe "time zone" do

    it "Time.zone when user isn't login == UTC" do
      Time.zone.name.should == "UTC"
    end

    it "Time.zone when user is login == Moscow" do
      user = FactoryGirl.create(:admin)
      test_sign_in(user)
      @controller.send(:set_time_zone) do
        Time.zone.name.should == "Moscow"
      end
    end

    it "Rechoising Time.zone to Berlin" do
      company = FactoryGirl.create(:company, :time_zone => "Berlin")
      stub_current_company(company)
      user = FactoryGirl.create(:admin, :company_id => company.id)
      test_sign_in(user)
      @controller.send(:set_time_zone) do
        Time.zone.name.should == "Berlin"
      end
    end
  end
end