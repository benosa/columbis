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
  clean_once_with_sphinx do
    before(:all) do
      @company = create(:company)
      @company2 = create(:company)
      @company.owner = create(:boss, company: @company)
      @company2.owner = create(:boss, company: @company2)
      @company.save
      @company2.save
      @office = create(:office, company: @company)
      @admin = create(:admin, company: @company, office: @office)
      @manager = create(:manager, company: @company, office: @office)
      @tourists = create_list(:tourist, 6, company: @company)
      @claims = create_list(:claim, 5, company: @company, user: @manager, office: @office, applicant: @tourists[0])
      @tasks = create_list(:task, 4, company: @company, user: @manager)
      ThinkingSphinx::Test.index
    end

    subject { page }

    describe "companies list show" do
      before do
        login_as(@admin)
        visit admin_index_path
      end

      it "should contain filter and company field values" do
        should have_field("filter")
        should have_selector('td', :text => l(@company.created_at, format: :long))
        should have_selector('td', :text => @company.name)
        should have_selector('td', :text => "#{@company.owner.last_name} #{@company.owner.first_name} #{@company.owner.middle_name}")
        should have_selector('td', :text => @company.owner.email)
        should have_selector('td', :text => @company.owner.phone)
        should have_selector('td', :text => @company.subdomain)
        should have_selector('td', :text => @company.offices_count)
        should have_selector('td', :text => @company.users_count)
        should have_selector('td', :text => @company.claims_count)
        should have_selector('td', :text => @company.tourists_count)
        should have_selector('td', :text => @company.tasks_count)

        should have_selector('td', :text => @company2.subdomain)
      end

      it "should find @company" do
        should have_field("filter")
        fill_in('filter', with: @company.subdomain)
        should have_selector('td', :text => @company.subdomain)

        should_not have_selector('td', :text => @company2.subdomain)
      end
    end

    describe "no_access_to_company_list" do
      before do
        login_as(@manager)
        visit admin_index_path
      end

      it "should contain filter and company field values" do
        should have_text(I18n.t('unauthorized.default'))
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
      @boss = FactoryGirl.create(:boss_without_company)
      login_as(@boss)
    }
    subject { page }

    describe "create company" do
      before do
        visit new_dashboard_company_path
      end

      it "should create company" do
        fill_in 'company[name]', with: 'company_new'
        all("a.save").first.click
        should have_text(I18n.t('companies.messages.successfully_updated_company'))
      end

      it "should create company and change user" do
        fill_in 'company[name]', with: 'company_new2'
        fill_in 'company[subdomain]', with: 'domain3'
        all("a.save").first.click
        should have_text(I18n.t('companies.messages.successfully_updated_company'))
        @boss.reload
        @boss.subdomain.should == 'domain3'
      end

      it "should not create company - duplicate domain" do
        fill_in 'company[name]', with: 'company_new2'
        fill_in 'company[subdomain]', with: 'domain'
        all("a.save").first.click
        should have_text("#{I18n.t('activerecord.attributes.company.subdomain')} #{I18n.t('activerecord.errors.messages.subdomain_taken')}")
      end

      it "should not create company - reserved domain" do
        fill_in 'company[name]', with: 'company_new2'
        fill_in 'company[subdomain]', with: 'demo'
        all("a.save").first.click
        should have_text("#{I18n.t('activerecord.attributes.company.subdomain')} #{I18n.t('activerecord.errors.messages.subdomain_taken')}")
      end
    end
  end
end
