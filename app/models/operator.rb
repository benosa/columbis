class Operator < ActiveRecord::Base
  attr_accessible :name, :register_number, :register_series, :inn, :ogrn, :site,
  				  :insurer, :insurer_address, :insurer_provision, :insurer_contract,
  				  :insurer_contract_date, :insurer_contract_start, :insurer_contract_end,
  				  :address_attributes

  attr_protected :company_id

  belongs_to :company
  has_many :payments, :as => :recipient
  has_one :address, :as => :addressable, :dependent => :destroy

  accepts_nested_attributes_for :address

  validates_presence_of :name
  validates_uniqueness_of :name

  # default_scope :order => :name

  define_index do
    indexes :name, :register_number, :register_series, :inn, :ogrn, :sortable => true
    indexes address(:joint_address), as => :joint_address, :sortable => true
    has :company_id
    # set_property :delta => true
  end

  sphinx_scope(:by_name) { { :order => :name } }
  default_sphinx_scope :by_name

  local_data :extra_columns => :local_data_extra_columns, :extra_data => :local_extra_data

  def self.search_and_sort(options = {})
    filter = options.delete(:filter)
    search_results = search_for_ids(filter, options)
    @search_info = {
      :total_entries => search_results.total_entries,
      :total_pages => search_results.total_pages
    }
    scoped = where(:id => search_results)
    if options[:order].present?
      if options[:order].to_sym == :joint_address
        scoped = scoped.joins(Address.left_join(self)).reorder(Address.order_text(:joint_address, options[:sort_mode]))
      else
        scoped = scoped.reorder("#{options[:order]} #{options[:sort_mode]}")
      end
    end
    scoped
  end

  def self.search_info
    @search_info
  end

  def self.local_data_extra_columns
    [ :address, :address_id ]
  end

  def local_extra_data
    {
      :address => self.address.try(:pretty_full_address),
      :address_id => self.address.try(:id),
    }
  end

end
