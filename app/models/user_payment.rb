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

  before_validation :set_status
  before_validation :set_description
  before_validation :check_tariff

  before_create :check_other_user_payments
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

  def pay(status)
    rezult_of_check = is_bad_status(status)
    return rezult_of_check if rezult_of_check && rezult_of_check.has_key?(:alert)
    send(:"#{status}")
  end

  def self.can_create_new?(company)
    UserPayment.where(:company_id => company.id)
      .where("\"user_payments\".\"status\" = 'new' OR \"user_payments\".\"status\" = 'success'").blank?
  end

  private

    def is_bad_status(status)
      unless status || [:paid, :success, :fail].include?(status)
        return {:alert => I18n.t('.user_payments.messages.uncertain_status')}
      else
        false
      end
    end

    def paid
      if self.update_attributes(:status => 'approved')
        return self.company.tariff_paid(self)
      else
        false
      end
    end

    def success
      if self.status == 'approved'
        return {:notice => I18n.t('.user_payments.messages.paid_already_complete')}
      elsif self.update_attributes(:status => 'success')
        return {:notice => I18n.t('.user_payments.messages.success_complete')}
      else
        return {:alert => I18n.t('.user_payments.messages.success_incomplete')}
      end
    end

    def fail
      if self.status == 'approved' || self.status == 'success'
        return {:notice => I18n.t('.user_payments.messages.fail_not_complete')}
      elsif self.update_attributes(:status => 'fail')
        return {:notice => I18n.t('.user_payments.messages.fail_complete')}
      else
        return {:alert => I18n.t('.user_payments.messages.fail_incomplete')}
      end
    end

    def set_invoice
      UserPayment.update(self.id, :invoice => self.company_id * 10000 + self.id) if self.id
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
      if UserPayment.can_create_new?(self.company)
        true
      else
        errors.add(:status, "#{I18n.t('activerecord.attributes.user_payment.errors.new_has_exist')}")
        false
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
