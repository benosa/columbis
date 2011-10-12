require 'spec_helper'

describe TouristsController do
  def create_tourist
    @tourist = Factory(:tourist)
  end

  before (:each) do
    create_tourist
  end

  describe 'GET index' do
    def do_get
      get :index
    end

    it 'should be successful' do
      do_get
      response.should be_success                
    end

    it 'should find all tourists' do
      do_get
      assigns[:tourists].size.should > 0
    end

    it 'should render tourists/index.html' do
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

    it 'should render tourists/new' do
      response.should render_template('new')
    end

    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'POST create' do
    def do_tourist
      post :create, :tourist => {:passport_series => '1223', :passport_number => '123123'}
    end

    it 'should redirect to tourists/show.html' do
      do_tourist
      new_tourist = Tourist.last
      response.should redirect_to tourist_path(new_tourist)
    end

    it 'should change tourists count up by 1' do
      lambda { do_tourist }.should change{ Tourist.count }.by(1)
    end
  end

  describe 'GET edit' do    
    def do_get
      get :edit, :id => @tourist.id
    end

    before (:each) do
      do_get
    end

    it 'should render tourists/edit' do
      response.should render_template('edit')
    end
    
    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'PUT update' do
    def do_put
      put :update, :id => @tourist.id, :tourist => {:last_name => 'Ivanov'}
    end

    before(:each) do
      do_put
    end

    it 'should change tourist last_name' do
      assigns[:tourist].last_name.should == 'Ivanov'
    end
    
    it 'should redirect to tourists/show.html' do
      response.should redirect_to @tourist
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @tourist.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to tourists/index.html' do
      do_delete
      response.should redirect_to(tourists_path)
    end

    it 'should change tourists count down by 1' do
      lambda { do_delete }.should change{ Tourist.count }.by(-1)
    end
  end

  describe 'GET show' do
    def do_get
      get :show, :id => @tourist.id
    end

    before (:each) do
      do_get
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right tourist' do
      assigns[:tourist].should == @tourist
    end

    it 'should render tourists/show.html' do
      response.should render_template('show')
    end
  end
end
