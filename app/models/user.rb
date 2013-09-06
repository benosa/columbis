# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  ROLES = %w[admin boss supervisor manager accountant]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :office_id,
                  :login, :first_name, :last_name, :middle_name, :color, :screen_width, :time_zone
  attr_protected :company_id, :as => :admin
  attr_protected :role, :as => [:admin, :boss]

  attr_accessor :phone_code

  belongs_to :company
  belongs_to :office
  has_many :tasks

  before_validation :set_role, :on => :create, :unless => Proc.new{ ROLES.include? self.role  }
  before_validation :generate_login
  before_validation :generate_password
  before_validation :join_phone

  validates_presence_of :role
  validates_presence_of :company_id, :office_id, :unless => Proc.new{ %w[admin boss].include? self.role }
  validates_presence_of :last_name, :first_name
  validates :phone, :length => { minimum: 8 }, uniqueness: true


  before_save do |user|
    for attribute in [:last_name, :first_name, :middle_name]
      user.send "#{attribute}=", user.send(attribute).try(:strip)
    end
  end

  define_index do
    indexes [:last_name, :first_name, :middle_name], :as => :fio, :sortable => true
    indexes :login, :role, :email, :sortable => true
    indexes office(:name), :as => :office, :sortable => true
    has :company_id
    has :office_id

    set_property :delta => true
  end

  sphinx_scope(:by_fio) { { :order => [:last_name, :first_name, :middle_name] } }
  default_sphinx_scope :by_fio

  default_scope :order => [:last_name, :first_name, :middle_name]

  scope :admins, where( role: 'admin')

  def last_boss?
    User.where('role = \'boss\' AND company_id = ? AND id != ?', company_id, id).empty?
  end

  def name_for_list
    first_last_name.blank? ? login : first_last_name
  end

  def first_last_name
    "#{first_name} #{last_name}".strip
  end

  def full_name
    "#{last_name} #{first_name} #{middle_name}".strip
  end

  def self.available_colors
    @available_colors = YAML.load_file("#{Rails.root}/app/assets/colors.yml")['colors'].sort unless @available_colors
    @available_colors
  end

  def available_roles
    case role
    when 'admin'
      ROLES
    when 'boss'
      ROLES - ['admin']
    else
      [role]
    end
  end

  def update_by_params(params = {})
    self.role = params[:role] if available_roles.include?(params[:role])
    params[:role] = self.role

    if params[:password].present?
      update_with_password(params)
    else
      params.delete(:current_password)
      update_without_password(params)
    end
  end

  # Redefine Devise method for refining fields, that can't be deleted without asking for the current password
  def update_without_password(params = {}, *options)
    params.delete(:email)
    super(params)
  end

  def create_new(params)
    self.role = params[:role] if available_roles.include?(params[:role])
    office = Office.where(:id => params[:office_id]).first
    self.password = Office.where(:id => params[:office_id]).first.try(:default_password) if params[:password].blank?
    self.password_confirmation = self.password
    params.delete(:role)
    params.delete(:password)
    self.save(params)
  end

  def join_phone
    self.phone = phone_code.to_s + phone.to_s
  end

  def generate_login
    if first_name.to_s.length > 0 && last_name.to_s.length > 0
      login_temp = Russian.transliterate(first_name)[0] + Russian.transliterate(last_name)
      i = 0
      while !User.where(:login => login_temp + (i > 0 ? i.to_s : '')).empty?
        i += 1
      end
      self.login = login_temp + (i > 0 ? i.to_s : '')
    end
  end

  def generate_password
    self.password = Devise.friendly_token.first(8);
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