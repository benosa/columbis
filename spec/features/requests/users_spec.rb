# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Logged_user:", js: true do
  include ActionView::Helpers
  include UsersHelper
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  clean_once do
    before(:all) do
      @boss = create_user_with_company_and_office :boss
      @manager = FactoryGirl.create(:manager, company: @boss.company, office: @boss.office)
    end

    before { login_as @boss }
    subject { page }

    let(:company) { @boss.company }
    let(:office) { @boss.office }
    let(:user) { @manager }

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
          user_attrs = attributes_for(:user)
          login = FactoryGirl.generate(:login)
          expect {
            user_attrs.each do |atr, value|
              fill_in "user[#{atr}]", with: value if page.has_field?("user[#{atr}]")
            end
            fill_in "user[login]", with: login
            page.click_link I18n.t('save')
          }.to change(User, :count).by(1)
          page.current_path.should eq(dashboard_users_path)
          within ".messages" do
            should have_selector('.alert-success')
          end
          user = User.where(login: login).first
          last_user_email = open_last_email_for(user.email)
          last_user_email.should deliver_to user.email
          last_user_email.should have_body_text(/#{user.first_name}/)
          last_user_email.should have_body_text(/#{user.last_name}/)
          last_user_email.should have_body_text(/#{user.login}/)
          last_user_email.should have_body_text(/#{user.confirmation_token}/)
        end

        it "should create an user with password" do
          user_attrs = attributes_for(:user)
          login = FactoryGirl.generate(:login)
          password = ('a'..'z').to_a.shuffle.first(8).join
          expect {
            user_attrs.each do |atr, value|
              fill_in "user[#{atr}]", with: value if page.has_field?("user[#{atr}]")
            end
            fill_in "user[password]", with: password
            fill_in "user[login]", with: login
            page.click_link I18n.t('save')
          }.to change(User, :count).by(1)
          page.current_path.should eq(dashboard_users_path)
          within ".messages" do
            should have_selector('.alert-success')
          end
          user = User.where(login: login).first
          last_user_email = open_last_email_for(user.email)
          last_user_email.should deliver_to user.email
          last_user_email.should have_body_text(/#{user.login}/)
          last_user_email.should have_body_text(/#{password}/)
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

      it 'should update user' do
        login = FactoryGirl.generate(:login)
        click_link "edit_user_#{user.id}"
        current_path.should eq edit_dashboard_user_path(user.id)
        expect {
          fill_in "user[login]", with: login
          click_link I18n.t('save')
          user.reload
        }.to change(user, :login).from(user.login).to(login)
      end

      it 'update user password' do
        password = ('a'..'z').to_a.shuffle.first(8).join
        click_link "edit_user_#{user.id}"
        current_path.should eq edit_dashboard_user_path(user.id)
        expect {
          fill_in "user[password]", with: password
          click_link I18n.t('save')
          user.reload
        }.to change(user, :encrypted_password)
        last_email = open_last_email
        last_email.should deliver_to user.email
        last_email.should have_body_text(/#{user.login}/)
        last_email.should have_body_text(/#{password}/)
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
        @manager2 = FactoryGirl.create(:manager, company: @boss.company, office: @boss.office)
        visit dashboard_users_path
      end

      it 'delete user' do
        expect{
          click_link "destroy_user_#{@manager2.id}"
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

  end

  clean_once_with_sphinx do
    describe "users list" do

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

describe "Unlogged user", js: true do
  include ActionView::Helpers
  include ApplicationHelper
  include UsersHelper
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  clean_once do
    before(:all) do
      @user = create_user_with_company_and_office
    end

    subject { page }

    describe "user_login" do

      it 'should not sign in, because of filling hiden field' do
        visit new_user_session_path
        fill_in 'user[login]', with: @user.login
        fill_in 'user[check]', with: @user.login
        fill_in 'user[password]', with: @user.password
        find("input[name='commit']").click
        page.current_path.should eq(new_user_session_path)
      end

      it 'should sign in' do
        visit new_user_session_path
        fill_in 'user[check]', with: @user.login
        fill_in 'user[password]', with: @user.password
        find("input[name='commit']").click
        page.current_path.should eq(root_path)
      end
    end

    describe "user_confirm" do
      before(:all) do
        @user_confirm = FactoryGirl.create(:boss, confirmed_at: "")
      end
      it 'should not send confirm, because of filling hiden field' do
        visit new_user_confirmation_path
        fill_in 'user[email]', with: @user_confirm.email
        fill_in 'user[check]', with: @user_confirm.email
        find("input[name='commit']").click
        page.current_path.should eq(new_user_confirmation_path)
      end

      it 'should show email exist error' do
        visit new_user_confirmation_path
        fill_in 'user[check]', with: @user_confirm.email.to_s + '1'
        find("input[name='commit']").click
        page.current_path.should eq(user_confirmation_path)
        page.should have_text("#{I18n.t('users.index.email')} #{I18n.t('errors.messages.maybe_not_found')}")
      end

      it 'should send confirm' do
        visit new_user_confirmation_path
        fill_in 'user[check]', with: @user_confirm.email
        find("input[name='commit']").click
        open_last_email.should deliver_to @user_confirm.email
        page.current_path.should eq(new_user_session_path)
      end


    end

    describe "user new pass" do

      it 'should create email, with reset password instructions' do
        visit new_user_password_path
        fill_in 'user[check]', with: @user.email
        find("input[name='commit']").click
        page.current_path.should eq(new_user_session_path)
        @user.reload
        open_last_email.should deliver_to @user.email
        open_last_email.should have_body_text(/#{@user.reset_password_token}/)
        visit edit_user_password_path + '?reset_password_token=' + @user.reset_password_token.to_s
        fill_in 'user[password]', with: '222222'
        fill_in 'user[password_confirmation]', with: '222222'
        find("input[name='commit']").click
        page.current_path.should eq(root_path)
      end

      it 'should show error email not exist' do
        visit new_user_password_path
        fill_in 'user[check]', with: FactoryGirl.generate(:email)
        find("input[name='commit']").click
        # wait_until { current_path == user_password_path }
        page.should have_text("#{I18n.t('users.index.email')} #{I18n.t('errors.messages.maybe_not_found')}")
      end

      it 'should not show error email not exist, because of filling hiden field' do
        visit new_user_password_path
        fill_in 'user[email]', with: FactoryGirl.generate(:email)
        fill_in 'user[check]', with: FactoryGirl.generate(:email)
        find("input[name='commit']").click
        # wait_until { current_path == user_password_path }
        page.current_path.should eq(new_user_password_path)
        page.should_not have_text("#{I18n.t('users.index.email')} #{I18n.t('errors.messages.maybe_not_found')}")
      end

      it 'should create email, with new password' do
        visit new_user_password_path
        fill_in 'user[check]', with: @user.email
        find("label[for='user_generate_password']").click
        find("input[name='commit']").click
        # wait_until { current_path == new_user_session_path }
        page.current_path.should eq(new_user_session_path)
        open_last_email.should deliver_to @user.email
        open_last_email.subject.should == I18n.t('devise.mailer.new_password_instructions.subject')
      end
    end

    describe "registration" do
      before(:all) do
        @user2 = FactoryGirl.create(:boss, subdomain: 'newcomp', email: 'newuser@mail.ru', phone: '766678888')
        @attr = attributes_for :user
      end
      it 'should create new user and company' do
        visit new_user_registration_path
        fill_in 'user[subdomain]', with: @attr[:subdomain]
        fill_in 'user[check]', with: @attr[:email]
        fill_in 'user[first_name]', with: @attr[:first_name]
        fill_in 'user[last_name]', with: @attr[:last_name]
        fill_in 'user[phone]', with: @attr[:phone]
        find("input[name='commit']").click
        @newuser = User.where(email: @attr[:email]).first
        last_user_email = open_last_email_for(@attr[:email])
        last_user_email.should deliver_to @attr[:email]
        last_user_email.should have_body_text(/#{@newuser.confirmation_token}/)
        html.should include(I18n.t('devise.registrations.user.signed_up_but_unconfirmed'))
        visit user_confirmation_path + '?confirmation_token=' + @newuser.confirmation_token.to_s
        page.should have_text(I18n.t('you_must_add_office'))
        #current_path.should eq(dashboard_edit_company_path)
      end

      it 'should not create new user - duplicate fields' do

        visit new_user_registration_path
        fill_in 'user[subdomain]', with: 'newcomp'
        fill_in 'user[check]', with: 'newuser@mail.ru'
        fill_in 'user[first_name]', with: 'test'
        fill_in 'user[last_name]', with: 'testing'
        fill_in 'user[phone]', with: '766678888'
        find("input[name='commit']").click
        should have_text("#{I18n.t('activerecord.attributes.user.subdomain')} #{I18n.t('activerecord.errors.messages.subdomain_taken')}")
        should have_text("#{I18n.t('activerecord.attributes.user.email')} #{I18n.t('activerecord.errors.messages.taken')}")
        should have_text("#{I18n.t('activerecord.attributes.user.phone')} #{I18n.t('activerecord.errors.messages.taken')}")
      end

      it 'should not create new user - reserved subdomain' do
        visit new_user_registration_path
        fill_in 'user[subdomain]', with: 'demo'
        fill_in 'user[check]', with: 'newuser2@mail.ru'
        fill_in 'user[first_name]', with: 'test2'
        fill_in 'user[last_name]', with: 'testing2'
        fill_in 'user[phone]', with: '7666788882'
        find("input[name='commit']").click
        should have_text("#{I18n.t('activerecord.attributes.user.subdomain')} #{I18n.t('activerecord.errors.messages.subdomain_taken')}")
      end

      it 'should not show error, because of filling hiden field' do
        visit new_user_registration_path
        fill_in 'user[email]', with: FactoryGirl.generate(:email)
        fill_in 'user[subdomain]', with: 'demo'
        find("input[name='commit']").click
        should_not have_text("#{I18n.t('activerecord.attributes.user.subdomain')} #{I18n.t('errors.messages.reserved')}")
        page.current_path.should eq(new_user_registration_path)
      end
    end

  end

end
