# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  ROLES = %w[admin boss supervisor manager accountant]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :office_id, :use_office_password,
                  :login, :first_name, :last_name, :middle_name, :color, :screen_width, :time_zone, :subdomain
  attr_protected :company_id, :as => :admin
  attr_protected :role, :as => [:admin, :boss]

  attr_accessor :phone_code

  belongs_to :company
  belongs_to :office
  has_many :tasks

  before_validation :set_role, :on => :create, :unless => proc{ ROLES.include? self.role  }
  before_validation :generate_login, :on => :create, :if => proc{ self.login.blank?  }
  before_validation :generate_password, :on => :create, :if => proc{ self.password.blank?  }
  before_validation :join_phone

  validates :login, presence: true, uniqueness: true
  validates_presence_of :role
  validates_presence_of :company_id, :office_id, :unless => proc{ %w[admin boss].include? self.role }
  validates_presence_of :last_name, :first_name
  validates :phone, presence: true, length: { minimum: 8 }, uniqueness: true, :unless => proc{ self.role == 'admin' }
  validates :subdomain, uniqueness: true,
    format: { with: /\A[\d\w\-]{3,20}\Z/ }, length: { minimum: 3, maximum: 20 }

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

  # Define methods for check roles: is_admin?, is_boss?...
  ROLES.each do |role|
    define_method :"is_#{role}?" do
      self.role == role
    end
  end

  def update_by_params(params = {}, current_user = nil)
    current_user = self unless current_user
    self.role = params[:role] if available_roles.include?(params[:role])
    params[:role] = self.role

    # Send registration information in case only when user doesn't know his current password (generated or changed by someone else)
    send_registration_info = false
    need_update_with_password = false

    # Currently set use_office_password attribute
    if params[:use_office_password].to_boolean
      if !self.use_office_password && self.office
        self.password = self.office.default_password
        self.use_office_password = true
        send_registration_info = true unless self == current_user
      elsif !self.office
        params.delete(:use_office_password)
      end

    # Set new password
    elsif params[:password].present?
      # User changes password himself, need confirmation and current password
      if self == current_user
        need_update_with_password = true
      # Password is changed by someone who can manage users
      else
        self.password = params[:password]
        send_registration_info = true
      end

    # Currently unset use_office_password attribute and don't fill password, generate one
    elsif self.use_office_password
      generate_password
      self.use_office_password = false
      send_registration_info = true
    end

    # Need save current password to deliver email, because Devise call clean_up_passwords ufter user update
    current_password = self.password || params[:password]

    # Update user
    update_result = if need_update_with_password
      update_with_password(params)
    else
      params.delete(:current_password)
      # update_without_password(params, _current_user: current_user)
      update_without_password(params)
    end

    Mailer.registrations_info(self, current_password).deliver if update_result && send_registration_info
    update_result
  end

  # Redefine Devise method for refining fields, that can't be deleted without asking for the current password
  def update_without_password(params = {}, *args)
    # options = args.extract_options!
    # current_user = options.delete(:_current_user) if options.kind_of?(Hash)
    # # User can not change his email and login without current password, but someone who can manage users can!
    # if current_user.nil? || current_user == self
    #   params.delete(:email)
    #   params.delete(:login)
    # end
    # args << options

    params.delete(:email)
    super(params, *args)
  end

  def create_new(params)
    self.role = params[:role] if available_roles.include?(params[:role])
    if params[:use_office_password].to_boolean
      office = Office.where(:id => params[:office_id]).first
      self.password = office.default_password
      self.password_confirmation = self.password
    end
    params.delete(:role)
    params.delete(:password)
    params.delete(:password_confirmation)
    self.save(params)
  end

  def join_phone
    self.phone = phone_code.to_s + phone.to_s if phone_code
  end

  def self.find_for_database_authentication(conditions)
    self.where(:login => conditions[:login]).first || self.where(:email => conditions[:login]).first
  end

  def self.generate_password_by_mail(attributes={})
    user = User.where(email: attributes[:email]).first
    user.generate_password
    user.save
    Mailer.new_password_instructions(user).deliver
    user
  end

  def self.generate_password
    Devise.friendly_token.first(8)
  end

  def generate_password
    self.password = User.generate_password
  end

  private

    def set_role
      if User.count == 0
        self.role = 'admin'
      else
        self.role = 'boss'
      end
    end

    def generate_login
      if first_name.to_s.length > 0 && last_name.to_s.length > 0
        login = (Russian.transliterate(first_name)[0] + Russian.transliterate(last_name).delete(' ')).downcase
        if User.where(login: login).count > 0
          slogin = ActiveRecord::Base.sanitize(login).gsub("'", '')
          nums = User.select("substring(login from '#{slogin}(\\d*)') as num").where("login ~ '#{slogin}\\d*'").map{|u| u.num.to_i}.sort
          i = 1
          i += 1 while nums.include?(i)
          login = login + i.to_s
        end
        self.login = login
      end
    end
end