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

    def repurchase
      @report = RepurchaseReport.new(report_params.merge({minim: params[:minim].to_i})).prepare
      @count  = @report.count
      @total  = @report.total
    end

    def income
      type = false
      if params[:is_maturity] == "true"
        @title = I18n.t('boss.reports.income.maturity_title')
        type = true
      else
        @title = I18n.t('boss.reports.income.amount_title')
      end
      @amount_factor = params[:group] ? "amount_#{params[:group]}".to_sym : :amount
      @total_factor  = params[:group] ? "total_#{params[:group]}".to_sym : :total
      @report = IncomeReport.new(report_params.merge({
        view: params[:view],
        office_filter: params[:office_filter],
        manager_filter: params[:manager_filter],
        query_type: type
      })).prepare(@amount_factor)
      @total = @report.results[@total_factor]
      @all_offices = current_company.offices
      @all_managers = current_company.users.where(role: User::ROLES - ['admin', 'accountant'])
    end

    def tourduration
      @report = TourDurationReport.new(report_params).prepare
      @count  = @report.count
    end

    def hotelstars
      @report = HotelStarsReport.new(report_params).prepare
      @count  = @report.count
    end

    def clientsbase
      @report = ClientsBaseReport.new(report_params).prepare
      @count  = @report.count
      @amount = @report.amount
      @amount80 = @report.amount80
      @amount15 = @report.amount15
      @amount5 = @report.amount5
    end

    def normalcheck
      @report = NormalCheckReport.new(report_params.merge({view: params[:view]})).prepare
      @count  = @report.count
    end

    def increaseclients
      @report = IncreaseClientsReport.new(report_params).prepare
      @count  = @report.count
    end

    def promotionchannel
      @report = PromotionChannelReport.new(report_params).prepare
      @amount = @report.amount
      @count  = @report.count
    end

    def salesfunnel
      @report = SalesFunnelReport.new(report_params).prepare
      @count  = @report.count
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
        params_key = [params[:action]]
        params_key << params[:group] if params[:group]
        filter_key = "reports-#{params_key.join('-')}-last-filter".to_sym

        if params[:filter_reset]
          session[filter_key] = nil
        elsif request.xhr?
          filter_params = params.select do |k,v|
            not ([:controller, :action, :group].include?(k.to_sym) or v.blank?)
          end
          session[filter_key] = !filter_params.empty? ? filter_params : nil;
        elsif session[filter_key].present?
          params.reverse_merge!(session[filter_key])
        end
      end

  end
end
