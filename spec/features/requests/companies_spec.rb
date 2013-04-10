# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Companyies:", js: true do
  include ActionView::Helpers
  
  before { login_as_admin }

  subject { page }
  let(:company) { create :company }
  let(:office) { create :office, company: company }
  let(:user) { create :admin, company: company, office: office }
  let(:country) { create :country }

  # describe "create company" do 
  #   before do
  #     visit new_user_registration_path
  #   end
  #   it "registration user" do
  #     country = FactoryGirl.create(:country)
  #     expect {
  #       fill_in "user[email]", with: "test@mail.ru"
  #       fill_in "user[login]", with: "testlogin"
  #       fill_in "user[password]", with: "123456"
  #       fill_in "user[password_confirmation]", with: "123456"
  #       click_button "Зарегистрироваться"
  #     }.to change(User, :count).by(+1)

  #     save_and_open_page
  #     expect { 
  #       fill_in "company[name]", with: "test2"
  #       click_link I18n.t('save')
  #       company.reload
  #     }.to change(Company, :count).by(+1)
  #   end
  # end

  describe "update company" do

    before do
      company
      visit dashboard_edit_company_path
    end

    it 'should not update an company, should show error message' do
      current_path.should eq dashboard_edit_company_path

      expect {
        fill_in "company[name]", with: ""
        click_link I18n.t('save')
      }.to_not change(company, :name).from(company.name).to('')
      page.should have_selector("div.error_messages")
    end

    it 'should update an company' do
      current_path.should eq dashboard_edit_company_path
      expect {
        fill_in "company[name]", with: "test"
        click_link I18n.t('save')
        company.reload
      }.to change(company, :name).from(company.name).to('test')
    end
  end
end
