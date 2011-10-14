require 'spec_helper'

describe CurrencyCoursesController do

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
