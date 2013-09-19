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
      { :role => :admin, :company_id => @manager.company, :login => "login", :email => "test@test.com",
        :first_name => "Name1", :last_name => "Name2", :office_id => @office.id, :phone => "+77777777",
        :use_office_password => false }
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

describe RegistrationsController do
  include Devise::TestHelpers

  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  def create_user
    @office = FactoryGirl.create(:office)
    @company = FactoryGirl.create(:company)
    @user = FactoryGirl.create(:admin, :office_id => @office.id, :company_id => @company.id, :confirmed_at => Time.now)
    stub_current_company(@company)
    stub_current_office(@office)
    stub_current_user(@user)
    test_sign_in(@user)
  end

  describe 'PUT_update' do
    before {
      create_user
      put :update, id: @user.id, user: attributes_for(:user)
    }
    it { should assign_to(:user).with(@user) }
    it { should redirect_to(edit_user_registration_path) }

    it "changes user last_name " do
      expect {
        put :update, id: @user.id, user: attributes_for(:user, last_name: 'Ivanov1')
        @user.reload
      }.to change(@user, :last_name).to('Ivanov1')
    end
  end

  describe 'POST_create_json' do
    before {
      @user = FactoryGirl.create(:admin, :email => 'test@mail.ru')
      #@request.env["devise.mapping"] = Devise.mappings[:user]
      @attributes = {first_name: 'test', last_name: 'test',
        phone_code: '+7', phone: '99999999'}
    }

    it 'should return success:true' do
      @attributes['email'] = 'test2@mail.ru'
      post :create, :user => @attributes, :format => :json
      response.body.should == { :success => true }.to_json
    end

    it 'should return success:false because email exist' do
      @attributes['email'] = 'test@mail.ru'
      post :create, :user => @attributes, :format => :json
      response.body.should have_text('"success":false')
    end

    it 'should redirect success:false because phone is short' do
      @attributes['email'] = 'test3@mail.ru'
      @attributes['phone'] = '444'
      post :create, :user => @attributes, :format => :json
      response.body.should have_text('"success":false')
    end
  end
end

describe SessionsController do
  include Devise::TestHelpers

  before {
    @request.env["devise.mapping"] = Devise.mappings[:user]
    create_user
  }

  def create_user
    @user = FactoryGirl.create(:admin, :login => 'test', :password => '111111')
  end

  describe 'POST_create2_json' do
    it 'should return success: email6 exist' do
      post :create, :user => { login: 'test', password: '111112' }, :format => :json
     # response.header['Content-Type'].should match /json/
      response.body.should == 'dfsfd'
    end

    it 'should return success:false because email exist' do
      post :create, :user => { login: 'test', password: '111111' }, :format => :json
     # response.header['Content-Type'].should match /json/
      response.body.should have_text('"success":true')
    end
  end
end

describe PasswordsController do
  include Devise::TestHelpers

  before { create_user }

  def create_user
    @user = FactoryGirl.create(:admin, :email => 'test@mail.ru')
  end

  describe 'POST_create' do
    before {
      @request.env["devise.mapping"] = Devise.mappings[:user]
    }

    it "changes user reset_password_token " do
      expect {
        post :create, user: {email: 'test@mail.ru', generate_password: '0'}
        @user.reload
      }.to change(@user, :reset_password_token)
      response.should redirect_to(new_user_session_path)
    end

    it "changes user password " do
      expect {
        post :create, user: {email: 'test@mail.ru', generate_password: '1'}
        @user.reload
      }.to change(@user, :encrypted_password)
      response.should redirect_to(new_user_session_path)
    end
  end
end


