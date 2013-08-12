class TariffPlan < ActiveRecord::Base
  attr_accessible :active, :analytics, :back_office, :boss_desktop, :claims_base, :crm_system,
                  :documents_flow, :managers_reminder, :name, :place_size, :price, :sms_sending,
                  :users_count
  validates :currency, :inclusion => CurrencyCourse::CURRENCIES
  validates_presence_of :name, :place_size, :price, :users_count
end
