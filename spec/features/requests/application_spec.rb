# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "SSL tests:" do
  include ActionView::Helpers

  it "protocol should be https" do
    visit new_user_session_path
    current_url.split(':')[0].should == "http"
  end
end