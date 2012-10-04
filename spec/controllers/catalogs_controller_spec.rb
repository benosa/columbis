# -*- encoding : utf-8 -*-
require 'spec_helper'

describe CatalogsController do
  def create_catalog
    @catalog = Factory(:catalog)
  end

  before (:each) do
    create_catalog
  end

  describe 'GET index' do
    def do_get
      get :index
    end

    it 'should be successful' do
      do_get
      response.should be_success                
    end

    it 'should find all catalogs' do
      do_get
      assigns[:catalogs].size.should > 0
    end

    it 'should render catalogs/index.html' do
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

    it 'should render catalogs/new' do
      response.should render_template('new')
    end

    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'POST create' do
    def do_catalog
      post :create, :catalog => {:name => 'catalog'}
    end

    it 'should redirect to catalogs/show.html' do
      do_catalog
      response.should redirect_to(catalog_path(Catalog.last.id))
    end

    it 'should change catalog count up by 1' do
      lambda { do_catalog }.should change{ Catalog.count }.by(1)
    end
  end

  describe 'GET edit' do    
    def do_get
      get :edit, :id => @catalog.id
    end

    before (:each) do
      do_get
    end

    it 'should render catalogs/edit' do
      response.should render_template('edit')
    end
    
    it 'should be successful' do
      response.should be_success
    end

    it 'should find right catalog' do
      assigns[:catalog].id.should == @catalog.id
    end
  end

  describe 'PUT update' do
    def do_put
      put :update, :id => @catalog.id, :catalog => {:name => 'changed_catalog'}
    end

    before(:each) do
      do_put
    end

    it 'should change catalog name' do
      assigns[:catalog].name.should == 'changed_catalog'
    end
    
    it 'should redirect to catalogs/show.html' do
      response.should redirect_to @catalog
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @catalog.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to catalogs/index.html' do
      do_delete
      response.should redirect_to(catalogs_path)
    end

    it 'should change catalogs count down by 1' do
      lambda { do_delete }.should change{ Catalog.count }.by(-1)
    end
  end

  describe 'GET show' do
    def do_get
      get :show, :id => @catalog.id
    end

    before (:each) do
      do_get
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should find right catalog' do
      assigns[:catalog].id.should == @catalog.id
    end

    it 'should render catalogs/show.html' do
      response.should render_template('show')
    end
  end
end
