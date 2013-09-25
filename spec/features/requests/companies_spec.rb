# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Companies:", js: true do
  include ActionView::Helpers

  clean_once do
    before(:all) do
      @boss = create_user_with_company_and_office(:boss)
      @company = @boss.company
    end

    before { login_as(@boss) }
    subject { page }

    describe "update company" do
      before do
        visit dashboard_edit_company_path
      end

      it "checking time zone on select box" do
        page.select '(GMT+01:00) Берлин', :from => 'company_time_zone'
        page.find("a.save").click
        page.should have_content 'Данные компании обновлены'
        page.should have_content '(GMT+01:00) Берлин'
        page.select '(GMT+04:00) Москва', :from => 'company_time_zone'
        page.find("a.save").click
        page.should have_content 'Данные компании обновлены'
        page.should have_content '(GMT+04:00) Москва'
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
end

describe "Company create:", js: true do
  include ActionView::Helpers
  before {
    @boss = FactoryGirl.create(:boss)#FactoryGirl.create(user, company: company, office: office, role: :boss)
    login_as(@boss)
  }

  describe "create_company" do
      before do
        visit new_dashboard_company_path
      end

      it "sholud create company" do
        #fill_in 'user[email]', with: @user.email
        all("a.save").first.click
        # wait_until { current_path == new_user_session_path }
        current_path.should eq(new_dashboard_company_path)
      end
    end


end
