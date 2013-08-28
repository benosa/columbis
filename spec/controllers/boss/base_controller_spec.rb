# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Boss::BaseController do
  include ActionView::Helpers

  before(:all) do
    @company = FactoryGirl.create(:company)
    @user = FactoryGirl.create(:admin, :company => @company)
  end

  before do
    test_sign_in(@user)
  end

  it 'before index user should not content widget' do
    Boss::Widget.where(:company_id => @company.id)
      .where(:user_id => @user.id).length.should == 0
  end

  describe 'after first index' do
    before do
      get :index
    end

    it 'user should content factor widgets' do
      Boss::Widget.where(:company_id => @company.id).where(:user_id => @user.id)
        .where(:widget_type => 'factor').length.should_not == 0
    end

    it 'user should content leader widgets' do
      Boss::Widget.where(:company_id => @company.id).where(:user_id => @user.id)
        .where(:widget_type => 'leader').length.should_not == 0
    end

    it 'user should content chart widgets' do
      Boss::Widget.where(:company_id => @company.id).where(:user_id => @user.id)
        .where(:widget_type => 'chart').length.should_not == 0
    end

    it 'user should content table widgets' do
      Boss::Widget.where(:company_id => @company.id).where(:user_id => @user.id)
        .where(:widget_type => 'table').length.should_not == 0
    end
  end

end