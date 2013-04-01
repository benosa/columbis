# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "User:", js: true do
  include ActionView::Helpers
  include UsersHelper

  before { login_as_admin }
  subject { page }
  let(:company) { create :company }
  let(:office) { create :office, company: company }


  # describe "user sign_up" do
  #   it "registration user" do 
  #     before do
  # #     visit new_user_registration_path
  # #   end
  # #   it "registration user" do
  # #     country = FactoryGirl.create(:country)
  # #     expect {
  # #       fill_in "user[email]", with: "test@mail.ru"
  # #       fill_in "user[login]", with: "testlogin"
  # #       fill_in "user[password]", with: "123456"
  # #       fill_in "user[password_confirmation]", with: "123456"
  # #       click_button "Зарегистрироваться"
  # #     }.to change(User, :count).by(+1)
  #   end
  # end

  
  describe "submit form" do
    let(:user) { create :admin, company: company, office: office }

    before do
      visit new_dashboard_user_path
    end

    describe "create user" do
      
      let(:user_attrs) { attributes_for(:user) }
      it{ current_path.should eq(new_dashboard_user_path) }

      it "should not create an user, should show error message" do
        expect {
          fill_in "user[login]", with: ""
          fill_in "user[last_name]", with: ""
          fill_in "user[first_name]", with: ""
          page.click_link I18n.t('save')
        }.to_not change(User, :count)
        page.current_path.should eq(dashboard_users_path)
        page.has_selector?('.error_messages')
      end

      it "should create an user" do
        expect {
          page.fill_in "user[login]", with: "qweqwe123123"
          page.fill_in "user[middle_name]", with: "ytrytrytry"
          page.fill_in "user[last_name]", with: "TESqwdqw3123T"
          page.fill_in "user[first_name]", with: "tecascascascst"
          page.fill_in "user[email]", with: "tes123123t@mail.ru"
          page.click_link I18n.t('save')
        }.to change(User, :count).by(1)
        page.current_path.should eq(dashboard_users_path)
      end
    end
  end

  describe "update user" do
    let(:user) { create :admin, company: company, office: office }

    before do
      user
      visit dashboard_users_path
    end

    it 'should not create an tourist, should show error message' do
      click_link "edit_user_#{user.id}"
      current_path.should eq edit_dashboard_user_path(user.id)
      expect {
        fill_in "user[login]", with: ""
        click_link I18n.t('save')
      }.to_not change(user, :login).from(user.login).to('')
      current_path.should eq dashboard_user_path(user.id) 
      page.should have_selector("div.error_messages")
    end

    it 'should edit an user, redirect to dashboard_users_path' do
      click_link "edit_user_#{user.id}"
      current_path.should eq edit_dashboard_user_path(user.id)
      expect {
        fill_in "user[login]", with: "test123456789"
        click_link I18n.t('save')
        user.reload
      }.to change(user, :login).from(user.login).to('test123456789')
    end

    it 'destroy user, edit user' do
      click_link "edit_user_#{user.id}"
      current_path.should eq edit_dashboard_user_path(user.id)

      expect{
        click_link I18n.t('delete')
      }.to change(User, :count).by(-1)
    end
  end

  describe "delete user" do 
    let(:user) { create(:admin) }

    before do
      user
      visit dashboard_users_path
    end

    it 'delete user' do
      expect{
        click_link "destroy_user_#{user.id}"
      }.to change(User, :count).by(-1)
    end
  end

  # describe "edit password user" do 
  #   let(:user) { create(:admin) }
  #   before do
  #     user
  #     visit dashboard_users_path
  #   end

  #   it 'edit password user' do
  #     click_link "edit_password_user#{user.id}"
  #     current_path.should eq edit_password_dashboard_user_path(user.id)
  #     page.has_link?(I18n.t('save'))

  #     expect{
  #       page.fill_in "user[password]", with: "123456789"
  #       #click_link I18n.t('save')
  #       page.click_on(I18n.t('save'))

  #       user.reload
  #     }

  #     #current_path.should eq dashboard_users_url


  #     visit new_user_session_path

  #     expect{
  #       fill_in "user[login]", :with => user.login
  #       fill_in "user[password]", :with => "123456qwsa"
  #       page.click_button 'user_session_submit'
  #     }
  #     current_path.should eq root_path
  #   end
  # end
  describe "edit password user" do 
    before do
      user
      visit dashboard_users_path
    end

    it 'edit password user' do
      click_link "edit_password_user#{user.id}"
      current_path.should eq edit_password_dashboard_user_path(user.id)
      save_and_open_page
      expect{
        fill_in "user[password]", with: "test123456"
        click_link I18n.t('save')
        user.reload
        save_and_open_page
      }.to change(user, :password).from(user.password).to('test123456')
    end
  end
end
