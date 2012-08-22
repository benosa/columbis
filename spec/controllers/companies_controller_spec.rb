require 'spec_helper'

describe Dashboard::CompaniesController do

  def create_company
    @company = Factory(:company)
  end

  before(:each) do
    create_company
  end

  describe 'GET index' do
    def do_get
      get :index
    end

    before(:each) do
      do_get
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find all companies' do
      do_get
      assigns[:companies].size.should > 0
    end

    it 'should render companies/index.html' do
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

    it 'should render companies/new' do
      response.should render_template('new')
    end

    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'POST create' do
    def do_company
      post :create, :company => {:name => 'company', :email => 'fuck@gmail.com', :oficial_letter_signature => 'best wishes', :address_attributes => {:region => 'kyrovsky', :zip_code => '234', :house_number => '3', :housing => '4', :office_number => '1', :street => 'elm street', :phone_number => '666'}}
    end

    it 'should redirect to companies/show.html' do
      do_company
      response.should redirect_to(company_path(Company.last.id))
    end

    it 'should change companies count up by 1' do
      lambda { do_company }.should change{ Company.count }.by(1)
    end

    it 'should change addresses count up by 1' do
      lambda { do_company }.should change{ Address.count }.by(1)
    end
  end

  describe 'GET edit' do    
    def do_get
      get :edit, :id => @company.id
    end

    before (:each) do
      do_get
    end

    it 'should render companies/edit' do
      response.should render_template('edit')
    end
    
    it 'should be successful' do
      response.should be_success
    end

    it 'should find right company' do
      assigns[:company].id.should == @company.id
    end
  end

  describe 'PUT update' do
    def do_put
      put :update, :id => @company.id, :company => {:name => 'new_company'}
    end

    before(:each) do
      do_put
    end

    it 'should update company name' do
      assigns[:company].name.should == 'new_company'
    end
    
    it 'should redirect to companies/show.html' do
      response.should redirect_to @company
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @company.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to companies/index.html' do
      do_delete
      response.should redirect_to(companies_path)
    end

    it 'should change companies count down by 1' do
      lambda { do_delete }.should change{ Company.count }.by(-1)
    end
  end

  describe 'GET show' do
    def do_get
      get :show, :id => @company.id
    end

    before (:each) do
      do_get
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right company' do
      assigns[:company].id.should == @company.id
    end

    it 'should render companies/show.html' do
      response.should render_template('show')
    end
  end
end
