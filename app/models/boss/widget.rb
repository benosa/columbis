# -*- encoding : utf-8 -*-
module Boss
  class Widget < ActiveRecord::Base

    VIEWS = %w[small small2 medium large].freeze
    TYPES = %w[factor chart table].freeze
    NAMES = %w[claim income normalcheck tourprice margin].freeze
    PERIODS = %w[day week month].freeze

    attr_accessible :company_id, :name, :position, :settings, :title, :user_id, :view, :widget_type

    belongs_to :user
    belongs_to :company

    serialize :settings, Hash

    def self.create_default_widgets(user, company)
      widgets = []
      widgets << create_default_widget(user, company, 1,
        'boss.active_record.widget.factors.claims', 'small', 'factor', 'claim')
      widgets << create_default_widget(user, company, 2,
        'boss.active_record.widget.factors.incomes', 'small', 'factor', 'income')
      widgets << create_default_widget(user, company, 3,
        'boss.active_record.widget.factors.normalcheck', 'small', 'factor', 'normalcheck')
      widgets << create_default_widget(user, company, 4,
        'boss.active_record.widget.factors.tourprice', 'small', 'factor', 'tourprice')
      widgets << create_default_widget(user, company, 5,
        'boss.active_record.widget.factors.margin', 'small', 'factor', 'margin')
      widgets << create_default_widget(user, company, 6,
        'boss.active_record.widget.charts.income_title_day', 'small2', 'chart', 'income',
        {:period => 'day', :yAxis_text => 'RUR'})
      widgets << create_default_widget(user, company, 7,
        'boss.active_record.widget.charts.margin_title_week', 'large', 'chart', 'margin',
        {:period => 'week', :yAxis_text => 'boss.active_record.widget.charts.percent'})
      widgets << create_default_widget(user, company, 8,
        'boss.active_record.widget.charts.claim_title_month', 'medium', 'chart', 'claim',
        {:period => 'month', :yAxis_text => 'boss.active_record.widget.charts.claim_number'})
    end

    def self.create_default_widget(user, company, position, title, view, widget_type, name, settings = {})
      widget = Widget.new(:user_id => user.id, :company_id => company.id, :position => position,
        :title => title, :view => view, :widget_type => widget_type,
        :name => name, :settings => settings)
      widget.save
      widget
    end

    def widget_data
      case widget_type
      when 'factor'
        factor_widget_data
      when 'chart'
        chart_widget_data
      end
    end

    def factor_widget_data
      case name
      when 'claim'
        claims_factor_data
      when 'income'
        income_factor_data
      when 'normalcheck'
        normalcheck_factor_data
      when 'tourprice'
        tourprice_factor_data
      when 'margin'
        margin_factor_data
      end
    end

    def chart_widget_data
      end_date = Time.zone.now.to_date
      case settings[:period]
      when 'day'
        start_date = end_date - 6.days
      when 'week'
        start_date = end_date - (7*6-1).days
        start_date = start_date - (start_date.cwday-1).days
      else
        start_date = (end_date - 6.months)
        start_date = start_date - start_date.day + 1.days
      end

      case name
      when 'income'
        income_chart_data(start_date, end_date)
      when 'margin'
        margin_chart_data(start_date, end_date)
      when 'claim'
        claim_chart_data(start_date, end_date)
      end
    end



    private

    def claims_factor_data
      data = Claim.select("COUNT(id) AS total, reservation_date AS date")
        .where(company_id: company.id)
        .where(excluded_from_profit: false)
        .where(canceled: false)
        .where("reservation_date >= ?", (Time.zone.now - 61.days).to_date)
        .group(:reservation_date)
        .order("reservation_date DESC")
      total = Claim.select("COUNT(id) AS total")
        .where(company_id: company.id)
        .where(excluded_from_profit: false)
        .where(canceled: false)
      data = data.map{|d| [d.try(:date).to_date, d.try(:total).to_i]}
      create_factor_data(data).merge(:total => {
        title: I18n.t('boss.active_record.widget.factors.in_all'),
        data: "#{total.first.try('total')} <span>#{I18n.t('boss.active_record.widget.factors.claim_number')}<span/>".html_safe,
        text: I18n.t('boss.active_record.widget.factors.claim_text')
      })
    end

    def income_factor_data
      data = Payment.select("SUM(amount) AS total, date_in AS date")
        .where(company_id: company.id)
        .where(recipient_type: 'Company')
        .where(approved: true)
        .where(canceled: false)
        .where("date_in >= ?", (Time.zone.now - 61.days).to_date)
        .joins("INNER JOIN claims ON payments.claim_id = claims.id")
          .where(claims: {excluded_from_profit: false})
          .where(claims: {canceled: false})
        .group(:date)
        .order("date DESC")
      total = Payment.select("SUM(amount) AS total")
        .where(company_id: company.id)
        .where(recipient_type: 'Company')
        .where(approved: true)
        .where(canceled: false)
        .joins("INNER JOIN claims ON payments.claim_id = claims.id")
          .where(claims: {excluded_from_profit: false})
          .where(claims: {canceled: false})
      data = data.map{|d| [d.try(:date).to_date, d.try(:total).to_i]}
      create_factor_data(data).merge(:total => {
        title: I18n.t('boss.active_record.widget.factors.in_all'),
        data: "#{commas(total.first.try('total'))} <span>#{I18n.t('boss.active_record.widget.factors.payment_sum')}<span/>".html_safe,
        text: I18n.t('boss.active_record.widget.factors.income_text')
      })
    end

    def normalcheck_factor_data
      data = Claim.select("AVG(primary_currency_price) AS total, reservation_date AS date")
        .where(company_id: company.id)
        .where(excluded_from_profit: false)
        .where(canceled: false)
        .where("reservation_date >= ?", (Time.zone.now - 61.days).to_date)
        .group(:reservation_date)
        .order("reservation_date DESC")
      total = Claim.select("AVG(primary_currency_price) AS total")
        .where(company_id: company.id)
        .where(excluded_from_profit: false)
        .where(canceled: false)
      data = data.map{|d| [d.try(:date).to_date, d.try(:total).to_i]}
      create_factor_data(data, true).merge(:total => {
        title: I18n.t('boss.active_record.widget.factors.normal'),
        data: "#{commas(total.first.try('total').to_i)} <span>#{I18n.t('boss.active_record.widget.factors.payment_sum')}<span/>".html_safe,
        text: I18n.t('boss.active_record.widget.factors.normalcheck_text')
        })
    end

    def tourprice_factor_data
      data_count = TouristClaim.select("claims.reservation_date AS date, COUNT(tourist_id) as count")
        .joins("INNER JOIN claims ON tourist_claims.claim_id = claims.id")
          .where(claims: {excluded_from_profit: false})
          .where(claims: {canceled: false})
          .where("claims.reservation_date >= ?", (Time.zone.now - 61.days).to_date)
        .group(:date)
        .order("claims.reservation_date DESC")
      data_amount = Claim.select("SUM(primary_currency_price) AS amount, reservation_date AS date")
        .where(company_id: company.id)
        .where(excluded_from_profit: false)
        .where(canceled: false)
        .where("reservation_date >= ?", (Time.zone.now - 61.days).to_date)
        .group(:date)
        .order("reservation_date DESC")

      data = []
      data_count.each_with_index do |count, i|
        normal = data_count[i].try(:count).to_i == 0 ? 0 : data_amount[i].try(:amount).to_i/data_count[i].try(:count).to_i
        data << [count.date.to_date, normal]
      end

      total_count = TouristClaim.select("COUNT(tourist_id) as count")
        .joins("INNER JOIN claims ON tourist_claims.claim_id = claims.id")
          .where(claims: {excluded_from_profit: false})
          .where(claims: {canceled: false})
      total_amount = Claim.select("SUM(primary_currency_price) AS amount")
        .where(company_id: company.id)
        .where(excluded_from_profit: false)
        .where(canceled: false)

      total = []
      total_count.each_with_index do |count, i|
        normal = total_count[i].try(:count).to_i == 0 ? 0 : total_amount[i].try(:amount).to_i/total_count[i].try(:count).to_i
        total << normal
      end
      total = total == [] ? 0 : total.first

      create_factor_data(data, true).merge(
        :total => {
          title: I18n.t('boss.active_record.widget.factors.normal'),
          data: "#{commas(total)} <span>#{I18n.t('boss.active_record.widget.factors.payment_sum')}<span/>".html_safe,
          text: I18n.t('boss.active_record.widget.factors.normalcheck_text')
        })
    end

    def margin_factor_data
      data = Claim.select("AVG(profit_in_percent_acc) AS total, reservation_date AS date")
        .where(company_id: company.id)
        .where(excluded_from_profit: false)
        .where(canceled: false)
        .where("reservation_date >= ?", (Time.zone.now - 61.days).to_date)
        .group(:reservation_date)
        .order("reservation_date DESC")
      total = Claim.select("AVG(profit_in_percent_acc) AS total")
        .where(company_id: company.id)
        .where(excluded_from_profit: false)
        .where(canceled: false)
      data = data.map{|d| [d.try(:date).to_date, d.try(:total).to_f.round(2)]}
      create_factor_data(data, true).merge(:total => {
        title: I18n.t('boss.active_record.widget.factors.normal'),
        data: "#{commas(total.first.try('total').to_f.round(2))} <span>%<span/>".html_safe,
        text: I18n.t('boss.active_record.widget.factors.margin_text')
      })
    end

    def create_factor_data(data, is_mean = false)
      now_day        = get_by_date(data, is_mean, Time.zone.now.to_date,         Time.zone.now.to_date        )
      previous_day   = get_by_date(data, is_mean, Time.zone.now.to_date-1.days,  Time.zone.now.to_date-1.days )
      now_week       = get_by_date(data, is_mean, Time.zone.now.to_date-6.days,  Time.zone.now.to_date        )
      previous_week  = get_by_date(data, is_mean, Time.zone.now.to_date-13.days, Time.zone.now.to_date-7.days )
      now_month      = get_by_date(data, is_mean, Time.zone.now.to_date-30.days, Time.zone.now.to_date        )
      previous_month = get_by_date(data, is_mean, Time.zone.now.to_date-61.days, Time.zone.now.to_date-31.days)
      {
        data: [
          [ I18n.t('boss.active_record.widget.factors.today'),
            I18n.t('boss.active_record.widget.factors.week'),
            I18n.t('boss.active_record.widget.factors.month')],
          [commas(now_day.to_s), commas(now_week.to_s), commas(now_month.to_s)],
          [get_class(now_day, previous_day),
            get_class(now_week, previous_week),
            get_class(now_month, previous_month)],
          [get_percent(now_day, previous_day),
            get_percent(now_week, previous_week),
            get_percent(now_month, previous_month)]
        ]
      }
    end

    def get_by_date(data, is_mean = false, start_date, end_date)
      avg_or_sum( data.select{|d| (d[0] >= start_date) && (d[0] <= end_date)}.map{|d| d[1]},
        is_mean)
    end

    def avg_or_sum(array, is_mean = false)
      array.delete(0)
      if is_mean
        array.blank? ? 0 : (array.sum/array.length).round(2)
      else
        array.blank? ? 0 : array.sum.round(2)
      end
    end

    def get_class(now, previous)
      if now == 0 && previous == 0
        '&ndash;'.html_safe
      elsif now != 0 && previous == 0
        {class: 'sign-up'}
      elsif now == 0 && previous != 0
        {class: 'sign-down'}
      elsif now > previous
        {class: 'sign-up'}
      elsif now == previous
        '&ndash;'.html_safe
      else
        {class: 'sign-down'}
      end
    end

    def get_percent(now, previous)
      if now == 0 && previous == 0
        "0%"
      elsif now != 0 && previous == 0
        "100%"
      elsif now == 0 && previous != 0
        "100%"
      elsif now < previous
        ((previous-now)*100/previous).round(2).to_s + "%"
      elsif now == previous
        "0%"
      else
        ((now-previous)*100/previous).round(2).to_s + "%"
      end
    end

    def commas(x)
      str = x.to_s.reverse
      str.gsub!(/([0-9]{3})/,"\\1,")
      str.gsub(/,$/,"").reverse
    end

    def income_chart_data(start_date, end_date)
      data = Payment.select("SUM(amount) AS total, date_in AS date")
        .where(company_id: company.id)
        .where(recipient_type: 'Company')
        .where(approved: true)
        .where(canceled: false)
        .where("date_in >= ?", start_date)
        .where("date_in <= ?", end_date)
        .joins("INNER JOIN claims ON payments.claim_id = claims.id")
          .where(claims: {excluded_from_profit: false})
          .where(claims: {canceled: false})
        .group(:date)
        .order("date DESC")
      chart_settings(data, start_date, end_date)
    end

    def margin_chart_data(start_date, end_date)
      data = Claim.select("AVG(profit_in_percent_acc) AS total, reservation_date AS date")
        .where(company_id: company.id)
        .where(excluded_from_profit: false)
        .where(canceled: false)
        .where("reservation_date >= ?", start_date)
        .where("reservation_date <= ?", end_date)
        .group(:reservation_date)
        .order("reservation_date DESC")
      chart_settings(data, start_date, end_date, true)
    end

    def claim_chart_data(start_date, end_date)
      data = Claim.select("COUNT(id) AS total, reservation_date AS date")
        .where(company_id: company.id)
        .where(excluded_from_profit: false)
        .where(canceled: false)
        .where("reservation_date >= ?", start_date)
        .where("reservation_date <= ?", end_date)
        .group(:reservation_date)
        .order("reservation_date DESC")
      chart_settings(data, start_date, end_date)
    end

    def chart_settings(data, start_date, end_date, is_mean = false)
      case settings[:period]
      when 'day'
        categories = []
        x = start_date
        while x <= end_date
          categories << x
          x += 1.days
        end
        series = [{
          name: I18n.t('boss.active_record.widget.charts.income_sum'),
          data: categories.map do |c|
            elem = data.find_all { |d| d.try(:date).to_date == c }
            elem.length==0 ? 0 : elem.try(:total).to_f.round(2)
          end
        }]
        chart_day_settings(categories, series)
      when 'week'
        categories = []
        x = start_date
        while x <= end_date
          categories << (x + 3.days)
          x += 7.days
        end
        series = [{
          name: I18n.t('boss.active_record.widget.charts.income_sum'),
          data: categories.map do |c|
            elem = data.find_all { |d| d.try(:date).to_date >= (c-3.days) && d.try(:date).to_date <= (c+6.days) }
            elem.length==0 ? [c.to_datetime.to_i * 1000, 0] :
              [c.to_datetime.to_i * 1000, avg_or_sum(elem.map{|e| e.try(:total).to_f}, is_mean).round(2)]
          end
        }]
        chart_week_settings(categories, series)
      else
        categories = []
        x = start_date
        while x <= end_date
          categories << x
          x += 1.months
        end
        series = [{
          name: I18n.t('boss.active_record.widget.charts.income_sum'),
          data: categories.map do |c|
            elem = data.find_all { |d| d.try(:date).to_date.month == c.month }
            elem.length==0 ? 0 : avg_or_sum(elem.map{|e| e.try(:total).to_f}, is_mean).round(2)
          end
        }]
        chart_month_settings(categories, series)
      end
    end

    def chart_day_settings(categories, series)
      {
        title: {
          text: nil
        },
        xAxis: {
          categories: categories.map{|c| c.day.to_s + " " + I18n.t('date.months')[c.month][0..3]},
          labels: {
            align: 'center'
          }
        },
        yAxis: {
          min: 0,
          tickPixelInterval: 25,
          title: {
            text: I18n.t(settings[:yAxis_text])
          }
        },
        tooltip: {
          formatter: nil
        },
        series: series
      }
    end

    def chart_week_settings(categories, series)
      {
        title: {
          text: nil
        },
        xAxis: {
          type: 'datetime'
        },
        yAxis: {
          min: 0,
          tickPixelInterval: 25,
          title: {
            text: I18n.t(settings[:yAxis_text])
          }
        },
        tooltip: {
          formatter: nil,
          shared: true,
          useHTML: true,
          headerFormat: ''
        },
        series: series
      }
    end

    def chart_month_settings(categories, series)
      {
        title: {
          text: nil
        },
        xAxis: {
          categories: categories.map{|c| I18n.t('date.months')[c.month-1][0..5]},
          labels: {
            align: 'center'
          }
        },
        yAxis: {
          min: 0,
          tickPixelInterval: 25,
          title: {
            text: I18n.t(settings[:yAxis_text])
          }
        },
        tooltip: {
          formatter: nil
        },
        series: series
      }
    end
  end
end