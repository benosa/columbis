class UserPayment < ActiveRecord::Base
  attr_accessible :amount, :approved, :company_id, :currency, :description, :invoice, :period, :tariff_id, :user_id

  attr_protected :user_id, :company_id

  belongs_to :company
  belongs_to :user
  belongs_to :tariff, class_name: 'TariffPlan'

  validates_presence_of :amount, :currency, :period
  validates_uniqueness_of :invoice
  validates :currency, :inclusion => CurrencyCourse::CURRENCIES

  after_create :set_invoice

  default_scope :order => :updated_at

  define_index do
    indexes :description, :sortable => true

    has :invoice
    has :updated_at
    has :approved
    has :company_id

    set_property :delta => true
  end

  sphinx_scope(:by_updated_at) { { :order => :updated_at } }
  default_sphinx_scope :by_updated_at

  extend SearchAndSort

  def set_invoice
    UserPayment.update(id, :invoice => company_id * 10000 + id)
  end
end
