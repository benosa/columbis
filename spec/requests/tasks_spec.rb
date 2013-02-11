# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Tasks" do
  before (:each) do
    login_as_admin
    visit user_session_path
    # puts page.body.inspect
  end

  describe "GET /tasks" do
    #puts "1"*80
    it "works! (now write some real specs)" do
      #puts "2"*80
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      #puts tasks_path
      get tasks_path
      #puts "3"*80
      #puts response.body.inspect
      response.status.should be(200)
    end
    #puts "4"*80
  end
end
