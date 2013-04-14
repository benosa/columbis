# -*- encoding : utf-8 -*-
class CurrencyCourse < ActiveRecord::Base
  CURRENCIES = %w[rur eur usd].freeze
  PRIMARY_CURRENCY = CURRENCIES[0]

  attr_accessible :currency, :course, :user_id, :on_date
  attr_protected :company_id

  belongs_to :company
  belongs_to :user

  validates_inclusion_of :currency, :in => CURRENCIES, :message => I18n.t('currency_is_not_found')
  validates_exclusion_of :currency, :in => [PRIMARY_CURRENCY], :message => I18n.t('primary_currency_course_updating_is_impossible')

  validates_presence_of :course, :currency, :on_date
  validates_numericality_of :course

  scope :order_by_date, order('on_date DESC')

  def self.currency_symbol(curr)
    case curr
    when 'rur'
      'р.'
    when 'eur'
      '€'
    when 'usd'
      '$'
    else
      raise 'Unknown currency!'
    end
  end

  def self.convert_from_curr_to_curr(source_currency, target_currency, amount)
    return amount if source_currency == target_currency or amount == 0

    source_course = CurrencyCourse.actual_course(source_currency)
    target_course = CurrencyCourse.actual_course(target_currency)

    (amount * source_course / target_course).round(2)
  end

  def self.actual_courses
    act_cour = []
    for cur in CURRENCIES
      cour = self.send(cur.to_sym)
      act_cour << cour if cour
    end
    act_cour
  end

  def self.actual_course(curr)
    curr == PRIMARY_CURRENCY ? 1 : self.where(:currency => curr).order('on_date DESC').first.try(:course)
  end

  def self.method_missing(meth, *args, &block)
    meth_name = meth.to_s

    if CURRENCIES.include? meth_name
      return self.where(:currency => meth_name).order('on_date DESC').first
    elsif (meth_name =~ /^([a-z]+)_on$/)  and (CURRENCIES.include?($1))
      return self.where('currency = ? AND on_date <= ?', $1, args[0]).order('on_date DESC').first
    end

    super
  end

  def self.get_current_courses
    today = Date.today.strftime("%d/%m/%Y")
    courses = Nokogiri::XML(open("http://www.cbr.ru/scripts/XML_daily.asp?date_req=#{today}"))
    courses.xpath('//Valute').each {|v|
      currency = v.xpath('CharCode').inner_text.downcase
      if CURRENCIES.include? currency
        value = v.xpath('Value').inner_text.sub(/,/, '.').to_f.round(2)
        CurrencyCourse.find_or_create_by_on_date_and_currency!(:on_date => DateTime.parse(today), :currency => currency, :course => value)
      end
    }
  end
end
