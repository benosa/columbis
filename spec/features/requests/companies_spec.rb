# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Companyies:", js: true do
  include ActionView::Helpers

  before { login_as_admin }
  subject { page }

  describe "update company" do
    let(:user) { create(:admin, :company_id => company.id) }

    before do
      visit dashboard_edit_company_path
    end

    # it 'should not update an company, should show error message' do
    #   current_path.should eq(dashboard_edit_company_path)

    #   expect {
    #     fill_in "operator[name]", with: ""
    #     click_link I18n.t('save')
    #   }.to_not change(operator, :name).from(operator.name).to('')
    #   current_path.should eq("/operators/#{operator.id}")
    #   page.should have_selector("div.error_messages")
    # end

    # it 'should edit an operator, redirect to operators_path' do
    #   current_path.should eq(dashboard_edit_company_path)
      

      # expect {
      #   fill_in "company[name]", with: "Test"
      #   click_link I18n.t('save')
      #   company.reload
      # }.to change(company, :name).from(company.name).to('Test')
      # company.name.should eq("qweqwe")
      # current_path.should eq(dashboard_edit_company_path)
    # end

    # it 'delete operator, edit operator' do
    #   click_link "edit_operator_#{operator.id}"
    #   current_path.should eq("/operators/#{operator.id}/edit")
    #   expect{
    #     click_link I18n.t('delete')
    #   }.to change(Operator, :count).by(-1)
    # end
  # end
  end
end
