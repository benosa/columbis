# -*- encoding : utf-8 -*-
module Boss
  class Widget < ActiveRecord::Base

    VIEWS = %w[small small2 medium large].freeze
    TYPES = %w[factor chart table leader].freeze
    NAMES = %w[claim income normalcheck tourprice margin tourists promotion].freeze
    PERIODS = %w[day week month].freeze

    attr_accessible :company_id, :name, :position, :settings, :title, :user_id, :view, :widget_type

    belongs_to :user
    belongs_to :company

    serialize :settings, Hash

    def self.create_default_widgets(user, company)
      widgets = []
      widgets << create_widget(user, company, 1,
        'boss.active_record.widget.factors.claims', 'small', 'factor', 'claim')
      widgets << create_widget(user, company, 2,
        'boss.active_record.widget.factors.incomes', 'small', 'factor', 'income')
      widgets << create_widget(user, company, 3,
        'boss.active_record.widget.factors.normalcheck', 'small', 'factor', 'normalcheck')
      widgets << create_widget(user, company, 4,
        'boss.active_record.widget.factors.tourprice', 'small', 'factor', 'tourprice')
      widgets << create_widget(user, company, 5,
        'boss.active_record.widget.factors.margin', 'small', 'factor', 'margin')
      widgets << create_widget(user, company, 6,
        'boss.active_record.widget.charts.income_title_day', 'medium', 'chart', 'income',
        {:period => 'day', :yAxis_text => 'RUR'})
      widgets << create_widget(user, company, 7,
        'boss.active_record.widget.charts.margin_title_week', 'medium', 'chart', 'margin',
        {:period => 'week', :yAxis_text => 'boss.active_record.widget.charts.percent'})
      widgets << create_widget(user, company, 8,
        'boss.active_record.widget.charts.claim_title_month', 'medium', 'chart', 'claim',
        {:period => 'month', :yAxis_text => 'boss.active_record.widget.charts.claim_number'})
      widgets << create_widget(user, company, 9,
        'boss.active_record.widget.tables.tourists', 'large', 'table', 'tourists')
      widgets << create_widget(user, company, 10,
        'boss.active_record.widget.leaders.promotion', 'small', 'leader', 'promotion')
      widgets << create_widget(user, company, 11,
        'boss.active_record.widget.leaders.direction', 'small', 'leader', 'direction')
      widgets << create_widget(user, company, 12,
        'boss.active_record.widget.leaders.hotelstars', 'small', 'leader', 'hotelstars')
      widgets << create_widget(user, company, 13,
        'boss.active_record.widget.leaders.officesincome', 'small', 'leader', 'officesincome')
      widgets << create_widget(user, company, 14,
        'boss.active_record.widget.leaders.managersincome', 'small', 'leader', 'managersincome')
    end

    def self.create_widget(user, company, position, title, view, widget_type, name, settings = {})
      widget = Widget.new(:user_id => user.id, :company_id => company.id, :position => position,
        :title => title, :view => view, :widget_type => widget_type,
        :name => name, :settings => settings)
      widget.save
      widget
    end

    def widget_data
      send(:"#{name}_#{widget_type}_data")
    end



    private

    def claim_factor_data
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

    def income_chart_data
      report = IncomeReport.new({
        period: settings[:period],
        company: company
      }).prepare
      hash = ActiveSupport::JSON.decode report.send(:"#{settings[:period]}s_column_settings", report.amount)
      hash["title"]["text"] = nil
      hash.delete "legend"
      hash.to_json
    end

    def margin_chart_data
      report = MarginReport.new({
        period: settings[:period],
        company: company
      }).prepare
      hash = ActiveSupport::JSON.decode report.send(:"#{settings[:period]}s_column_settings", report.amount)
      hash["title"]["text"] = nil
      hash.delete "legend"
      hash.to_json
    end

    def claim_chart_data
      report = ClaimReport.new({
        period: settings[:period],
        company: company
      }).prepare
      hash = ActiveSupport::JSON.decode report.send(:"#{settings[:period]}s_column_settings", report.amount)
      hash["title"]["text"] = nil
      hash.delete "legend"
      hash.to_json
    end

    def tourists_table_data
      Tourist.unscoped
        .clients
        .where(:company_id => company.id)
        .order("created_at DESC")
        .first(10)
    end

    def promotion_leader_data
      report = PromotionChannelReport.new({
        company: company,
        start_date: Time.zone.now.to_date-30.days,
        end_date: Time.zone.now.to_date
      }).prepare
      data_now = report.count.data
        .sort{|x,y| y['count'] <=> x['count']}.first(4)
        .map{|d| {:name => d['name'], :total => d['count']}}

      report = PromotionChannelReport.new({
        company: company,
        start_date: Time.zone.now.to_date-61.days,
        end_date: Time.zone.now.to_date-31.days
      }).prepare
      data_previous = report.count.data
        .sort{|x,y| y['count'] <=> x['count']}
        .map{|d| {:name => d['name'], :total => d['count']}}

      leader_data(data_now, data_previous).merge(
        :text => I18n.t('boss.active_record.widget.leaders.promotion_text'))
    end

    def direction_leader_data
      report = DirectionReport.new({
        company: company,
        start_date: Time.zone.now.to_date-30.days,
        end_date: Time.zone.now.to_date
      }).prepare
      data_now = report.items.data
        .sort{|x,y| y['items'] <=> x['items']}.first(4)
        .map{|d| {:name => d['name'], :total => d['items']}}

      report = DirectionReport.new({
        company: company,
        start_date: Time.zone.now.to_date-61.days,
        end_date: Time.zone.now.to_date-31.days
      }).prepare
      data_previous = report.items.data
        .sort{|x,y| y['items'] <=> x['items']}
        .map{|d| {:name => d['name'], :total => d['items']}}

      leader_data(data_now, data_previous).merge(
        :text => I18n.t('boss.active_record.widget.leaders.direction_text'))
    end

    def hotelstars_leader_data
      report = HotelStarsReport.new({
        company: company,
        start_date: Time.zone.now.to_date-30.days,
        end_date: Time.zone.now.to_date
      }).prepare
      data_now = report.count.data
        .sort{|x,y| y['count'] <=> x['count']}.first(4)
        .map{|d| {:name => d['name'], :total => d['count']}}

      report = HotelStarsReport.new({
        company: company,
        start_date: Time.zone.now.to_date-61.days,
        end_date: Time.zone.now.to_date-31.days
      }).prepare
      data_previous = report.count.data
        .sort{|x,y| y['count'] <=> x['count']}
        .map{|d| {:name => d['name'], :total => d['count']}}

      leader_data(data_now, data_previous).merge(
        :text => I18n.t('boss.active_record.widget.leaders.hotelstars_text'))
    end

    def officesincome_leader_data
      report = OfficesIncomeReport.new({
        period: 'day',
        company: company,
        start_date: Time.zone.now.to_date-1.days,
        end_date: Time.zone.now.to_date,
        check_date: true
      }).prepare
      data_now = report.amount.data.select{|d| "#{d['year']}.#{d['month']}.#{d['day']}".to_date == Time.zone.now.to_date}
        .sort{|x,y| x['amount'] <=> y['amount']}.first(4)
        .map{|d| {:name => d['name'], :total => d['amount']}}
      data_previous = report.amount.data.select{|d| "#{d['year']}.#{d['month']}.#{d['day']}".to_date == (Time.zone.now.to_date-1.days)}
        .sort{|x,y| x['amount'] <=> y['amount']}
        .map{|d| {:name => d['name'], :total => d['amount']}}
      leader_data(data_now, data_previous).merge(
        :text => I18n.t('boss.active_record.widget.leaders.officesincome_text'))
    end

    def managersincome_leader_data
      report = ManagersIncomeReport.new({
        period: 'day',
        company: company,
        start_date: Time.zone.now.to_date-1.days,
        end_date: Time.zone.now.to_date,
        check_date: true
      }).prepare
      data_now = report.amount.data.select{|d| "#{d['year']}.#{d['month']}.#{d['day']}".to_date == Time.zone.now.to_date}
        .sort{|x,y| x['amount'] <=> y['amount']}.first(4)
        .map{|d| {:name => d['name'], :total => d['amount']}}
      data_previous = report.amount.data.select{|d| "#{d['year']}.#{d['month']}.#{d['day']}".to_date == (Time.zone.now.to_date-1.days)}
        .sort{|x,y| x['amount'] <=> y['amount']}
        .map{|d| {:name => d['name'], :total => d['amount']}}
      leader_data(data_now, data_previous).merge(
        :text => I18n.t('boss.active_record.widget.leaders.managersincome_text'))
    end

    def leader_data(data_now, data_previous)
      data = [[],[],[],[]]
      data_now.each do |d|
        name = d[:name] or d.try(:name)
        now  = (d[:total] or d.try(:total)).to_i
        prev = data_previous.select{|p| (p[:name] or p.try(:name)) == name}
        prev = prev.blank? ? 0 : (prev.first[:total] or prev.first.try(:total)).to_i
        data[0] << name
        data[1] << commas(now)
        data[2] << get_class(now, prev)
        data[3] << get_percent(now, prev)
      end
      { data: data }
    end
  end
end