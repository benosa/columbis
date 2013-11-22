# -*- encoding : utf-8 -*-
class Operator < ActiveRecord::Base
  attr_accessible :name, :register_number, :register_series, :inn, :ogrn, :site,
  				  :insurer, :insurer_address, :insurer_provision, :insurer_contract,
  				  :insurer_contract_date, :insurer_contract_start, :insurer_contract_end,
  				  :address_attributes, :code_of_reason, :full_name, :banking_details,
            :actual_address, :insurer_full_name, :actual_insurer_address

  attr_protected :company_id

  attr_reader :common_operator # common_operator relation for company operator

  belongs_to :company
  has_many :claims, :inverse_of => :operator
  has_many :payments, :as => :recipient
  has_one :address, :as => :addressable, :dependent => :destroy

  accepts_nested_attributes_for :address, :reject_if => :all_blank

  validates :name, presence: true, uniqueness: { scope: :company_id }, length: { maximum: 255 }

  scope :by_company_or_common, ->(company) { where("common = ? OR company_id = ?", true, company.id) }

  after_update :touch_claims
  after_destroy :touch_claims

  define_index do
    indexes :name, :register_number, :register_series, :inn, :ogrn, :sortable => true
    indexes address(:joint_address), :as => :joint_address, :sortable => true
    has :company_id
    has :common, :type => :boolean
    set_property :delta => true
  end

  local_data :extra_columns => :local_data_extra_columns, :extra_data => :local_extra_data

  extend SearchAndSort

  def self.local_data_extra_columns
    [ :address, :address_id ]
  end

  def local_extra_data
    {
      :address => self.address.try(:pretty_full_address),
      :address_id => self.address.try(:id),
    }
  end

  def self.common_operator(*args) # register_number/register_series or inn
    options = args.extract_options!
    options[:register_number], options[:register_series] = args[0], args[1] if args.length > 1
    options[:inn] = args[0] if args.length == 1
    return if options.empty?
    where(options.merge company_id: nil, common: true).first
  end

  def check_and_load_common_operator!
    @common_operator = Operator.common_operator(register_number, register_series)
  end

  def synced_with_common_operator?
    return unless common_operator
    attrs = attrs_to_sync_with_common_operator(false)
    synced = attrs[:attributes] == attrs[:common_attributes]
    synced = attrs[:address_attributes] == attrs[:common_address_attributes] if synced
    synced
  end

  def sync_with_common_operator!
    return unless common_operator
    attrs = attrs_to_sync_with_common_operator
    assign_attributes attrs[:common_attributes]
    unless attrs[:common_address_attributes].empty?
      build_address if address.nil?
      address.assign_attributes attrs[:common_address_attributes]
    end
    self
  end

  private

    def touch_claims
      # Potentially long operation, handle it asynchronously
      OperatorJobs.touch_claims(id) if (!new_record? and name_changed?) or destroyed?
    end

    def attrs_to_sync_with_common_operator(only_common = true)
      excluded_attrs = %w[id name common company_id created_at updated_at delta]
      excluded_address_attrs = %w[id addressable_id addressable_type joint_address created_at updated_at delta]

      attrs_to_sync = {}
      attrs_to_sync[:common_attributes] = common_operator.attributes.delete_if{ |k,v| excluded_attrs.include? k }
      common_address_attributes = common_operator.address.attributes.delete_if{ |k,v| excluded_address_attrs.include? k } if common_operator.address
      attrs_to_sync[:common_address_attributes] = common_address_attributes || {}

      unless only_common
        attrs_to_sync[:attributes] = attributes.delete_if{ |k,v| excluded_attrs.include? k }
        address_attributes = address.attributes.delete_if{ |k,v| excluded_address_attrs.include? k } if address
        attrs_to_sync[:address_attributes] = address_attributes || {}
      end

      attrs_to_sync
    end
end
