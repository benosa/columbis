class User < ActiveRecord::Base
  ROLES = %w[admin boss manager accountant]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :office_id,
                  :login, :first_name, :last_name, :middle_name, :color
  attr_protected :company_id, :as => :admin
  attr_protected :role, :as => [:admin, :boss]

  belongs_to :company
  belongs_to :office

  before_validation :set_role, :on => :create, :unless => Proc.new{ ROLES.include? self.role  }

  validates_uniqueness_of :login
  validates_presence_of :login, :role
  validates_presence_of :company_id, :office_id, :unless => Proc.new{ %w[admin boss].include? self.role }


  def last_boss?
    User.where('role = \'boss\' AND company_id = ? AND id != ?', company_id, id).empty?
  end

  def first_last_name
    "#{first_name} #{last_name}".strip
  end

  def full_name
    "#{last_name} #{first_name} #{middle_name}".strip
  end

  def self.available_colors
    colors = YAML.load_file("#{Rails.root}/app/assets/colors.yml")
    colors['colors'].sort
  end

  def available_roles
    case role
    when 'admin'
      ROLES
    when 'boss'
      ROLES - ['admin']
    when 'accountant'
      [role]
    when 'manager'
      [role]
    else
      []
    end
  end

  private

  def set_role
    if User.count == 0
      self.role = 'admin'
    else
      self.role = 'boss'
    end
  end
end
