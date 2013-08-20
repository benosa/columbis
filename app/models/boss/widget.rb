# -*- encoding : utf-8 -*-
module Boss
  class Widget < ActiveRecord::Base

    VIEWS = %w[small small2 medium large].freeze
    TYPES = %w[factor chart table].freeze
    NAMES = %w[claim].freeze

    attr_accessible :company_id, :name, :position, :settings, :title, :user_id, :view, :widget_type

    belongs_to :user
    belongs_to :company

    serialize :settings, Hash

    def self.create_default_widgets(user, company)
      widgets = []
      widgets << create_default_claim_widget(user, company)
      widgets << create_default_income_widget(user, company)
      widgets << create_default_normalcheck_widget(user, company)
      widgets << create_default_tourprice_widget(user, company)
      widgets << create_default_margin_widget(user, company)
    end

    def self.create_default_claim_widget(user, company)
      widget = Widget.new(:user_id => user.id, :company_id => company.id, :position => 1,
        :title => I18n.t('boss.active_record.claims'), :view => 'small', :widget_type => 'factor',
        :name => 'claim', :settings => {})
      widget.save
      widget
    end

    def self.create_default_income_widget(user, company)
      widget = Widget.new(:user_id => user.id, :company_id => company.id, :position => 2,
        :title => I18n.t('boss.active_record.incomes'), :view => 'small', :widget_type => 'factor',
        :name => 'income', :settings => {})
      widget.save
      widget
    end

    def self.create_default_normalcheck_widget(user, company)
      widget = Widget.new(:user_id => user.id, :company_id => company.id, :position => 2,
        :title => I18n.t('boss.active_record.normalcheck'), :view => 'small', :widget_type => 'factor',
        :name => 'normalcheck', :settings => {})
      widget.save
      widget
    end

    def self.create_default_tourprice_widget(user, company)
      widget = Widget.new(:user_id => user.id, :company_id => company.id, :position => 2,
        :title => I18n.t('boss.active_record.tourprice'), :view => 'small', :widget_type => 'factor',
        :name => 'tourprice', :settings => {})
      widget.save
      widget
    end

    def self.create_default_margin_widget(user, company)
      widget = Widget.new(:user_id => user.id, :company_id => company.id, :position => 2,
        :title => I18n.t('boss.active_record.margin'), :view => 'small', :widget_type => 'factor',
        :name => 'margin', :settings => {})
      widget.save
      widget
    end

    def widget_data
      case name
      when 'claim'
        claims_widget_data
      when 'income'
        income_widget_data
      when 'normalcheck'
        normalcheck_widget_data
      when 'tourprice'
        tourprice_widget_data
      when 'margin'
        margin_widget_data
      end
    end




    private

    def claims_widget_data
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
      create_data(data).merge(:total => {
        title: I18n.t('.in_all'),
        data: "#{total.first.try('total')} <span>#{I18n.t('.claim_number')}<span/>".html_safe,
        text: I18n.t('.claim_text')
      })
    end

    def income_widget_data
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
      create_data(data).merge(:total => {
        title: I18n.t('.in_all'),
        data: "#{commas(total.first.try('total'))} <span>#{I18n.t('.payment_sum')}<span/>".html_safe,
        text: I18n.t('.income_text')
      })
    end

    def normalcheck_widget_data
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
      create_data(data, true).merge(:total => {
        title: I18n.t('.normal'),
        data: "#{commas(total.first.try('total').to_i)} <span>#{I18n.t('.payment_sum')}<span/>".html_safe,
        text: I18n.t('.normalcheck_text')
        })
    end

    def tourprice_widget_data
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

      create_data(data, true).merge(
        :total => {
          title: I18n.t('.normal'),
          data: "#{commas(total)} <span>#{I18n.t('.payment_sum')}<span/>".html_safe,
          text: I18n.t('.normalcheck_text')
        })
    end

    def margin_widget_data
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
      create_data(data, true).merge(:total => {
        title: I18n.t('.normal'),
        data: "#{commas(total.first.try('total').to_f.round(2))} <span>%<span/>".html_safe,
        text: I18n.t('.margin_text')
      })
    end

    def create_data(data, is_mean = false)
      now_day        = get_by_date(data, is_mean, Time.zone.now.to_date,         Time.zone.now.to_date        )
      previous_day   = get_by_date(data, is_mean, Time.zone.now.to_date-1.days,  Time.zone.now.to_date-1.days )
      now_week       = get_by_date(data, is_mean, Time.zone.now.to_date-6.days,  Time.zone.now.to_date        )
      previous_week  = get_by_date(data, is_mean, Time.zone.now.to_date-13.days, Time.zone.now.to_date-7.days )
      now_month      = get_by_date(data, is_mean, Time.zone.now.to_date-30.days, Time.zone.now.to_date        )
      previous_month = get_by_date(data, is_mean, Time.zone.now.to_date-61.days, Time.zone.now.to_date-31.days)
      {
        data: [
          [I18n.t('.today'), I18n.t('.week'), I18n.t('.month')],
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

    def get_by_date(data, is_mean, start_date, end_date)
      x = data.select{|d| (d[0] >= start_date) && (d[0] <= end_date)}.map{|d| d[1]}
      x.delete(0)
      if is_mean
        x.blank? ? 0 : (x.sum/x.length).round(2)
      else
        x.blank? ? 0 : x.sum.round(2)
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
        "0%"
      elsif now == 0 && previous != 0
        "0%"
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
  end
end