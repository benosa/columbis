# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Dashboard::CompaniesController do

  before(:all) do
    @company = FactoryGirl.create(:company)
    @admin = FactoryGirl.create(:admin, :company => @company)
  end

  let(:user) { @admin }

  before do
    test_sign_in(user)
  end

  describe 'PUT update' do
    before { put :update, id: @company.id, company: attributes_for(:company, name: 'new_company') }
    it { should assign_to(:company).with(@company) }
    #it { should set_the_flash[:notice].to  t('companies.messages.successfully_updated_company') }
    it { should redirect_to dashboard_edit_company_path }

    it "changes company name " do
      expect {
        put :update, id: @company.id, company: attributes_for(:company, name: 'new_company2')
        @company.reload
      }.to change(@company, :name).to('new_company2')
    end
  end
end
