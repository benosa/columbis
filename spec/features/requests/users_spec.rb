# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "User:", js: true do
  include ActionView::Helpers
  include UsersHelper

  subject { page }

  before do
    @admin = login_as_admin
  end

  let(:company) { @admin.company }
  let(:office) { @admin.office }
  let(:user) { @admin }


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
    # let(:user) { create :admin, company: company, office: office }

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
          page.fill_in "user[phone]", with: "+77777777"
          page.click_link I18n.t('save')
        }.to change(User, :count).by(1)
        page.current_path.should eq(dashboard_users_path)
      end

      it "should create an user with password" do
        expect {
          page.fill_in "user[login]", with: "qweqwe123123"
          page.fill_in "user[middle_name]", with: "ytrytrytry"
          page.fill_in "user[last_name]", with: "TESqwdqw3123T"
          page.fill_in "user[first_name]", with: "tecascascascst"
          page.fill_in "user[email]", with: "tes123123t@mail.ru"
          page.fill_in "user[password]", with: "password"
          page.fill_in "user[phone]", with: "+77777777"
          page.click_link I18n.t('save')
        }.to change(User, :count).by(1)
        page.current_path.should eq(dashboard_users_path)
      end

      context "when valid attribute values" do
        include EmailSpec::Helpers
        include EmailSpec::Matchers

        it "should create an order, show success message and confirmation link are work" do
          expect {
            page.fill_in "user[login]", with: "qweqwe123123"
            page.fill_in "user[middle_name]", with: "ytrytrytry"
            page.fill_in "user[last_name]", with: "TESqwdqw3123T"
            page.fill_in "user[first_name]", with: "tecascascascst"
            page.fill_in "user[email]", with: "tes123123t@mail.ru"
            page.fill_in "user[phone]", with: "+77777777"
            page.click_link I18n.t('save')
          }.to change(User, :count).by(1)
          within ".messages" do
            should have_selector('.alert-success')
          end
          # Check email delivery with customer data, rest is checked in controller spec
          user = User.last
          open_last_email.should deliver_to user.email
          open_last_email.should have_body_text(/#{user.first_name}/)
          open_last_email.should have_body_text(/#{user.last_name}/)
          open_last_email.should have_body_text(/#{user.login}/)
          open_last_email.should have_body_text(/#{user.confirmation_token}/)
        end

      end
    end
  end

  describe "update user" do
    # let(:user) { create :admin, company: company, office: office }

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

    it 'update user password' do
      click_link "edit_user_#{user.id}"
      current_path.should eq edit_dashboard_user_path(user.id)
      expect {
        fill_in "user[password]", with: "password"
        click_link I18n.t('save')
        user.reload
      }.to change(user, :encrypted_password)
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
    # let(:user) { create(:admin) }

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
#  describe "edit user" do
    # let(:user) { create(:admin) }

#    before do
#      user
#      visit dashboard_users_path
#    end
  describe "users list" do
    clean_once_with_sphinx do

      def create_users
        @user = create_users_with_company_and_office(:user, 10).first
        @office = Office.where(:id => @user.office_id).first
        @users = User.where(:company_id => @user.company_id).map do |u|
          { :fio => u.full_name, :login => u.login,
            :role => u.role, :email => u.email
          }
        end
        #we will be use only first 10 users, to ignore pagination and etc.
        @count = @users.length > 10 ? 10 : @users.length
      end #create 10 users with the user who will be logged, set count of users and his office

      def take_elements(column_number)
        elements = []

        (3..(@count + 2)).to_a.each do |i|
          elements << page.find(:xpath, "//table/tbody/tr[#{i}]/td[#{column_number+1}]/p").text
        end
        elements
      end #this method return string array from one of the column

      def sort_users_asc_by (column)
        @users
          .sort{|x,y| x.values_at(column).first <=> y.values_at(column).first }
          .first(@count)
          .map{|u| u.values_at(column).first }
      end

      def sort_users_desc_by (column)
        @users
          .sort{|x,y| y.values_at(column).first <=> x.values_at(column).first }
          .first(@count)
          .map{|u| u.values_at(column).first }
      end

      before do
        page.click_link t('logout') #Exit and login by new user from new company
        create_users                #Create 10 new users
        login_as @user
        visit dashboard_users_path
      end

      it "sort columns" do
        columns = [:fio, :login, :role, :email]
        columns.each_with_index do |column, i|
          page.should have_selector("a[data-sort='#{column}']")
          if column != :fio
            page.find("a[data-sort='#{column}']").click
          end
          page.should have_selector("a.sort_active.asc[data-sort='#{column}']")
          take_elements(i).should == sort_users_asc_by(column)
          page.find("a[data-sort='#{column}']").click
          page.should have_selector("a.sort_active.desc[data-sort='#{column}']")
          take_elements(i).should == sort_users_desc_by(column)
        end
      end

      it "filter sotring" do
        @filter = @users.first[:fio].split(/[\s,.']/).first
        fill_in('filter', with: @filter)
        @users.each do |u|
          if u[:fio].index(@filter) or @office.name.index(@filter)
            page.has_content?(u[:fio]).should be_true
          else
            page.has_no_content?(u[:fio]).should be_true
          end
        end
      end
    end
  end
end
