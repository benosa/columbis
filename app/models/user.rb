class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :login, :first_name, :last_name, :middle_name, :role, :office_id, :color

  belongs_to :office

  validates_uniqueness_of :login
  validates_presence_of :login, :role, :office_id

  ROLES = %w[admin manager accountant]

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
end
