# -*- encoding : utf-8 -*-
require 'spec_helper'

describe CountriesController do
  before(:all) do
  	@company_one = FactoryGirl.create(:company)
  	@company_two = FactoryGirl.create(:company)
  	3.times { FactoryGirl.create(:country, :company_id => @company_one.id) }
  	3.times { FactoryGirl.create(:country, :company_id => @company_two.id) }
  	3.times { FactoryGirl.create(:open_country) }
  	@admin      = FactoryGirl.create(:admin, :company_id => @company_one.id)
  	@boss       = FactoryGirl.create(:boss, :company_id => @company_one.id)
  	@manager    = FactoryGirl.create(:manager, :company_id => @company_one.id)
  	@accountant = FactoryGirl.create(:accountant, :company_id => @company_one.id)
  end

  describe "GET index" do

    it "if user - admin then count = 9" do
      test_sign_in(@admin)
      get :index
      assigns(:countries).length.should == 9
    end

    it "if user - boss, manager or accountant then count = 6" do
      test_users = [@boss, @manager, @accountant]
      test_users.each do |user|
        test_sign_in(user)
        get :index
        assigns(:countries).length.should == 6
      end
    end
  end

  describe "GET show" do

    describe "his company country" do
      before do
        @country = Country.where(:company_id => @company_one.id).first
      end
      it "by all users should be true" do
        test_users = [@boss, @admin, @manager, @accountant]
        test_users.each do |user|
          test_sign_in(user)
          get :show, :id => @country.id
          should respond_with :success
          should assign_to(:country)
          response.should render_template('show')
        end
      end
    end

    describe "not his company country" do
      before do
        @country = Country.where(:company_id => @company_two.id).first
      end
      it "by admin should be true" do
        test_users = [@admin]
        test_users.each do |user|
          test_sign_in(user)
          get :show, :id => @country.id
          should respond_with :success
          should assign_to(:country)
          response.should render_template('show')
        end
      end
      it "by boss, manager or accountant should be false" do
        test_users = [@manager, @accountant, @boss]
        test_users.each do |user|
          test_sign_in(user)
          get :show, :id => @country.id
          should_not respond_with :success
        end
      end
    end

    describe "open countries" do
      before do
        @country = Country.where(:company_id => nil).first
      end
      it "by all users should be true" do
        test_users = [@boss, @admin, @manager, @accountant]
        test_users.each do |user|
          test_sign_in(user)
          get :show, :id => @country.id
          should respond_with :success
          should assign_to(:country)
          response.should render_template('show')
        end
      end
    end
  end

  describe "GET new" do

    describe "his company country" do
      before do
        @country = Country.where(:company_id => @company_one.id).first
      end
      it "by admin and boss should be true" do
        test_users = [@boss, @admin]
        test_users.each do |user|
          test_sign_in(user)
          get :new, :id => @country.id
          should respond_with :success
          should assign_to(:country)
          response.should render_template('new')
        end
      end
      it "by manager or accountant should be false" do
        test_users = [@manager, @accountant]
        test_users.each do |user|
          test_sign_in(user)
          get :new, :id => @country.id
          should_not respond_with :success
        end
      end
    end

    describe "not his company country" do
      before do
        @country = Country.where(:company_id => @company_two.id).first
      end
      it "by admin should be true" do
        test_users = [@admin]
        test_users.each do |user|
          test_sign_in(user)
          get :new, :id => @country.id
          should respond_with :success
          should assign_to(:country)
          response.should render_template('new')
        end
      end
      it "by boss, manager or accountant should be false" do
        test_users = [@manager, @accountant, @boss]
        test_users.each do |user|
          test_sign_in(user)
          get :new, :id => @country.id
          should_not respond_with :success
        end
      end
    end

    describe "open countries" do
      before do
        @country = Country.where(:company_id => nil).first
      end
      it "by admin should be true" do
        test_users = [@admin]
        test_users.each do |user|
          test_sign_in(user)
          get :new, :id => @country.id
          should respond_with :success
          should assign_to(:country)
          response.should render_template('new')
        end
      end
      it "by boss, manager or accountant should be false" do
        test_users = [@manager, @accountant, @boss]
        test_users.each do |user|
          test_sign_in(user)
          get :new, :id => @country.id
          should_not respond_with :success
        end
      end
    end

  end

  describe "GET edit" do

    describe "his company country" do
      before do
        @country = Country.where(:company_id => @company_one.id).first
      end
      it "by admin and boss should be true" do
        test_users = [@boss, @admin]
        test_users.each do |user|
          test_sign_in(user)
          get :edit, :id => @country.id
          should respond_with :success
          should assign_to(:country)
          response.should render_template('edit')
        end
      end
      it "by manager or accountant should be false" do
        test_users = [@manager, @accountant]
        test_users.each do |user|
          test_sign_in(user)
          get :edit, :id => @country.id
          should_not respond_with :success
        end
      end
    end

    describe "not his company country" do
      before do
        @country = Country.where(:company_id => @company_two.id).first
      end
      it "by admin should be true" do
        test_users = [@admin]
        test_users.each do |user|
          test_sign_in(user)
          get :edit, :id => @country.id
          should respond_with :success
          should assign_to(:country)
          response.should render_template('edit')
        end
      end
      it "by boss, manager or accountant should be false" do
        test_users = [@manager, @accountant, @boss]
        test_users.each do |user|
          test_sign_in(user)
          get :edit, :id => @country.id
          should_not respond_with :success
        end
      end
    end

    describe "open countries" do
      before do
        @country = Country.where(:company_id => nil).first
      end
      it "by admin should be true" do
        test_users = [@admin]
        test_users.each do |user|
          test_sign_in(user)
          get :edit, :id => @country.id
          should respond_with :success
          should assign_to(:country)
          response.should render_template('edit')
        end
      end
      it "by boss, manager or accountant should be false" do
        test_users = [@manager, @accountant, @boss]
        test_users.each do |user|
          test_sign_in(user)
          get :edit, :id => @country.id
          should_not respond_with :success
        end
      end
    end
  end

  describe "POST create" do
    before do
      test_sign_in @boss
    end

    def post_create
      post :create, :country => { :name => 'Russia', :company_id => @boss.company_id, :common => false }
    end

    it 'should redirect to countries list' do
      post_create
      response.should redirect_to(countries_path)
    end

    it 'should change tourists count up by 1' do
      expect { post_create }.to change{ Country.count }.by(1)
    end
  end

  describe "PUT update" do
    before do
      test_sign_in(@boss)
      @country = Country.where(:company_id => @boss.company_id).first
      put :update, id: @country.id, :country => { :name => "Russia" }
    end

    it { should assign_to(:country).with(@country) }
    it { should redirect_to(countries_path)  }

    it "changes country name " do
      expect {
        put :update, id: @country.id, :country => { :name => "Russia1" }
        @country.reload
      }.to change(@country, :name).to("Russia1")
    end
  end

  describe "DELETE destroy" do
    before do
      test_sign_in(@boss)
      @country = Country.where(:company_id => @boss.company_id).first
    end
    def do_delete
      delete :destroy, :id => @country.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should redirect to countries list' do
      do_delete
      response.should redirect_to(countries_path)
    end

    it 'should change country count down by 1' do
      expect { do_delete }.to change{ Country.count }.by(-1)
    end
  end
end