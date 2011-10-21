require 'spec_helper'

describe CurrencyCoursesController do
  include Devise::TestHelpers  
  
  def create_user
    @user = Factory(:user)
    test_sign_in(@user)
  end

  def create_course
    @course = Factory(:currency_course, :user_id =>@user.id)
  end

  before(:each) do
    create_user
    create_course
    puts @user.inspect
    puts @course.inspect
  end

  describe 'GET new' do
    def do_get
      get :new
    end

    before (:each) do
      do_get
    end

    it 'should render currency_cources/new' do
      response.should render_template('new')
    end

    it 'should be successful' do
      response.should be_success
    end
  end
end
