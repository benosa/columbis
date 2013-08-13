require 'spec_helper'

describe TariffPlansController do
  before do
    10.times { FactoryGirl.create(:tariff_plan) }
    test_sign_in(FactoryGirl.create(:admin))
  end

  describe "GET index" do
    before { get :index }
    it { should respond_with :success }
    it { should render_template :index }
  end

  describe "GET show" do
    before { get :show, :id => TariffPlan.first }
    it { response.should redirect_to(tariff_plans_path) }
  end

  describe "GET new" do
    before { get :new }
    it { should respond_with :success }
    it { should render_template :new }
  end

  describe "GET edit" do
    before { get :edit, :id => TariffPlan.first }

    it { should respond_with :success }
    it { should render_template :edit }
    it { should assign_to(:tariff_plan).with(TariffPlan.first) }
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TariffPlan" do
        expect {
          post :create, {:tariff_plan => FactoryGirl.build(:tariff_plan).attributes}
        }.to change(TariffPlan, :count).by(1)
      end

      it "assigns a newly created tariff_plan as @tariff_plan" do
        post :create, {:tariff_plan => FactoryGirl.build(:tariff_plan).attributes}
        assigns(:tariff_plan).should be_a(TariffPlan)
        assigns(:tariff_plan).should be_persisted
      end

      it "redirects to the created tariff_plan" do
        post :create, {:tariff_plan => FactoryGirl.build(:tariff_plan).attributes}
        response.should redirect_to(tariff_plans_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved tariff_plan as @tariff_plan" do
        # Trigger the behavior that occurs when invalid params are submitted
        TariffPlan.any_instance.stub(:save).and_return(false)
        post :create, {:tariff_plan => { "price" => "invalid value" }}
        assigns(:tariff_plan).should be_a_new(TariffPlan)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        TariffPlan.any_instance.stub(:save).and_return(false)
        post :create, {:tariff_plan => { "price" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested tariff_plan" do
        tariff_plan = FactoryGirl.create(:tariff_plan)
        expect {
          put :update, id: tariff_plan.id, tariff_plan: attributes_for(:tariff_plan, price: 10000)
          tariff_plan.reload
        }.to change(tariff_plan, :price).to(10000)
      end

      it "assigns the requested tariff_plan as @tariff_plan" do
        tariff_plan = FactoryGirl.create(:tariff_plan)
        put :update, {:id => tariff_plan.to_param}
        assigns(:tariff_plan).should eq(tariff_plan)
      end

      it "redirects to the tariff_plan" do
        tariff_plan = FactoryGirl.create(:tariff_plan)
        put :update, {:id => tariff_plan.to_param}
        response.should redirect_to(tariff_plans_path)
      end
    end

    describe "with invalid params" do
      it "assigns the tariff_plan as @tariff_plan" do
        tariff_plan = FactoryGirl.create(:tariff_plan)
        # Trigger the behavior that occurs when invalid params are submitted
        TariffPlan.any_instance.stub(:save).and_return(false)
        put :update, {:id => tariff_plan.to_param, :tariff_plan => { "price" => "invalid value" }}
        assigns(:tariff_plan).should eq(tariff_plan)
      end

      it "re-renders the 'edit' template" do
        tariff_plan = FactoryGirl.create(:tariff_plan)
        # Trigger the behavior that occurs when invalid params are submitted
        TariffPlan.any_instance.stub(:save).and_return(false)
        put :update, {:id => tariff_plan.to_param, :tariff_plan => { "price" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested tariff_plan" do
      tariff_plan = FactoryGirl.create(:tariff_plan)
      expect {
        delete :destroy, {:id => tariff_plan.to_param}
      }.to change(TariffPlan, :count).by(-1)
    end

    it "redirects to the tariff_plans list" do
      tariff_plan = FactoryGirl.create(:tariff_plan)
      delete :destroy, {:id => tariff_plan.to_param}
      response.should redirect_to(tariff_plans_path)
    end
  end

end
