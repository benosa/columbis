# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Dashboard::CompaniesController do

  def create_company
    @company = FactoryGirl.create(:company)
    @user = FactoryGirl.create(:admin, :company_id => @company.id)
    test_sign_in(@user)
  end

  before { create_company }

  describe 'POST create' do

    def do_company
      post :create, :company => {
        :subdomain => FactoryGirl.sequence_by_name(:subdomain).next,
        :name => 'company',
        :email => 'company@example.com',
        :address_attributes => {
          :region => 'kyrovsky',
          :zip_code => '234',
          :house_number => '3',
          :housing => '4', :office_number => '1',
          :street => 'elm street',
          :phone_number => '666'
        }
      }
    end

    it 'should redirect to companies/show.html' do
      do_company
      response.should redirect_to(dashboard_edit_company_path)
    end

    it 'should change companies count up by 1' do
      expect { do_company }.to change{ Company.count }.by(1)
    end

    it 'should change addresses count up by 1' do
      expect { do_company }.to change{ Address.count }.by(1)
    end
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
