# -*- encoding : utf-8 -*-
require 'spec_helper'

describe TouristsController do
  before { create_tourist }
  
  def create_tourist
    @tourist = FactoryGirl.create(:tourist)
    user = FactoryGirl.create(:admin)
    test_sign_in(user)
  end

  describe "GET #index" do
    before { get :index }
    it { should respond_with :success }
    it { should render_template :index }
    it { should assign_to(:tourists).with [@tourist] }
  end

  describe 'GET new' do
    before { get :new }
    it { should respond_with :success }
    it { should render_template :new }
  end

  describe 'POST create' do
    def do_tourist
      post :create, :tourist => {:first_name => 'Billy', :last_name => 'G!' }
    end

    it 'should redirect to tourists/show.html' do
      do_tourist
      response.should redirect_to(tourists_path)
    end

    it 'should change tourists count up by 1' do
      lambda { do_tourist }.should change{ Tourist.count }.by(1)
    end
  end

  describe 'GET edit' do
    before { get :edit, :id => @tourist.id }

    it { should respond_with :success }
    it { should render_template :edit }
    it { should assign_to(:tourist).with(@tourist) }

  end

  describe 'PUT update' do
    before { put :update, id: @tourist.id, tourist: attributes_for(:tourist, last_name: 'Ivanov') }
    
    it { should assign_to(:tourist).with(@tourist) }
    it { should redirect_to(tourists_path)  }

    it "changes tourist last_name " do
      expect {
        put :update, id: @tourist.id, tourist: attributes_for(:tourist, last_name: 'Ivanov1')
        @tourist.reload
      }.to change(@tourist, :last_name).to('Ivanov1')
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @tourist.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to tourists/index.html' do
      do_delete
      response.should redirect_to(tourists_path)
    end

    it 'should change tourists count down by 1' do
      lambda { do_delete }.should change{ Tourist.count }.by(-1)
    end
  end

  describe 'GET show' do
    before { get :show, :id => @tourist.id }

    it { should assign_to(:tourist).with(@tourist) }
    it { should respond_with :success }
    it { should render_template(:show)  }

  end
end
