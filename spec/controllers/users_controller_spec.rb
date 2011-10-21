require 'spec_helper'

describe UsersController do
  include Devise::TestHelpers  
  
  def create_user
    @user = Factory(:user)
    test_sign_in(@user)
  end

  before(:each) do
    create_user
    puts @user.inspect
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
      delete :destroy, :id => @user.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to users/index.html' do
      do_delete
      response.should redirect_to(users_path)
    end

    it 'should change users count down by 1' do
      lambda { do_delete }.should change{ User.count }.by(-1)
    end
  end

  describe 'GET edit' do    
    def do_get
      get :edit, :id => @user.id
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
      assigns[:user].id.should == @user.id
    end
  end
end
