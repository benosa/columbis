# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Clients base" do
  include ActionView::Helpers

  before(:all) do
    @boss = create_user_with_company_and_office(:admin)
    @company = @boss.company
    # @claims = create_claims_with_prerequisites(@company, :clientbase_claim, 10)
    @claims = create_list(:claim, 10, company: @company, office: @boss.office)
  end

  subject { page }

  describe "report", js: true do
    before do
      login_as @boss
      visit boss_reports_path(:clientsbase)
    end

    it 'should have period options' do
      page.should have_selector("select[data-param='period']")
      find("div.ik_select.period").click
      page.should have_selector("div.ik_select_list_inner ul li span",
        :text => I18n.t("report.period_options.day"))
      page.should have_selector("div.ik_select_list_inner ul li span",
        :text => I18n.t("report.period_options.month"))
      page.should have_selector("div.ik_select_list_inner ul li span",
        :text => I18n.t("report.period_options.week"))
      page.should have_selector("div.ik_select_list_inner ul li span",
        :text => I18n.t("report.period_options.year"))
    end

    it 'should start and end date' do
      page.should have_selector("input.datepicker.start_date.date.hasDatepicker")
      page.should have_selector("input.datepicker.end_date.date.hasDatepicker")
      find("input.datepicker.start_date.date.hasDatepicker").click
      page.should have_selector("table.ui-datepicker-calendar")
      find("input.datepicker.end_date.date.hasDatepicker").click
      page.should have_selector("table.ui-datepicker-calendar")
    end

    it 'should be button for clearing filters' do
      page.should have_selector("fieldset a.filter_reset#filter_reset")
    end

    it 'default period is month' do
      page.should have_selector("div.ik_select.period div.ik_select_link span",
        :text => I18n.t("report.period_options.month"))
    end

    it 'should be working period - day' do
      find("div.ik_select.period").click
      find("div.ik_select_list_inner ul li span", :text => I18n.t("report.period_options.day")).click
      page.should have_selector("div.ik_select.period div.ik_select_link span",
        :text => I18n.t("report.period_options.day"))
      date = Time.zone.now.beginning_of_day
      Payment.all.each do |payment|
        if payment.date_in.to_datetime < date
          page.should_not have_content(payment.payer.try(:full_name))
        else
          page.should have_content(payment.payer.try(:full_name))
        end
      end
    end
  end
end