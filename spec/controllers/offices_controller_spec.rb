require 'spec_helper'

describe OfficesController do
  def create_office
    @office = Factory(:office)
  end

  before (:each) do
    create_office
  end

  describe 'GET index' do
    def do_get
      get :index
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should find all offices' do
      do_get
      assigns[:offices].size.should > 0
    end

    it 'should render offices/index.html' do
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

    it 'should render offices/new' do
      response.should render_template('new')
    end

    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'POST create' do
    def do_office
      post :create, :office => {:name => 'branch'}
    end

    it 'should redirect to offices/show.html' do
      do_office
      response.should redirect_to(office_path(Office.last.id))
    end

    it 'should change office count up by 1' do
      lambda { do_office }.should change{ Office.count }.by(1)
    end
  end

  describe 'GET edit' do
    def do_get
      get :edit, :id => @office.id
    end

    before (:each) do
      do_get
    end

    it 'should render offices/edit' do
      response.should render_template('edit')
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right office' do
      assigns[:office].id.should == @office.id
    end
  end

  describe 'PUT update' do
    def do_put
      put :update, :id => @office.id, :office => {:name => 'first'}
    end

    before(:each) do
      do_put
    end

    it 'should change office name' do
      assigns[:office].name.should == 'first'
    end

    it 'should redirect to offices/show.html' do
      response.should redirect_to @office
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @office.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to offices/index.html' do
      do_delete
      response.should redirect_to(offices_path)
    end

    it 'should change offices count down by 1' do
      lambda { do_delete }.should change{ Office.count }.by(-1)
    end
  end

  describe 'GET show' do
    def do_get
      get :show, :id => @office.id
    end

    before (:each) do
      do_get
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right office' do
      assigns[:office].id.should == @office.id
    end

    it 'should render offices/show.html' do
      response.should render_template('show')
    end
  end
end
