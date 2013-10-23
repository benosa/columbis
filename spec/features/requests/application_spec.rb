# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "SSL tests:" do
  include ActionView::Helpers

  it "protocol should be https" do
    visit new_user_session_path
    current_url.split(':')[0].should == (CONFIG[:force_ssl] ? "https" : "http")
  end
end

describe "download tests:" do
  #include ActionView::Helpers

  it "protocol should be https" do
    visit root_url + '/instructions.pdf'
    page.response_headers['Content-Type'].should eq "application/pdf"
  end
end

