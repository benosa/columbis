# -*- encoding : utf-8 -*-
module Boss
  class ReportsController < ApplicationController
    include BossHelper

    def operators
      @report = OperatorReport.new(report_params).prepare
      @amount = @report.amount_compact
      @items  = @report.items_compact
      @total  = @report.total
      render partial: 'operators' if request.xhr?
    end

    private

      def report_params
        options = params.select{ |k,v| [:start_date, :end_date, :row_count, :show_others, :sort_col, :sort_dir].include?(k.to_sym) }
        options.merge({
          company: current_company,
          user: current_user
        })
      end

  end
end
