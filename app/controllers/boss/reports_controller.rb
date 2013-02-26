# -*- encoding : utf-8 -*-
module Boss
  class ReportsController < ApplicationController

    def operators
      @report = OperatorReport.new(report_options).prepare
      @amount = @report.amount_compact
      @items  = @report.items_compact
      @total  = @report.total
    end

    private

      def report_options
        options = params.select{ |k,v| [:start_date, :end_date, :row_count, :sort_col, :sort_dir].include?(k.to_sym) }
        options.merge({
          company: current_company,
          user: current_user
        })
      end

  end
end
