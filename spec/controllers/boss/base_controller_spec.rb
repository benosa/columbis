# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Boss::BaseController do
  before(:all) do
    @company = FactoryGirl.create(:company)
    @admin = FactoryGirl.create(:admin, :company => @company)
    @boss = FactoryGirl.create(:boss, :company => @admin.company, :office => @admin.office)
    @accountant = FactoryGirl.create(:accountant, :company => @admin.company, :office => @admin.office)
    @supervisor = FactoryGirl.create(:supervisor, :company => @admin.company, :office => @admin.office)
    @manager = FactoryGirl.create(:manager, :company => @admin.company, :office => @admin.office)
  end
  let(:user) { @admin }

  before do
    test_sign_in(user)
  end

  it 'before index user should not content widget' do
    Boss::Widget.where(:company_id => @company.id)
      .where(:user_id => @admin.id).length.should == 0
  end

  describe 'after first index' do
    before do
      get :index
    end

    it 'user should content factor widgets' do
      Boss::Widget.where(:company_id => @company.id).where(:user_id => @admin.id)
        .where(:widget_type => 'factor').length.should_not == 0
    end

    it 'user should content leader widgets' do
      Boss::Widget.where(:company_id => @company.id).where(:user_id => @admin.id)
        .where(:widget_type => 'leader').length.should_not == 0
    end

    it 'user should content chart widgets' do
      Boss::Widget.where(:company_id => @company.id).where(:user_id => @admin.id)
        .where(:widget_type => 'chart').length.should_not == 0
    end

    it 'user should content table widgets' do
      Boss::Widget.where(:company_id => @company.id).where(:user_id => @admin.id)
        .where(:widget_type => 'table').length.should_not == 0
    end
  end

  describe "users availability" do
    def actions
      [:index, :sort_widget, :save_widget_settings, :delete_widget]
    end
    context "when admin" do
      it do
        actions.each do |action|
          get action
          should respond_with :success
        end
      end
    end
    context "when boss" do
      let(:user) { @boss }
      it do
        actions.each do |action|
          get action
          should respond_with :success
        end
      end
    end
    context "when accountant" do
      let(:user) { @accountant }
      it do
        actions.each do |action|
          get action
          should_not respond_with :success
        end
      end
    end
    context "when supervisor" do
      let(:user) { @supervisor }
      it do
        actions.each do |action|
          get action
          should_not respond_with :success
        end
      end
    end
    context "when manager" do
      let(:user) { @manager }
      it do
        actions.each do |action|
          get action
          should_not respond_with :success
        end
      end
    end
  end
end