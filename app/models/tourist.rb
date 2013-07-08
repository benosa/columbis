# -*- encoding : utf-8 -*-
class Tourist < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :middle_name,
                  :passport_series, :passport_number, :passport_valid_until,
                  :date_of_birth, :phone_number, :potential, :email,
                  :address_attributes

  attr_protected :company_id

  belongs_to :company
  has_many :payments, :as => :payer

  has_many :tourist_claims, :dependent => :destroy
  has_many :claims, :through => :tourist_claims
  has_one :address, :as => :addressable, :dependent => :destroy

  accepts_nested_attributes_for :address, :reject_if => :all_blank

  validates_presence_of :company_id
  validate :presence_of_full_name
  validates_presence_of :date_of_birth, :passport_series, :passport_number, :passport_valid_until, :phone_number,
    :if => proc {|tourist| tourist.new_record? || tourist.updated_at >= '01.07.2013'} # TODO: It is temporary solution to avoid errors for old records
  validates :email, email: true, #presence: { on: :create }
    :if => proc {|tourist| tourist.new_record? || tourist.updated_at >= '01.07.2013'}

  scope :clients, where(:potential => false)
  scope :potentials, where(:potential => true)
  scope :by_full_name, order([:last_name, :first_name, :middle_name])

  default_scope by_full_name

  define_index do
    indexes [:last_name, :first_name, :middle_name], :as => :full_name, :sortable => true
    indexes :phone_number, :email, :sortable => true
    indexes address(:joint_address), :as => :joint_address, :sortable => true
    has :passport_series
    has :passport_number
    has :passport_valid_until, :date_of_birth, :type => :datetime
    has :potential, :type => :boolean
    has :company_id

    set_property :delta => true
  end

  sphinx_scope(:clients_by_full_name) do
    {
      :with => { :potential => false },
      :order => :full_name
    }
  end
  default_sphinx_scope :clients_by_full_name

  extend SearchAndSort

  local_data :full_name, :initials_name, :attributes => :all

  def first_last_name
    "#{first_name} #{last_name}".strip
  end

  def full_name
    "#{last_name} #{first_name} #{middle_name if middle_name}".strip
  end

  def initials_name
    "#{last_name} #{first_name.try(:initial)}#{middle_name.try(:initial) if middle_name}".strip
  end

  def full_name=(name)
    split = name.to_s.split(' ', 3)
    self.last_name = split[0]
    self.first_name = split[1]
    self.middle_name = split[2]
  end

  alias_method :name, :full_name

  private

    def presence_of_full_name
      atr = if last_name.blank? && first_name.blank? then :full_name
      elsif last_name.blank? then :last_name
      elsif first_name.blank? then :first_name
      end
      errors.add(:full_name, "#{Tourist.human_attribute_name(atr)} #{I18n.t('activerecord.errors.messages.blank')}") if atr
    end

end
