require 'spec_helper'

describe ItemsController do
  def create_item
    @item = Factory(:item)
  end

  def create_catalog
    @catalog = Factory(:catalog)
  end


  before(:each) do
    create_catalog
    create_item
  end

  describe 'GET new' do
    def do_get
      get :new, :catalog_id => @catalog.id
    end

    before (:each) do
      do_get
    end

    it 'should render items/new' do
      response.should render_template('new')
    end

    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'GET edit' do
    def do_get
      get :edit, :catalog_id => @catalog.id, :id => @item.id 
    end
    
    before(:each) do
      do_get
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should render items/edit.html' do
      response.should render_template('edit')
    end

    it 'should find right item_field' do
      assigns[:item].id.should == @item.id
    end
  end

  describe 'PUT update' do
    def do_put
      put :update, :catalog_id => @catalog.id, :id => @item.id
    end
    
    before(:each) do
      do_put
    end

    it 'should redirect to catalogs/show.html' do
      response.should redirect_to(catalog_path(@item.catalog_id))
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

    it 'should render items/index.html' do
      response.should render_template('index')                
    end

    it 'should find right catalog' do
      assigns[:catalog].should == @catalog
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :catalog_id => @catalog.id, :id => @item.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to catalogs/index.html' do
      do_delete
      response.should redirect_to catalogs_path
    end

    it 'should change item_fields count down by 1' do
      lambda { do_delete }.should change{ Item.count }.by(-1)
    end
  end

end
