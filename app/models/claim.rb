class Claim < ActiveRecord::Base
  VISA_STATUSES = %w[nothing_done docs_got docs_sent visa_approved passport_received].freeze
  attr_accessible :user_id, :check_date, :description, :office_id, :operator_id, :operator_confirmation, :visa, :visa_check,
                  :airport_to, :airport_back, :flight_to, :flight_back, :depart_to, :depart_back, :time_to, :time_back,
                  :total_tour_price, :course, :fuel_tax_price, :additional_insurance_price, :primary_currency_price,
                  :visa_price, :tourist_attributes, :insurance_price, :tour_price, :currency,
                  :tourists_attributes, :applicant_attributes

  belongs_to :user
  belongs_to :office

  has_many :tourist_claims, :dependent => :destroy, :conditions => { :applicant => false }
  has_many :tourists, :through => :tourist_claims

  has_one :tourist_claim, :dependent => :destroy, :conditions => { :applicant => true }
  has_one :applicant, :through => :tourist_claim, :source => :tourist

  validates_presence_of :user_id
  validates_presence_of :currency
  validates_inclusion_of :currency, :in => CurrencyCourse::CURRENCIES

  accepts_nested_attributes_for :tourists

  def assign_applicant(applicant_params)
    if applicant_params[:id].blank?
      tourist = Tourist.new(applicant_params)
      if tourist.save
        self.applicant = tourist
      else
        tourist.errors.messages.each do |attr_name, err|
          errors.add(:applicant, I18n.t("tourist.#{attr_name.to_s}" ) + " : " + err.join(', '))
        end
      end
    else
      self.applicant = Tourist.find(applicant_params[:id])
    end
  end

  def reset_tourists()

  end

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
