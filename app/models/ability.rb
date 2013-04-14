# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # TODO: need refactor to case operator
    if user.role == 'admin'
      can :manage, :all #, :company_id => user.company_id
      cannot :manage, Company
      can :manage, Company, :id => user.company_id
      can :manage, DropdownValue, :common=> true
      can :offline_version, User
      can :manage, Task
    elsif user.role == 'boss'
      can :switch_view, User
      can :manage, :all, :company_id => user.company_id
      cannot :manage, Company
      can :manage, Company, :id => user.company_id
      can :read, DropdownValue, :common=> true
      cannot :manage, User, :role => 'admin'
      can :dasboard_index, :user
      can :users_sign_in_as, :user
      can :claims_all, :user
      can :offline_version, User
      can :create, Task
    elsif user.role == 'accountant'
      can :switch_view, User
      can :manage, [CurrencyCourse, Claim, Tourist, Payment], :company_id => user.company_id
      can [:update, :destroy], User, :id => user.id
      can :read, :all, :company_id => user.company_id
      cannot :read, Company
      can :read, Company, :id => user.company_id
      can :claims_all, :user
      can :offline_version, User
      can :create, Task
    elsif user.role == 'supervisor'
      can :manage, Tourist, :company_id => user.company_id
      can [:create, :update], Claim, :company_id => user.company_id
      can [:read, :scroll], Claim, :company_id => user.company_id
      can :update, Payment, :company_id => user.company_id, :approved => false
      can [:update], User, :id => user.id
      can :read, [Country, Region, City]
      can :claims_all, :user
      can :offline_version, User
      can :create, Task
    elsif user.role == 'manager'
      can :manage, Tourist, :company_id => user.company_id
      can [:create, :update], Claim, :company_id => user.company_id, :office_id => user.office_id, :user_id => user.id
      can [:create, :update], Claim, :company_id => user.company_id, :office_id => user.office_id, :assistant_id => user.id
      can [:read, :scroll], Claim, :company_id => user.company_id, :office_id => user.office_id
      can :update, Payment, :claim => { :user_id => user.id }, :approved => false
      can :update, Payment, :claim => { :assistant_id => user.id }, :approved => false
      can [:update], User, :id => user.id
      can :read, [Country, Region, City]
      can :offline_version, User
      can :create, Task
    else
      can [:update, :destroy], User, :id => user.id
    end
  end
end
