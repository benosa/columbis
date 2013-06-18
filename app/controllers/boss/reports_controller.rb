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
      @report = RepurchaseReport.new(report_params).prepare
      @count  = @report.count
    end

    def income
      type = 'Company'
      if params[:is_operator] == "true"
        @title = I18n.t('boss.reports.income.maturity_title')
        type = 'Operator'
      else
        @title = I18n.t('boss.reports.income.amount_title')
      end
      @amount_factor = params[:group] ? "amount_#{params[:group]}".to_sym : :amount
      @total_factor  = params[:group] ? "total_#{params[:group]}".to_sym : :total
      @report = IncomeReport.new(report_params.merge({
        view: params[:view],
        office_filter: params[:office_filter],
        manager_filter: params[:manager_filter],
        payment_type: type
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
    end

    def promotionchannel
      @channels = Claim.where(:company_id => current_company).map { |channel| channel.tourist_stat }.uniq
      
      @from_internet = get_channels_list("internet")
      @from_recommendations = get_channels_list("recommendations")
      @from_client = get_channels_list("client")
      @from_tv = get_channels_list("tv")
      @from_magazines = get_channels_list("magazines")
      @from_signboard = get_channels_list("signboard")
      
      intervals = {
                  values: [ @channels,
                            @from_internet,
                            @from_recommendations,
                            @from_client,
                            @from_tv,
                            @from_magazines,
                            @from_signboard
                          ],
                  names:  [ I18n.t('intervals.channels.names.default'),
                            I18n.t('intervals.channels.names.internet'),
                            I18n.t('intervals.channels.names.recommendations'),
                            I18n.t('intervals.channels.names.client'),
                            I18n.t('intervals.channels.names.tv'),
                            I18n.t('intervals.channels.names.magazines'),
                            I18n.t('intervals.channels.names.signboard')
                          ]
                }
      @report = PromotionChannelReport.new( report_params )
      @report.intervals = intervals
      @report.prepare
      @amount = @report.amount
      @count  = @report.count
      @total  = @report.total
    end

    private
    
      def get_channels_list(type)
        what = t('intervals.channels.values.' + type).uniq
        ret = @channels.find_all { |channel| what.any? { |inet| channel.mb_chars.downcase.scan(inet.mb_chars.downcase).size != 0} }
        if ret.length == 0
          ret = what
        end
        @channels -= ret
        ret
      end

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
