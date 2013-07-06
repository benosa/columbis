# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Dashboard::UsersController do
  include Devise::TestHelpers

  def create_users
    @office = FactoryGirl.create(:office)
    @admin = FactoryGirl.create(:admin)
    @manager = FactoryGirl.create(:manager, :office_id => @office.id)
    test_sign_in(@admin)
  end

  before { create_users }

  describe 'GET index' do
    before { get :index }
    it{ response.should be_success }
    it{ should assign_to(:users) }
    it{ response.should render_template('index') }
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @manager.id
    end
    it { response.should be_success }
    it 'should redirect to sign in' do
      do_delete
      response.should redirect_to(dashboard_users_url)
    end
    it { expect { do_delete }.to change{ User.count }.by(-1) }
  end

  describe 'GET edit' do
    before { get :edit, :id => @manager.id }
    it { response.should render_template('edit')}
    it { response.should be_success}
    it { should assign_to(:user).with(@manager) }
  end

  describe 'POST create' do
    def create_user(password = "123456")
      create_user_without_password.merge(:password => password)
    end
    def create_user_without_password
      { :role => :admin, :company_id => @manager.company, :login => "login", :email => "test@test.com", :first_name => "Name1", :last_name => "Name2", :office_id => @office.id }
    end
    def call_post(user_params)
      post :create, :user => user_params
    end

    it 'if user was created successfully should redirect to users list' do
      call_post create_user
      response.should redirect_to(dashboard_users_path)
    end
    it 'should change user count up by 1' do
      expect { call_post create_user }.to change{ User.count }.by(1)
    end
    it 'should change user count up by 1 without password ' do
      expect { call_post create_user_without_password }.to change{ User.count }.by(1)
    end
    it 'should not change user count up by 1 with bad password' do
      expect { call_post create_user("a") }.to change{ User.count }.by(0)
    end
  end

  describe 'GET new' do
    before { get :new }
    it { response.should render_template('new') }
    it { response.should be_success }
  end
end
