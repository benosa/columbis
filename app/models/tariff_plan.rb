class TariffPlan < ActiveRecord::Base
  attr_accessible :active, :analytics, :back_office, :boss_desktop, :claims_base, :crm_system,
                  :documents_flow, :managers_reminder, :name, :place_size, :price, :sms_sending,
                  :users_count, :currency

  has_many :user_payments
  has_many :companies, :foreign_key => :tariff_id

  validates :currency,    :inclusion => CurrencyCourse::CURRENCIES, :presence => true
  validates :name,        :uniqueness   => true, :presence => true
  validates :place_size,  :numericality => true, :presence => true
  validates :price,       :numericality => true, :presence => true
  validates :users_count, :numericality => true, :presence => true

  after_destroy :set_deafault_plan_to_companies

  def self.default
    tps = TariffPlan.where(:name => "По умолчанию")
    if tps.length == 0
      TariffPlan.create(:active => true, :name => "По умолчанию", :place_size => 10,
        :price => 0, :sms_sending => false, :currency => "rur", :users_count => 5)
    else
      tps.first
    end
  end

  private

    def set_deafault_plan_to_companies      
      Company.update_by_default_tariff(companies)
    end
end
