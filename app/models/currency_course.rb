class CurrencyCourse < ActiveRecord::Base
  CURRENCIES = %w[rur eur usd].freeze

  attr_accessible :currency, :course, :user_id, :on_date

  belongs_to :user

  validates :currency, :inclusion => CURRENCIES
  validates_presence_of :course, :currency, :on_date
  validates_numericality_of :course

  scope :order_by_date, order('on_date DESC')

  def self.actual_courses
    act_cour = []
    for cur in CURRENCIES
      cour = self.send(cur.to_sym)
      act_cour << cour if cour
    end
    act_cour
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
end

