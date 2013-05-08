# -*- encoding : utf-8 -*-
module Boss
  class ReportsController < ApplicationController
    include BossHelper

    before_filter { raise CanCan::AccessDenied unless is_admin? or is_boss? }
    before_filter :set_last_filter

    def operators
      @report = OperatorReport.new(report_params).prepare
      @amount = @report.amount_compact
      @items  = @report.items_compact
      @total  = @report.total
      render partial: 'operators' if request.xhr?
    end

    def directions
      @report = DirectionReport.new(report_params).prepare
      @amount = @report.amount_compact
      @items  = @report.items_compact
      @total  = @report.total
      render partial: 'directions' if request.xhr?
    end

    def tourprice
      @report = TourpriceReport.new(report_params).prepare
      @count  = @report.count
    end

    def income
      @report = IncomeReport.new(report_params).prepare
      @amount = @report.amount
      @amount_by_offices = @report.amount_by_offices
      # render partial: 'income' if request.xhr?
    end

    private

      def render(*args)
        options = args.extract_options!
        options = options.merge({ partial: params[:action] }) if request.xhr?
        super *(args << options)
      end

      def report_params
        options = params.select{ |k,v| [:start_date, :end_date, :row_count, :show_others].include?(k.to_sym) }
        options.merge({
          company: current_company,
          user: current_user,
          sort_col: params[:sort],
          sort_dir: params[:dir]
        })
      end

      def set_last_filter
        filter_key = "reports-#{params[:action]}-last-filter".to_sym

        if params[:filter_reset]
          session[filter_key] = nil
        elsif request.xhr?
          filter_params = params.select do |k,v|
            not ([:controller, :action].include?(k.to_sym) or v.blank?)
          end
          session[filter_key] = !filter_params.empty? ? filter_params : nil;
        elsif session[filter_key].present?
          params.reverse_merge!(session[filter_key])
        end
      end

  end
end
