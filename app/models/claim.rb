class Claim < ActiveRecord::Base
  VISA_STATUSES = %w[nothing_done docs_got docs_sent visa_approved passport_received].freeze
  attr_accessible :user_id, :tourist_id, :check_date, :description, :office_id, :operator_id, :operator_confirmation, :visa, :visa_check,
                  :airport_to, :airport_back, :flight_to, :flight_back, :depart_to, :depart_back, :time_to, :time_back


  belongs_to :user
  belongs_to :office
  belongs_to :tourist
  has_many :tourists

  validates_presence_of :user_id
  validates_presence_of :currency
  validates_inclusion_of :currency, :in => CurrencyCourse::CURRENCIES

  accepts_nested_attributes_for :tourist, :reject_if => proc { |attributes| attributes['tourist'].blank? }
  accepts_nested_attributes_for :tourists

end
