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
        :title => '.claims', :view => 'small', :widget_type => 'factor',
        :name => 'claim', :settings => {})
      widget.save
      widget
    end

    def claims_widget_data
      data = Claim.select("COUNT(id) AS total,
          extract(day from reservation_date) AS day,
          extract(month from reservation_date) AS month,
          extract(year from reservation_date) AS year")
        .where(:company_id => company.id)
        .where(:excluded_from_profit => false)
        .where(:canceled => false)
        .where("reservation_date >= ?", Time.zone.now - 62.days)
        .group(:day, :month, :year)
        .order("year DESC, month DESC, day DESC")
      data = {
        data: [
          ['Среда', '7 дней', '31 день'],
          ['31', '5,420', '338,786'],
          [{class: 'sign-up'}, '&ndash;'.html_safe, {class: 'sign-down'}],
          ['00.01%', '17.30%', '21.40%']
        ],
        total: {
          title: 'Всего',
          data: '23,460 <span>p.<span/>'.html_safe,
          text: '(не включая продажи по другим <br> каналам)'.html_safe
        }
      }
    end
  end
end