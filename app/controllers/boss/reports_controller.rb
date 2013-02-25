# -*- encoding : utf-8 -*-
class Boss::ReportsController < ApplicationController

  before_filter :load_report

  def operators
    report = @report.operators(order: params[:order], rows: params[:rows] || 10)
    @amount, @items, @total = report[:amount], report[:items], report[:total]
  end

  private

    def load_report
      report_options = {
        company: current_company,
        user: current_user,
        start_date: params[:start_date],
        end_date: params[:end_date]
      }
      @report = Boss::Report.new(report_options)
    end

end
