require 'spec_helper'

describe PrintersController do
  before(:all) do
    @admin = FactoryGirl.create(:admin)
    @act = FactoryGirl.create(:act, :company => @admin.company)
    @warranty = FactoryGirl.create(:warranty, :company => @admin.company)
    @permit = FactoryGirl.create(:permit, :company => @admin.company)
    @memo = FactoryGirl.create(:memo, :company => @admin.company)
    @contract = FactoryGirl.create(:contract, :company => @admin.company)
  end

  before { test_sign_in(@admin) }

  describe "GET index" do
    before { get :index }
    it "should count = 5" do
      assigns(:printers).length.should == 5
    end
  end

  describe "GET new" do
    before { get :new }
    it "should be true" do
      should respond_with :success
      should assign_to(:printer)
      response.should render_template('new')
    end
  end

  describe "GET edit" do
    before { get :edit, :id => @act.id }
    it "should be true" do
      should respond_with :success
      should assign_to(:printer)
      response.should render_template('edit')
    end
  end

  describe "POST create" do
    def post_create
      post :create, :printer => { :mode => 'act', :company_id => @admin.company_id }
    end

    it "should be true" do
      expect { post_create }.to change{ Printer.count }.by(1)
      response.should redirect_to(printers_path)
    end
  end

  describe "PUT update" do
    def put_update
      put :update, id: @contract.id, :printer => { :mode => "permit" }
    end

    it "should rename a mode" do
      expect {
        put_update
        @contract.reload
        }.to change( @contract, :mode ).to("permit")
      response.should redirect_to(printers_path)
    end
  end

  describe "DELETE destroy" do
    def delete_destroy
      delete :destroy, :id => @warranty.id
    end

    it "should delete printer" do
      expect { delete_destroy }.to change{ Printer.count }.by(-1)
      response.should redirect_to(printers_path)
    end
  end
end
