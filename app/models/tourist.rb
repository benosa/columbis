# -*- encoding : utf-8 -*-
class Tourist < ActiveRecord::Base
  POTENTIAL_STATES = %w[important reserved refused].freeze
  SEX_STATES = %w[not_selected male female].freeze

  attr_accessible :first_name, :last_name, :middle_name,
                  :passport_series, :passport_number, :passport_valid_until,
                  :date_of_birth, :phone_number, :potential, :email,
                  :address_attributes, :special_offer, :sex, :fio_latin, :passport_issued, :images_attributes, :file

  attr_protected :company_id, :user_id

  attr_accessor :validate_secondary_attributes, :full_name

  belongs_to :company, :counter_cache => true
  belongs_to :user
  has_many :payments, :as => :payer
  has_many :images, as: :imageable

  has_many :tourist_claims, :dependent => :destroy
  has_many :claims, :through => :tourist_claims
  has_one :address, :as => :addressable, :dependent => :destroy

  has_many :sms_touristgroups
  has_many :sms_groups, through: :sms_touristgroups

  accepts_nested_attributes_for :address, :reject_if => :all_blank
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :company_id
  validate :presence_of_full_name

  # Additional attributes validation
  validates_presence_of :date_of_birth, :passport_series, :passport_number, :passport_valid_until,
    :if => proc{ |tourist| !tourist.potential && tourist.send(:additional_attributes_validation_condition) }

  # Secondary attributes validation
  validates_presence_of :phone_number, :if => :secondary_attributes_validation_condition
  validates :email, email: true, presence: true, :if => :secondary_attributes_validation_condition # uniqueness: { scope: :company_id }

  after_update :touch_claims
  after_destroy :touch_claims

  scope :clients, where(:potential => false)
  scope :potentials, where(:potential => true)
  scope :by_full_name, order([:last_name, :first_name, :middle_name])

  default_scope by_full_name

  extend SearchAndSort

  define_index do
    indexes [:last_name, :first_name, :middle_name], :as => :full_name, :sortable => true
    indexes :passport_series, :passport_number, :phone_number, :email, :sortable => true
    indexes address(:joint_address), :as => :joint_address, :sortable => true
    has :passport_valid_until, :date_of_birth, :created_at, :type => :datetime
    has :potential, :type => :boolean
    has :company_id
    has :user_id

    # Add index on date fields for searching
    Tourist.date_indexes :passport_valid_until, :date_of_birth, :created_at do |field, index|
      indexes field, as: index
    end

    set_property :delta => true
  end

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
      unless potential?
        atr = if last_name.blank? && first_name.blank? then :full_name
        elsif last_name.blank? then :last_name
        elsif first_name.blank? then :first_name
        end
      else
        atr = :full_name if full_name.blank?
      end
      # errors.add(:full_name, "#{Tourist.human_attribute_name(atr)} #{I18n.t('activerecord.errors.messages.blank')}") if atr
      self.errors.add(atr, I18n.t('activerecord.errors.messages.blank')) if atr
    end

    # TODO: It is temporary solution to avoid errors for old records
    def additional_attributes_validation_condition
      new_record? or updated_at >= Date.parse('01.07.2013')
    end

    def secondary_attributes_validation_condition
      additional_attributes_validation_condition unless validate_secondary_attributes === false
    end

    def touch_claims
      TouristJobs.touch_claims(id) if
        (!new_record? and (first_name_changed? or last_name_changed? or middle_name_changed? or phone_number_changed?)) or destroyed?
    end

end
