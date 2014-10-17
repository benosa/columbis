class TariffPlan < ActiveRecord::Base
  attr_accessible :active, :analytics, :back_office, :boss_desktop, :claims_base, :crm_system,
                  :documents_flow, :managers_reminder, :name, :place_size, :price, :sms_sending,
                  :users_count, :currency, :default, :extended_potential_clients, :offices_count,
                  :claims_count, :price_half_year, :price_year

  has_many :user_payments
  has_many :companies, :foreign_key => :tariff_id

  validates :currency,    :inclusion => CurrencyCourse::CURRENCIES, :presence => true
  validates :name,        :uniqueness   => true, :presence => true
  validates :place_size,  :numericality => true, :presence => true
  validates :price,       :numericality => true, :presence => true
  validates :users_count, :numericality => true, :presence => true

  after_destroy :set_default_plan_to_companies

  def self.default
    where(default: true).first
  end

  private

    def set_default_plan_to_companies
      companies.update_all tariff_id: TariffPlan.default.try(:id)
    end
end
