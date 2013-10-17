# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Dashboard::UsersController do
  include Devise::TestHelpers

  def create_users
    @boss = create_user_with_company_and_office :boss
    stub_currents @boss
    @manager = create(:manager, company: @boss.company, office: @boss.office)
    test_sign_in(@boss)
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
    def user_attrs(password = "123456")
      attributes_for(:manager).merge({
        :office_id => @boss.office.id,
        :password => password,
        :use_office_password => false
      })
    end
    def call_post(user_params)
      post :create, :user => user_params
    end

    it 'if user was created successfully should redirect to users list' do
      call_post user_attrs
      response.should redirect_to(dashboard_users_path)
    end
    it 'should change user count up by 1' do
      expect { call_post user_attrs }.to change{ User.count }.by(1)
    end
    it 'should change user count up by 1 without password ' do
      expect { call_post user_attrs(nil) }.to change{ User.count }.by(1)
    end
    it 'should not change user count up by 1 with bad password' do
      expect { call_post user_attrs("a") }.to change{ User.count }.by(0)
    end
  end

  describe 'GET new' do
    before { get :new }
    it { response.should render_template('new') }
    it { response.should be_success }
  end
end

def email_to_check(attrs)
  attrs[:_check] = attrs.delete(:email)
  attrs
end

describe RegistrationsController do
  include Devise::TestHelpers

  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'PUT_update' do
    def create_user
      @boss = create_user_with_company_and_office :boss
      stub_currents @boss
      test_sign_in(@boss)
    end

    context "when fully updated" do
      before {
        create_user
        put :update, id: @boss.id, user: attributes_for(:boss)
      }
      it { should assign_to(:user).with(@boss) }
      it { should redirect_to(edit_user_registration_path) }
    end

    it "changes user last_name" do
      create_user
      last_name = Faker::Name.last_name
      expect {
        put :update, id: @boss.id, user: { last_name: last_name }
        @boss.reload
      }.to change(@boss, :last_name).to(last_name)
    end
  end

  describe 'POST_create_html' do
    before {
      @user = create(:admin)
    }
    it 'should create user' do
      expect {
        post :create, :user => attributes_for(:user)
      }.to change{ User.count }.by(+1)
    end

    it 'should not create user - duplicate email' do
      expect {
        post :create, :user => attributes_for(:user, email: @user.email)
      }.not_to change{ User.count }
    end
  end

  describe 'POST_create_json' do
    before {
      @boss = create_user_with_company_and_office :boss
      @attributes = attributes_for :boss
    }

    it 'should return success:true' do
      post :create, :user => @attributes, :format => :json
      response.body.should == { :success => true }.to_json
    end

    it 'should return success:false because email exist' do
      @attributes[:email] = @boss.email
      post :create, :user => @attributes, :format => :json
      response.header['Content-Type'].should match /json/
      response.body.should have_text('"success":false')
    end

    it 'should return success:false because phone is short' do
      @attributes['phone'] = '444'
      post :create, :user => @attributes, :format => :json
      response.header['Content-Type'].should match /json/
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
    # @boss = create_user_with_company_and_office :boss
    login, password = FactoryGirl.generate(:login), '111111'
    @attributes = { login: login, password: password }
    @boss = create :boss, login: login, password: password
  end

  describe 'POST to create with json format' do
    render_views

    after { response.content_type.should match /json/ }

    context "when valid data" do
      it 'should return success:true' do
        post :create, :user => @attributes, :format => :json
        # response.body.should have_text('"success":false') - devise bug https://github.com/plataformatec/devise/pull/2074
      end
    end

    context "when invalid data" do
      it 'should return success:false because invalid password' do
        post :create, :user => @attributes.merge(password: '111112'), :format => :json
        # response.body.should have_text('"success":true')
      end
    end
  end
end

describe PasswordsController do
  include Devise::TestHelpers

  before { create_user }

  def create_user
    @boss = FactoryGirl.create(:boss, :email => 'test@mail.ru')
  end

  describe 'POST_create' do
    before {
      @request.env["devise.mapping"] = Devise.mappings[:user]
    }

    it "changes user reset_password_token " do
      expect {
        post :create, user: {email: 'test@mail.ru', generate_password: '0'}
        @boss.reload
      }.to change(@boss, :reset_password_token)
      response.should redirect_to(new_user_session_path)
    end

    it "changes user password " do
      expect {
        post :create, user: {email: 'test@mail.ru', generate_password: '1'}
        @boss.reload
      }.to change(@boss, :encrypted_password)
      response.should redirect_to(new_user_session_path)
    end
  end
end

describe ConfirmationsController do
  include Devise::TestHelpers

  before {
    @user = create(:user, confirmed_at: nil, company_id: nil )
    @request.env["devise.mapping"] = Devise.mappings[:user]
  }

  describe 'PUT_confirm' do
    it "create company after user confirm" do
      expect {
        put :show, confirmation_token: @user.confirmation_token
        @user.reload
      }.to change(@user, :company_id)
    end

    it "changes user reset_password_token " do
      expect {
        put :show, confirmation_token: @user.confirmation_token
        @user.reload
      }.to change(@user, :company_id)#{ Company.count }.by(+1)
    end
  end
end

