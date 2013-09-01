# -*- encoding : utf-8 -*-
module Boss
  class Widget < ActiveRecord::Base

    VIEWS = %w[small small2 medium large].freeze
    TYPES = %w[factor chart table leader].freeze
    NAMES = %w[claim income normalcheck normalprice margin tourists promotion].freeze
    PERIODS = %w[month day week].freeze

    attr_accessible :company_id, :name, :position, :settings, :title, :user_id, :view, :widget_type

    attr_accessible :period

    belongs_to :user
    belongs_to :company

    serialize :settings, Hash

    def period
      @period ||= settings[:period]
    end

    def period=(value)
      @period = value
      if self.widget_type == 'chart'
        self.title = "boss.active_record.widget.#{self.widget_type}.#{self.name}_title_#{value}"
      end
      self.settings.merge!({:period => @period})
    end

    def self.create_default_widgets(user, company)
      widgets = []
      widgets << create_widget(user, company, 1,
        'boss.active_record.widget.factor.claims', 'small', 'factor', 'claim')
      widgets << create_widget(user, company, 2,
        'boss.active_record.widget.factor.incomes', 'small', 'factor', 'income')
      widgets << create_widget(user, company, 3,
        'boss.active_record.widget.factor.normalcheck', 'small', 'factor', 'normalcheck')
      widgets << create_widget(user, company, 4,
        'boss.active_record.widget.factor.normalprice', 'small', 'factor', 'normalprice')
      widgets << create_widget(user, company, 5,
        'boss.active_record.widget.factor.margin', 'small', 'factor', 'margin')
      widgets << create_widget(user, company, 6,
        'boss.active_record.widget.chart.income_title_day', 'medium', 'chart', 'income',
        {:period => 'day', :yAxis_text => 'RUR'})
      widgets << create_widget(user, company, 7,
        'boss.active_record.widget.chart.margin_title_week', 'medium', 'chart', 'margin',
        {:period => 'week', :yAxis_text => 'boss.active_record.widget.chart.percent'})
      widgets << create_widget(user, company, 8,
        'boss.active_record.widget.chart.claim_title_month', 'medium', 'chart', 'claim',
        {:period => 'month', :yAxis_text => 'boss.active_record.widget.chart.claim_number'})
      widgets << create_widget(user, company, 9,
        'boss.active_record.widget.table.tourists', 'large', 'table', 'tourists')
      widgets << create_widget(user, company, 10,
        'boss.active_record.widget.leader.promotion', 'small', 'leader', 'promotion', {:period => 'month'})
      widgets << create_widget(user, company, 11,
        'boss.active_record.widget.leader.direction', 'small', 'leader', 'direction', {:period => 'month'})
      widgets << create_widget(user, company, 12,
        'boss.active_record.widget.leader.hotelstars', 'small', 'leader', 'hotelstars', {:period => 'month'})
      widgets << create_widget(user, company, 13,
        'boss.active_record.widget.leader.officesincome', 'small', 'leader', 'officesincome', {:period => 'month'})
      widgets << create_widget(user, company, 14,
        'boss.active_record.widget.leader.managersincome', 'small', 'leader', 'managersincome', {:period => 'month'})
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
      factor_data(ClaimReport, "amount", I18n.t('boss.active_record.widget.factor.in_all'),
        I18n.t('boss.active_record.widget.factor.claim_number'),
        I18n.t('boss.active_record.widget.factor.claim_text'))
    end

    def income_factor_data
      factor_data(IncomeReport, "amount", I18n.t('boss.active_record.widget.factor.in_all'),
        I18n.t('boss.active_record.widget.factor.payment_sum'),
        I18n.t('boss.active_record.widget.factor.income_text'))
    end

    def normalcheck_factor_data
      factor_data(NormalCheckReport, "amount", I18n.t('boss.active_record.widget.factor.normal'),
        I18n.t('boss.active_record.widget.factor.payment_sum'),
        I18n.t('boss.active_record.widget.factor.normalcheck_text'))
    end

    def normalprice_factor_data
      factor_data(NormalPriceReport, "amount", I18n.t('boss.active_record.widget.factor.normal'),
        I18n.t('boss.active_record.widget.factor.payment_sum'),
        I18n.t('boss.active_record.widget.factor.normalcheck_text'))
    end

    def margin_factor_data
      factor_data(MarginReport, "percent", I18n.t('boss.active_record.widget.factor.normal'),
        '%', I18n.t('boss.active_record.widget.factor.margin_text'), true)
    end

    def income_chart_data
      chart_data(IncomeReport, I18n.t('boss.active_record.widget.chart.sum')).to_json
    end

    def margin_chart_data
      chart_data(MarginReport, I18n.t('boss.active_record.widget.chart.normal')).to_json
    end

    def claim_chart_data
      chart_data(ClaimReport, I18n.t('boss.active_record.widget.chart.number')).to_json
    end

    def tourists_table_data
      Tourist.unscoped
        .clients
        .where(:company_id => company.id)
        .order("created_at DESC")
        .first(10)
    end

    def promotion_leader_data
      leader_data(PromotionChannelReport, 'count')
    end

    def direction_leader_data
      leader_data(DirectionReport, 'items')
    end

    def hotelstars_leader_data
      leader_data(HotelStarsReport, 'count')
    end

    def officesincome_leader_data
      leader_data(OfficesIncomeReport, 'amount')
    end

    def managersincome_leader_data
      leader_data(ManagersIncomeReport, 'amount')
    end

    def factor_data(report_class, method_name, total_title, total_data_prefix, total_text, is_f = false, round = 2)
      report = report_class.new({
        period: 'day',
        company: company,
        start_date: Time.zone.now.to_date-61.days,
        end_date: Time.zone.now.to_date,
        check_date: true
      }).prepare

      data = report.try(method_name.to_sym).data
        .map{|d| ["#{d['year']}.#{d['month']}.#{d['day']}".to_date, d['amount'].to_f.round(2)]}

      report = report_class.new({
        period: 'year',
        company: company,
        start_date: Time.zone.now.beginning_of_year,
        end_date: Time.zone.now.to_date,
        check_date: true
      }).prepare

      total = report.try(method_name.to_sym).data.first
      total = total.nil? ? 0 : total['amount']
      if is_f
        total = total.to_f.round(round)
      else
        total = total.to_i
      end

      create_factor_data(data, true).merge(:total => {
        title: total_title,
        data: "#{commas(total)} <span>#{total_data_prefix}<span/>".html_safe,
        text: total_text
      })
    end

    def chart_data(report_class, name)
      report = report_class.new({
        period: settings[:period],
        company: company
      }).prepare
      hash = ActiveSupport::JSON.decode report.send(:"#{settings[:period]}s_column_settings", report.amount)
      hash["title"]["text"] = nil
      hash.delete "legend"
      hash['series'].each do |s|
        s['name'] = name
      end
      hash
    end

    def leader_data(report_class, column_name)
      case period
      when 'day'
        start_date = Time.zone.now.to_date-1.days
        middle_date = Time.zone.now.to_date-1.days
        end_date = Time.zone.now.to_date
        text = I18n.t("boss.active_record.widget.leader.#{self.name}_text") +
          I18n.t('boss.active_record.widget.leader.by_day')
      when 'week'
        start_date = Time.zone.now.to_date-13.days
        middle_date = Time.zone.now.to_date-7.days
        end_date = Time.zone.now.to_date
        text = I18n.t("boss.active_record.widget.leader.#{self.name}_text") +
          I18n.t('boss.active_record.widget.leader.by_week')
      else
        start_date = Time.zone.now.to_date-61.days
        middle_date = Time.zone.now.to_date-31.days
        end_date = Time.zone.now.to_date
        text = I18n.t("boss.active_record.widget.leader.#{self.name}_text") +
          I18n.t('boss.active_record.widget.leader.by_month')
      end

      report = report_class.new({
        company: company,
        start_date: start_date,
        end_date: middle_date,
        check_date: true,
        no_group_date: true
      }).prepare

      data_previous = report.try(column_name.to_sym).data
        .map{|d| {:name => d['name'], :total => d[column_name]}}

      report = report_class.new({
        company: company,
        start_date: middle_date+1.days,
        end_date: end_date,
        check_date: true,
        no_group_date: true
      }).prepare

      data_now = report.try(column_name.to_sym).data
        .sort{|x,y| y[column_name] <=> x[column_name]}
        .map{|d| {:name => d['name'], :total => d[column_name]}}
        .first(4)

      create_leader_data(data_now, data_previous).merge(:text => text)
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
          [ I18n.t('boss.active_record.widget.factor.today'),
            I18n.t('boss.active_record.widget.factor.week'),
            I18n.t('boss.active_record.widget.factor.month')],
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

    def create_leader_data(data_now, data_previous)
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
  end
end