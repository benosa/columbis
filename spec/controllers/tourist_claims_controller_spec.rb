require File.dirname(__FILE__) + '/../spec_helper'

describe TouristClaimsController do
  fixtures :all
  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    get :show, :id => TouristClaim.first
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    TouristClaim.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    TouristClaim.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(tourist_claim_url(assigns[:tourist_claim]))
  end

  it "edit action should render edit template" do
    get :edit, :id => TouristClaim.first
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    TouristClaim.any_instance.stubs(:valid?).returns(false)
    put :update, :id => TouristClaim.first
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    TouristClaim.any_instance.stubs(:valid?).returns(true)
    put :update, :id => TouristClaim.first
    response.should redirect_to(tourist_claim_url(assigns[:tourist_claim]))
  end

  it "destroy action should destroy model and redirect to index action" do
    tourist_claim = TouristClaim.first
    delete :destroy, :id => tourist_claim
    response.should redirect_to(tourist_claims_url)
    TouristClaim.exists?(tourist_claim.id).should be_false
  end
end
