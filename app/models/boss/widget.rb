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
    end

    def self.create_default_claim_widget(user, company)
      widget = Widget.new(:user_id => user.id, :company_id => company.id, :position => 1,
        :title => I18n.t('.claims'), :view => 'small', :widget_type => 'factor',
        :name => 'claim', :settings => {})
      widget.save
      widget
    end

    def claims_widget_data
      data = Claim.select("COUNT(id) AS total, reservation_date")
        .where(:company_id => company.id)
        .where(:excluded_from_profit => false)
        .where(:canceled => false)
        .where("reservation_date >= ?", Time.zone.now - 61.days)
        .group(:reservation_date)
        .order("reservation_date DESC")
      total = Claim.select("COUNT(id) AS total")
        .where(:company_id => company.id)
        .where(:excluded_from_profit => false)
        .where(:canceled => false)
      widget_data(data).merge(:total => {
        title: I18n.t('.in_all'),
        data: "#{total.first.try('total')} <span>#{I18n.t('.claim_number')}<span/>".html_safe,
        text: I18n.t('.claim_text')
      })
    end

    def widget_data(data)
      data = data.map{|d| [d.try(:reservation_date), d.try(:total).to_i]}
      now_day = data.select{|d| d[0] == Time.zone.now.to_date}.first
      previous_day = data.select{|d| d[0] == (Time.zone.now.to_date - 1.days)}.first
      now_week = data.select{|d| d[0] >= (Time.zone.now.to_date - 6.days)}.map{|d| d[1]}.sum
      previous_week = data
        .select{|d| (d[0] >= (Time.zone.now.to_date - 13.days)) && (d[0] < (Time.zone.now.to_date - 6.days))}
        .map{|d| d[1]}.sum
      now_month = data.select{|d| d[0] >= (Time.zone.now.to_date - 30.days)}.map{|d| d[1]}.sum
      previous_month = data
        .select{|d| (d[0] >= (Time.zone.now.to_date - 61.days)) && (d[0] < (Time.zone.now.to_date - 30.days))}
        .map{|d| d[1]}.sum
      now_day = now_day.nil? ? 0 : now_day[1]
      previous_day = previous_day.nil? ? 0 : previous_day[1]
      now_week = now_week.nil? ? 0 : now_week
      now_month = now_month.nil? ? 0 : now_month
      {
        data: [
          [I18n.t('.today'), I18n.t('.week'), I18n.t('.month')],
          [now_day.to_s, now_week.to_s, now_month.to_s],
          [get_class(now_day, previous_day),
            get_class(now_week, previous_week),
            get_class(now_month, previous_month)],
          [get_percent(now_day, previous_day),
            get_percent(now_week, previous_week),
            get_percent(now_month, previous_month)]
        ]
      }
    end

    def get_class(now, previous)
      if now.blank? && previous.blank?
        '&ndash;'.html_safe
      elsif !now.blank? && previous.blank?
        {class: 'sign-up'}
      elsif now.blank? && !previous.blank?
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
      if now.blank? && previous.blank?
        "0%"
      elsif !now.blank? && previous.blank?
        "0%"
      elsif now.blank? && !previous.blank?
        "0%"
      elsif now > previous
        (now*100/previous).round(2).to_s + "%"
      elsif now == previous
        "0%"
      else
        (now*100/previous).round(2).to_s + "%"
      end
    end
  end
end