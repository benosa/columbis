class UserPayment < ActiveRecord::Base
  STATUSES = %w[new fail success approved all].freeze

  attr_accessible :amount, :status, :company_id, :currency, :description, :invoice, :period, :tariff_id, :user_id

  attr_protected :user_id, :company_id

  belongs_to :company
  belongs_to :user
  belongs_to :tariff, class_name: 'TariffPlan'

  has_one :payment_company, class_name: 'Company', :dependent => :nullify

  validates_presence_of :amount, :currency, :description, :company_id, :user_id
  validates_presence_of :period, :unless => proc{ self.tariff_id.blank?  }
  validates_uniqueness_of :invoice
  validates :currency, :inclusion => CurrencyCourse::CURRENCIES
  validates :status, :inclusion => STATUSES
  validates :period, :numericality => true
  validate :check_other_user_payments

  before_validation :set_status
  before_validation :set_description
  before_validation :check_tariff
  after_create :set_invoice

  default_scope :order => :updated_at

  define_index do
    indexes :description, :sortable => true

    has :amount
    has :invoice
    has :updated_at
    has "CRC32(status)", :as => :status_crc32, type: :integer
    has :company_id

    set_property :delta => true
  end

  sphinx_scope(:by_updated_at) { { :order => :updated_at } }
  default_sphinx_scope :by_updated_at

  extend SearchAndSort

  private
    def set_invoice
      UserPayment.update(id, :invoice => company_id * 10000 + id) if id
    end

    def check_tariff
      if self.tariff_id
        tariff = TariffPlan.find(tariff_id)
        self.currency = tariff.try(:currency)
        self.amount = tariff.try(:price) * self.period
      end
    end

    def set_status
      self.status = 'new' unless self.status
    end

    def check_other_user_payments
      if self.status == 'new' &&
          self.company.user_payments.select{|payment| payment.status == "new" &&
            payment.id != self.id}.size != 0
        errors.add(:status, "#{I18n.t('.user_payments.activerecord.errors.new_has_exist')}")
      end
    end

    def set_description
      plan = I18n.t('activerecord.attributes.user_payment.new_tariff')
      plan = I18n.t('activerecord.attributes.user_payment.old_tariff') if
        self.company.tariff_id == self.tariff.id
      self.description = I18n.t('.activerecord.attributes.user_payment.description_text',
        :tariff_plan_name => self.tariff.name, :tariff_period => self.period, :is_new_plan => plan)
    end
end
