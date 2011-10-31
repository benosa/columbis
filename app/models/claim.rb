class Claim < ActiveRecord::Base
  VISA_STATUSES = %w[nothing_done docs_got docs_sent visa_approved passport_received].freeze
  attr_accessible :user_id, :tourist_id, :check_date, :description, :office_id, :operator_id, :operator_confirmation, :visa, :visa_check,
                  :airport_to, :airport_back, :flight_to, :flight_back, :depart_to, :depart_back, :time_to, :time_back,
                  :total_tour_price, :course, :fuel_tax_price, :additional_insurance_price, :primary_currency_price,
                  :visa_price, :tourist_attributes, :insurance_price, :tour_price, :currency


  belongs_to :user
  belongs_to :office
  belongs_to :tourist
  has_many :tourist_claims
  has_many :tourists, :through => :tourist_claims

  validates_presence_of :user_id
  validates_presence_of :currency
  validates_inclusion_of :currency, :in => CurrencyCourse::CURRENCIES

  accepts_nested_attributes_for :tourist, :reject_if => proc { |attributes| attributes['tourist'].blank? }
  accepts_nested_attributes_for :tourists

  def tourist_debt?
    true
  end

  def operators_debt?
    false
  end

  def documents_ready?
    true
  end
end
