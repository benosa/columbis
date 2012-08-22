require 'spec_helper'

describe Dashboard::CountriesController do
  def create_country
    @country = Factory(:country)
  end

  before (:each) do
    create_country
  end

  describe 'GET index' do
    def do_get
      get :index
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should find all countries' do
      do_get
      assigns[:countries].size.should > 0
    end

    it 'should render countries/index.html' do
      do_get
      response.should render_template('index')
    end
  end

  describe 'GET new' do
    def do_get
      get :new
    end

    before (:each) do
      do_get
    end

    it 'should render countries/new' do
      response.should render_template('new')
    end

    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'POST create' do
    def do_country
      post :create, :country => {:name => 'country'}
    end

    it 'should redirect to countries/show.html' do
      do_country
      response.should redirect_to(countries_path)
    end

    it 'should change country count up by 1' do
      lambda { do_country }.should change{ Country.count }.by(1)
    end
  end

  describe 'GET edit' do
    def do_get
      get :edit, :id => @country.id
    end

    before (:each) do
      do_get
    end

    it 'should render countries/edit' do
      response.should render_template('edit')
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right country' do
      assigns[:country].id.should == @country.id
    end
  end

  describe 'PUT update' do
    def do_put
      put :update, :id => @country.id, :country => {:name => 'first'}
    end

    before(:each) do
      do_put
    end

    it 'should change country name' do
      assigns[:country].name.should == 'first'
    end

    it 'should redirect to countries/show.html' do
      response.should redirect_to countries_path
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @country.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to countries/index.html' do
      do_delete
      response.should redirect_to(countries_path)
    end

    it 'should change country count down by 1' do
      lambda { do_delete }.should change{ Country.count }.by(-1)
    end
  end

  describe 'GET show' do
    def do_get
      get :show, :id => @country.id
    end

    before (:each) do
      do_get
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right country' do
      assigns[:country].id.should == @country.id
    end

    it 'should render countries/show.html' do
      response.should render_template('show')
    end
  end
end
