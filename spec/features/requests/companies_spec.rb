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

describe "company_list", js: true do
  include ActionView::Helpers
  clean_once do
    before(:all) do
      @company = create(:company, subdomain: 'domain')
      @company2 = create(:company, subdomain: 'domain2')
      @office = create(:office, company: @company)
      @office2 = create(:office, company: @company2)
      @admin = create(:admin, company: @company, office: @office)
      @manager = create(:manager, company: @company, office: @office)
      @manager2 = create(:manager, company: @company2, office: @office2)
      @tourist = create(:tourist, company: @company)
      @tourist2 = create(:tourist, company: @company2)
      @claim = create_list(:claim, 2, company: @company, user: @manager, office: @office, applicant: @tourist)
      @claim2 = create_list(:claim, 3, company: @company2, user: @manager2, office: @office2, applicant: @tourist2)
      @task = create(:task, company: @company, user: @manager)
      @task2 = create(:task, company: @company2, user: @manager2)
      login_as(@admin)
    end

    before {
      login_as(@admin)
    }
    subject { page }

    describe "create_company" do
      before do
        visit admin_index_path
      end

      it "should contain add button, filter by status and bug, links and data for each task" do
        save_screenshot
      end


    end
  end
end

describe "Company create:", js: true do
  include ActionView::Helpers
  clean_once do
    before(:all) do
      @company = FactoryGirl.create(:company, subdomain: 'domain')
    end

    before {
      @boss = FactoryGirl.create(:boss)
      login_as(@boss)
    }
    subject { page }

    describe "create_company" do
      before do
        visit new_dashboard_company_path
      end

      it "should create company" do
        fill_in 'company[name]', with: 'company_new'
        all("a.save").first.click
        should have_text(I18n.t('companies.messages.successfully_created_company'))
      end

      it "should create company and change user" do
        fill_in 'company[name]', with: 'company_new2'
        fill_in 'company[subdomain]', with: 'domain3'
        all("a.save").first.click
        should have_text(I18n.t('companies.messages.successfully_created_company'))
        @boss.reload
        @boss.subdomain.should == 'domain3'
      end

      it "should not create company - duplicate domain" do
        fill_in 'company[name]', with: 'company_new2'
        fill_in 'company[subdomain]', with: 'domain'
        all("a.save").first.click
        should have_text("#{I18n.t('activerecord.attributes.company.subdomain')} #{I18n.t('activerecord.errors.messages.taken')}")
      end

      it "should not create company - reserved domain" do
        fill_in 'company[name]', with: 'company_new2'
        fill_in 'company[subdomain]', with: 'demo'
        all("a.save").first.click
        should have_text("#{I18n.t('activerecord.attributes.company.subdomain')} #{I18n.t('errors.messages.reserved')}")
      end
    end
  end
end
