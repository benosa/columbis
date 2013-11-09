require 'spec_helper'

describe VisitorsController do

  describe "POST 'create'" do
    before {
      @attrs = attributes_for(:visitor)
      create(:visitor, @attrs)
    }
    it "should create visitor" do
      expect {
        post :create, :visitor => attributes_for(:visitor), :format => :json
      }.to change{ Visitor.count }.by(+1)
    end

    it "should not create visitor" do
      expect {
        post :create, :visitor => @attrs, :format => :json
      }.not_to change{ Visitor.count }
    end
  end

  describe "GET 'confirm'" do
    before {
      @visitor = create(:visitor, attributes_for(:visitor))
      @boss = FactoryGirl.create(:boss, :login => 'demo')
    }

    it "should confirm visitor" do
      expect {
        get :confirm, confirmation_token: @visitor.confirmation_token
          @visitor.reload
        }.to change(@visitor, :confirmed)
      end
  end

end
