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
      @report = IncomeReport.new(report_params.merge(period: params[:period])).prepare
      @amount = @report.amount
    end

    def offices_income
      @report = OfficesIncomeReport.new(report_params.merge({
        period: params[:period],
        total_filter: params[:total_filter]
      })).prepare
      @amount = @report.amount
      @total = @report.total
      @total_names = current_company.offices
        .map {|office| { :id => office.id, :name => office.name } }
    end

    def managers_income
      @report = ManagersIncomeReport.new(report_params.merge({
        period: params[:period],
        total_filter: params[:total_filter]
      })).prepare
      @amount = @report.amount
      @total = @report.total
      @total_names = current_company.users.where(role: User::ROLES - ['admin', 'accountant'])
        .map {|user| { :id => user.id, :name => user.name_for_list } }
    end

    def margin
      @report = MarginReport.new(report_params.merge(period: params[:period])).prepare
      @amount = @report.amount
    end

    def offices_margin
      @report = OfficesMarginReport.new(report_params.merge({
        period: params[:period],
        total_filter: params[:total_filter]
      })).prepare
      @amount = @report.amount
      @total = @report.total
      @total_names = current_company.offices
        .map {|office| { :id => office.id, :name => office.name } }
    end

    def managers_margin
      @report = ManagersMarginReport.new(report_params.merge({
        period: params[:period],
        total_filter: params[:total_filter]
      })).prepare
      @amount = @report.amount
      @total = @report.total
      @total_names = current_company.users.where(role: User::ROLES - ['admin', 'accountant'])
        .map {|user| { :id => user.id, :name => user.name_for_list } }
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
      @amount  = @report.amount
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
