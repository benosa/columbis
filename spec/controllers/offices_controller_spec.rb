require 'spec_helper'

describe Dashboard::OfficesController do

  before (:each) do
    @company = Factory(:company)
    @office = Factory(:office, :company => @company)

    @alien_company = Factory(:alien_company)
    @alien_office = Factory(:alien_office, :company => @alien_company)

    @boss = Factory(:boss, :company => @company, :office => @office)
    @manager = Factory(:manager, :company => @company, :office => @office)

    @alien_boss = Factory(:alien_boss, :company => @alien_company, :office => @alien_office)

  end

  describe'for boss' do
    before (:each) do
      stub_current_user(@boss)
    end

    describe 'GET index' do
      def do_get
        get :index
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should find available offices' do
        do_get
        assigns[:offices].should eq(Office.where(:company_id => @company.id))
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

      it 'should redirect to offices/index.html' do
        do_office
        response.should redirect_to(offices_path)
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

      it 'should redirect to offices/index.html' do
        response.should redirect_to(offices_path)
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
  end

  describe 'for alien boss' do
    before (:each) do
      stub_current_user(@alien_boss)
    end

    describe 'GET index' do
      def do_get
        get :index
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should find available offices' do
        do_get
        assigns[:offices].map(&:id).should eq(Office.where(:company_id => @alien_company.id).map(&:id))
      end
    end

    describe 'GET edit' do
      before (:each) do
        get :edit, :id => @office.id
      end

      it 'should redirect to root' do
        response.should redirect_to(root_path)
      end

      it 'should not be successful' do
        response.should_not be_success
      end
    end

    describe 'PUT update' do
      before(:each) do
        put :update, :id => @office.id, :office => {:name => 'mailware'}
      end

      it 'should not change office name' do
        assigns[:office].name.should_not eq('mailware')
      end

      it 'should redirect to offices/index.html' do
        response.should redirect_to(root_path)
      end
    end
  end
end
