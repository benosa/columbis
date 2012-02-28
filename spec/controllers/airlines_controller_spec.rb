require 'spec_helper'

describe AirlinesController do
  def create_airline
    @airline = Factory(:airline)
  end

  before (:each) do
    create_airline
  end

  describe 'GET index' do
    def do_get
      get :index
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should find all airlines' do
      do_get
      assigns[:airlines].size.should > 0
    end

    it 'should render airlines/index.html' do
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

    it 'should render airlines/new' do
      response.should render_template('new')
    end

    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'POST create' do
    def do_airline
      post :create, :airline => {:name => 'airline'}
    end

    it 'should redirect to airlines/show.html' do
      do_airline
      response.should redirect_to(airlines_path)
    end

    it 'should change airline count up by 1' do
      lambda { do_airline }.should change{ Airline.count }.by(1)
    end
  end

  describe 'GET edit' do
    def do_get
      get :edit, :id => @airline.id
    end

    before (:each) do
      do_get
    end

    it 'should render airlines/edit' do
      response.should render_template('edit')
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right airline' do
      assigns[:airline].id.should == @airline.id
    end
  end

  describe 'PUT update' do
    def do_put
      put :update, :id => @airline.id, :airline => {:name => 'first'}
    end

    before(:each) do
      do_put
    end

    it 'should change airline name' do
      assigns[:airline].name.should == 'first'
    end

    it 'should redirect to airlines/show.html' do
      response.should redirect_to airlines_path
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @airline.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to airlines/index.html' do
      do_delete
      response.should redirect_to(airlines_path)
    end

    it 'should change airline count down by 1' do
      lambda { do_delete }.should change{ Airline.count }.by(-1)
    end
  end

  describe 'GET show' do
    def do_get
      get :show, :id => @airline.id
    end

    before (:each) do
      do_get
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right airline' do
      assigns[:airline].id.should == @airline.id
    end

    it 'should render airlines/show.html' do
      response.should render_template('show')
    end
  end
end
