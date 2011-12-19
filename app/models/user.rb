class User < ActiveRecord::Base
  ROLES = %w[admin manager accountant]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :company_id,
                  :login, :first_name, :last_name, :middle_name, :role, :office_id, :color

  belongs_to :company
  belongs_to :office

  validates_uniqueness_of :login
  validates_presence_of :login, :role, :office_id

  before_validation :set_role, :on => :create

  def first_last_name
    "#{first_name} #{last_name}".strip
  end

  def full_name
    "#{last_name} #{first_name} #{middle_name}".strip
  end

  def self.available_colors
    colors = YAML.load_file("#{Rails.root}/app/assets/colors.yml")
    colors['colors']
  end

  private

  def set_role
    if User.count == 0
      self.role = 'admin'
    else
      self.role = 'manager'
    end
  end
end
