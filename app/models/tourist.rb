class Tourist < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :middle_name,
                  :passport_series, :passport_number, :passport_valid_until,
                  :date_of_birth, :phone_number, :potential,
                  :address_attributes

  attr_protected :company_id

  belongs_to :company
  has_many :payments, :as => :payer

  has_many :tourist_claims
  has_many :claims, :through => :tourist_claims
  has_one :address, :as => :addressable, :dependent => :destroy

  accepts_nested_attributes_for :address

  validates_presence_of :first_name, :last_name, :company_id

  scope :clients, where(:potential => false)
  scope :potentials, where(:potential => true)
  scope :by_full_name, order([:last_name, :first_name, :middle_name])

  default_scope by_full_name

  define_index do
    indexes [:last_name, :first_name, :middle_name], :as => :full_name, :sortable => true
    indexes :phone_number, :sortable => true
    indexes address(:joint_address), :as => :joint_address, :sortable => true
    has [:passport_series, :passport_number], :as => :passport
    has :passport_valid_until, :date_of_birth, :type => :datetime
    has :potential, :type => :boolean
    has :company_id
    # set_property :delta => true
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
    "#{last_name} #{first_name.initial}#{middle_name.initial if middle_name}".strip
  end

  def full_name=(name)
    split = name.split(' ', 3)
    self.last_name = split[0]
    self.first_name = split[1]
    self.middle_name = split[2] if split[2]
  end

  alias_method :name, :full_name

end
