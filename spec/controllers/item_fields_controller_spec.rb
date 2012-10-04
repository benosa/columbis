# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ItemFieldsController do
  def create_item_field
    @item_field = Factory(:item_field)
  end

  def create_catalog
    @catalog = Factory(:catalog)
  end

  before(:each) do
    create_catalog
    create_item_field
  end

  describe 'GET new' do
    def do_get
      get :new, :catalog_id => @catalog.id
    end

    before (:each) do
      do_get
    end

    it 'should render item_fields/new' do
      response.should render_template('new')
    end

    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'POST create' do
    def do_item_field
      post :create, :catalog_id => @catalog.id, :item_field => {:name => 'Surname', :catalog_id => @catalog.id}
    end

    it 'should redirect to catalogs/show.html' do
      do_item_field
      response.should redirect_to(catalog_path(ItemField.last.catalog_id))
    end

    it 'should change item_field count up by 1' do
      lambda { do_item_field }.should change{ ItemField.count }.by(1)
    end
  end

  describe 'GET edit' do
    def do_get
      get :edit, :catalog_id => @catalog.id, :id => @item_field.id 
    end
    
    before(:each) do
      do_get
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should render item_fields/edit.html' do
      response.should render_template('edit')
    end

    it 'should find right item_field' do
      assigns[:item_field].id.should == @item_field.id
    end
  end

  describe 'PUT update' do
    def do_put
      put :update, :catalog_id => @catalog.id, :id => @item_field.id, :item_field => {:name => 'middle_name'}
    end
    
    before(:each) do
      do_put
    end

    it 'should redirect to catalogs/show.html' do
      response.should redirect_to(catalog_path(@item_field.catalog_id))
    end

    it 'should change item_field name to name' do
      assigns[:item_field].name.should == 'middle_name'
    end
  end

  describe 'GET show' do
    def do_get
      get :show, :catalog_id => @catalog.id, :id => @item_field.id
    end
    
    before(:each) do
      do_get
    end

    it 'should be successfull' do
      response.should be_success
    end

    it 'should render item_fields/show.html' do
      response.should render_template('show')
    end

    it 'should show right item_field' do
      assigns[:item_field].id.should == @item_field.id
    end
  end

  describe 'GET index' do
    def do_get
      get :index, :catalog_id => @catalog.id
    end
  
    before(:each) do
     do_get
    end

    it 'should be successful' do
      response.should be_success                
    end

    it 'should render item_fields/index.html' do
      response.should render_template('index')                
    end

    it 'should find right catalog' do
      assigns[:catalog].id.should == @catalog.id
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :catalog_id => @catalog.id, :id => @item_field.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to catalogs/show.html' do
      do_delete
      response.should redirect_to(catalog_path(@item_field.catalog_id))
    end

    it 'should change item_fields count down by 1' do
      lambda { do_delete }.should change{ ItemField.count }.by(-1)
    end
  end
end
