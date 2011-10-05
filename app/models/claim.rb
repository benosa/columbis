class Claim < ActiveRecord::Base
  attr_accessible :user_id, :tourist_id, :check_date, :description

  belongs_to :user
  belongs_to :tourist
  has_many :tourists

  validates_presence_of :user_id
  validates :currency, :inclusion => CurrencyCourse::CURRENCIES
  validates_presence_of :course, :currency
end

