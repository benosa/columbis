# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  attr_reader :user, :company

  def initialize(user)
    @user = user || User.new
    @company = @user.company || Company.new

    role = @user.role.to_s
    role = "unpaid_#{role}" unless @user.is_admin? || @company.is_active? || company.subdomain == 'demo'
    if self.respond_to?(role)
      self.send(role)
    else
      can [:update, :destroy], User, :id => @user.id
    end

    demo_restriction
  end

  def admin
    can :manage, :all
    cannot :manage, Company
    can :manage, Company, :id => user.company_id
    cannot [:new, :create], Company if company
  end

  def boss
    can :manage, Company, :id => user.company_id
    cannot [:new, :create], Company if company
    can :manage, [Address, Catalog, City, Claim, Client, Country, CurrencyCourse, DropdownValue,
      Item, ItemField, Note, Office, Operator, Payment, Printer, SmsGroup, SmsSending, Tourist, User,
      Boss::Widget, UserPayment], :company_id => user.company_id
    cannot(:destroy, User) { |u| u.company_owner? }
    cannot :destroy, UserPayment
    can :destroy, UserPayment, :status => 'new', :user => user
    can :read, :robokassa_pay
    can :manage, Flight, :claim => { :company_id => user.company_id }
    can :manage, SmsTouristgroup, :sms_group => { :company_id => user.company_id }
    can :manage, UserMailer, :task => { :user => user }
    can :read, Operator, :common => true
    can :read, [Country, City], :common => true
    can :read, DropdownValue, :common=> true
    can :read, Region
    can :create, Task
    can :read, Task, :user_id => user.id
    cannot :manage, User, :role => 'admin'
    can :dasboard_index, :user
    can :users_sign_in_as, :user
    can :offline_version, User
    can :switch_view, User
  end

  def accountant
    can :read, [Company, Address, Catalog, City, Claim, Client, Country, CurrencyCourse, DropdownValue,
      Item, ItemField, Note, Office, Operator, Payment, Printer, SmsGroup, SmsSending, Tourist, User],
      :company_id => user.company_id
    can :manage, [CurrencyCourse, Claim, Tourist, Payment], :company_id => user.company_id
    can :manage, UserMailer, :task => { :user => user }
    can :read, Flight, :claim => { :company_id => user.company_id }
    can [:update, :destroy], User, :id => user.id
    can :read, Operator, :common => true
    can :read, [Country, City], :common => true
    can :read, DropdownValue, :common=> true
    can :read, Region
    can :create, Task
    can :read, Task, :user_id => user.id
    cannot :read, User, :role => 'admin'
    can :offline_version, User
    can :read, [Country, City], :common => true
    can :switch_view, User
  end

  def supervisor
    can :manage, Tourist, :company_id => user.company_id
    can [:create, :update, :lock, :unlock, :printer], Claim, :company_id => user.company_id
    can [:read, :scroll], Claim, :company_id => user.company_id
    can :update, Payment, :company_id => user.company_id, :approved => false
    can [:update], User, :id => user.id
    can :read, Operator, :company_id => user.company_id
    can :read, Operator, :common => true
    can :read, [Country, City], :company_id => user.company_id
    can :read, [Country, City], :common => true
    can :read, Region
    can :offline_version, User
    can :create, Task
    can :read, Task, :user_id => user.id
  end

  def manager
    can :manage, Tourist, :company_id => user.company_id
    can [:create, :update, :lock, :unlock, :printer], Claim, :company_id => user.company_id, :office_id => user.office_id, :user_id => user.id
    can [:create, :update, :lock, :unlock, :printer], Claim, :company_id => user.company_id, :office_id => user.office_id, :assistant_id => user.id
    can [:read, :scroll], Claim, :company_id => user.company_id, :office_id => user.office_id
    can :update, Payment, :claim => { :user_id => user.id }, :approved => false
    can :update, Payment, :claim => { :assistant_id => user.id }, :approved => false
    can [:update], User, :id => user.id
    can :read, Operator, :company_id => user.company_id
    can :read, Operator, :common => true
    can :read, [Country, City], :company_id => user.company_id
    can :read, [Country, City], :common => true
    can :read, Region
    can :offline_version, User
    can :create, Task
    can :read, Task, :user_id => user.id
  end

  def demo_restriction
    # Restrict abilities for demo company and user
    if user && !user.is_admin? && company.subdomain == 'demo'
      cannot [:update, :destroy], Company
      cannot([:update, :destroy], User) { |u| u.login == 'demo' }
    end
  end

  def unpaid_boss
    can :read, Company, :id => user.company_id
    cannot [:new, :create], Company if company
    can :read, [Address, Catalog, City, Claim, Client, Country, CurrencyCourse, DropdownValue,
      Item, ItemField, Note, Office, Operator, Payment, Printer, SmsGroup, SmsSending, Tourist, User,
      Boss::Widget, UserPayment], :company_id => user.company_id
    can :manage, UserPayment, :company_id => user.company_id
    cannot(:destroy, User) { |u| u.company_owner? }
    cannot :destroy, UserPayment
    can :destroy, UserPayment, :status => 'new', :user => user
    can :read, :robokassa_pay
    can :read, Flight, :claim => { :company_id => user.company_id }
    can :read, SmsTouristgroup, :sms_group => { :company_id => user.company_id }
    can :read, UserMailer, :task => { :user => user }
    can :read, [Country, City], :common => true
    can :read, DropdownValue, :common=> true
    can :read, Region
    can :read, Task, :user_id => user.id
    cannot :manage, User, :role => 'admin'
  end

  def unpaid_accountant
    can [:read, :scroll], Claim, :company_id => user.company_id
  end


  def unpaid_supervisor
    can [:read, :scroll], Claim, :company_id => user.company_id
  end


  def unpaid_manager
    can [:read, :scroll], Claim, :company_id => user.company_id, :office_id => user.office_id
  end

end
