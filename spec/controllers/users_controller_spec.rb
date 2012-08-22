require 'spec_helper'

describe Dashboard::UsersController do
  include Devise::TestHelpers

  def create_users
    office = Factory(:office)
    @admin = Factory(:admin)
    @manager = Factory(:manager, :office_id => office.id)
    test_sign_in(@admin)
  end

  before(:each) do
    create_users
  end

  describe 'GET index' do
    def do_get
      get :index
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should find all users' do
      do_get
      assigns[:users].size.should > 0
    end

    it 'should render users/index.html' do
      do_get
      response.should render_template('index')
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @manager.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to sign in' do
      do_delete
      response.should redirect_to(new_user_session_path)
    end

    it 'should change users count down by 1' do
      lambda { do_delete }.should change{ User.count }.by(-1)
    end
  end

  describe 'GET edit' do
    def do_get
      get :edit, :id => @manager.id
    end

    before (:each) do
      do_get
    end

    it 'should render users/edit' do
      response.should render_template('edit')
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right user' do
      assigns[:user].id.should == @manager.id
    end
  end
end
