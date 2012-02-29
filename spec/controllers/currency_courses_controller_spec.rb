require 'spec_helper'

describe CurrencyCoursesController do
  include Devise::TestHelpers

  def create_users
    office = Factory(:office)
    @admin = Factory(:admin)
    @accountant = Factory(:accountant, :office_id => office.id)
    test_sign_in(@admin)
  end

  def create_course
    @course = Factory(:currency_course, :user_id =>@accountant.id)
  end

  before(:each) do
    create_users
    create_course
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
