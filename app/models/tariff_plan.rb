class TariffPlan < ActiveRecord::Base
  attr_accessible :active, :analytics, :back_office, :boss_desktop, :claims_base, :crm_system,
                  :documents_flow, :managers_reminder, :name, :place_size, :price, :sms_sending,
                  :users_count, :currency

  has_many :user_payments

  validates :currency, :inclusion => CurrencyCourse::CURRENCIES, :presence => true
  validates :name, :presence => true
  validates :place_size, :numericality => true, :presence => true
  validates :price, :numericality => true, :presence => true
  validates :users_count, :numericality => true, :presence => true
end
