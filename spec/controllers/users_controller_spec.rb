# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Dashboard::UsersController do
  include Devise::TestHelpers

  def create_users
    office = FactoryGirl.create(:office)
    @admin = FactoryGirl.create(:admin)
    @manager = FactoryGirl.create(:manager, :office_id => office.id)
    test_sign_in(@admin)
  end

  before { create_users }

  describe 'GET index' do
    before { get :index }

    it{ response.should be_success }

    it{ should assign_to(:users) }

    it{ response.should render_template('index') }
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @manager.id
    end

    it { response.should be_success }

    it 'should redirect to sign in' do
      do_delete
      response.should redirect_to(dashboard_users_url)
    end

    it { expect { do_delete }.to change{ User.count }.by(-1) }
  end

  describe 'GET edit' do
    before { get :edit, :id => @manager.id }

    it{ response.should render_template('edit')}
    it{ response.should be_success}
    it { should assign_to(:user).with(@manager) }
  end
end
