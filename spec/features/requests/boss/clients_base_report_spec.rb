# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Boss::ClientsBaseReport, js: true do
  include ActionView::Helpers

  clean_once_with_sphinx do

    before(:all) do
      @boss = create_user_with_company_and_office(:boss)
      @company = @boss.company
      @count = 10
      create_claims_with_prerequisites(@company, :clientbase_claim, @count)
    end

    before do
      login_as @boss
      visit boss_reports_path(:clientsbase)
    end

    subject { page }

    it 'should period options' do
      page.have_selector("select[data-param='period']").should be_true
      page.find("div.ik_select_period").click
      page.have_selector("div.ik_select_list_inner ul li span",
        :text => I18n.t("report.period_options.day")).should be_true
      page.have_selector("div.ik_select_list_inner ul li span",
        :text => I18n.t("report.period_options.month")).should be_true
      page.have_selector("div.ik_select_list_inner ul li span",
        :text => I18n.t("report.period_options.week")).should be_true
      page.have_selector("div.ik_select_list_inner ul li span",
        :text => I18n.t("report.period_options.year")).should be_true
    end

    #it 'should properly set period params' do
    #end

    #it 'should properly set interval params' do
    #end

    #it 'should sort by sum' do
    #end

    #it 'should sort by tourist' do
    #end
  end
end