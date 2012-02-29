require 'spec_helper'

describe ClientsController do
  def create_client
    @client = Factory(:client)
  end

  before (:each) do
    create_client
  end

  describe 'GET index' do
    def do_get
      get :index
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should find all clients' do
      do_get
      assigns[:clients].size.should > 0
    end

    it 'should render clients/index.html' do
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

    it 'should render clients/new' do
      response.should render_template('new')
    end

    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'POST create' do
    def do_client
      post :create, :client => { :last_name => 'Ivanov', :first_name => 'Ivan', :middle_name => 'Ivanovich',
                                  :address =>'', :phone_number => '', :passport_number => '123444',
                                  :passport_series => '1234', :date_of_birth => '', :passport_valid_until => '' }
    end

    it 'should redirect to clients/show.html' do
      do_client
      response.should redirect_to(client_path(Client.last.id))
    end

    it 'should change clients count up by 1' do
      lambda { do_client }.should change{ Client.count }.by(1)
    end
  end

  describe 'GET edit' do

    before (:each) do
      get :edit, :id => @client.id
    end

    it 'should render clients/edit' do
      response.should render_template('edit')
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right client' do
      assigns[:client].id.should == @client.id
    end
  end

  describe 'PUT update' do
    before(:each) do
      put :update, :id => @client.id, :client => {:full_name => 'Козлов Акакий'}
    end

    it 'should change client last_name' do
      assigns[:client].full_name.should == 'Козлов Акакий'
    end

    it 'should redirect to clients/show.html' do
      response.should redirect_to @client
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @client.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to clients/index.html' do
      do_delete
      response.should redirect_to(clients_path)
    end

    it 'should change clients count down by 1' do
      lambda { do_delete }.should change{ Client.count }.by(-1)
    end
  end

  describe 'GET show' do

    before (:each) do
      get :show, :id => @client.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right client' do
      assigns[:client].id.should == @client.id
    end

    it 'should render clients/show.html' do
      response.should render_template('show')
    end
  end
end
