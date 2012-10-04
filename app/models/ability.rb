# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.role == 'admin'
      can :manage, :all, :company_id => user.company_id
      cannot :manage, Company
      can :manage, Company, :id => user.company_id
      can :manage, DropdownValue, :common=> true
      can :offline_version, User      
    elsif user.role == 'boss'
      can :switch_view, User
      can :search, Claim
      can :manage, :all, :company_id => user.company_id
      cannot :manage, Company
      can :manage, Company, :id => user.company_id
      can :read, DropdownValue, :common=> true
      cannot :manage, User, :role => 'admin'
      can :dasboard_index, :user
      can :users_sign_in_as, :user
      can :claims_all, :user
      can :offline_version, User
    elsif user.role == 'accountant'
      can :switch_view, User
      can :search, Claim
      can :manage, [CurrencyCourse, Client, Claim, Tourist, Payment], :company_id => user.company_id
      can [:update, :destroy], User, :id => user.id
      can :read, :all, :company_id => user.company_id
      cannot :read, Company
      can :read, Company, :id => user.company_id
      can :claims_all, :user
      can :offline_version, User
    elsif user.role == 'supervisor'
      can :manage, [Client, Tourist], :company_id => user.company_id
      can [:create, :update], Claim, :company_id => user.company_id
      can :search, Claim
      can :read, Claim, :company_id => user.company_id
      can [:update], User, :id => user.id
      can :read, [Country, Region, City]
      can :claims_all, :user
      can :offline_version, User
    elsif user.role == 'manager'
      can :manage, [Client, Tourist], :company_id => user.company_id
      can [:create, :update], Claim, :company_id => user.company_id, :office_id => user.office_id, :user_id => user.id
      can :read, Claim, :company_id => user.company_id, :office_id => user.office_id
      can :search, Claim
      can [:update], User, :id => user.id
      can :read, [Country, Region, City]
      can :offline_version, User
    else
      can [:update, :destroy], User, :id => user.id
    end
  end
end
