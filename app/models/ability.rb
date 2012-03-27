class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role == 'admin'
      can :manage, :all
    elsif user.role == 'boss'
      can :manage, [Company, Printer, CurrencyCourse, Country, City, Client, DropdownValue, Claim, Tourist, Office, Payment, User], :company_id => user.company_id
      can :dasboard_index, :user
    elsif user.role == 'accountant'
      can :switch_view, User
      can :manage, [CurrencyCourse, Country, City, Client, DropdownValue, Claim, Tourist, Payment], :company_id => user.company_id
      can [:update, :destroy], User, :id => user.id, :company_id => user.company_id
      can :read, :all, :company_id => user.company_id
    elsif user.role == 'manager'
      can :manage, Country
      can :manage, City
      can :manage, Client
      can :manage, DropdownValue

      can [:create, :update], Claim
      can :manage, Tourist
      can :manage, Payment #, :approved => false
      can [:update], User, :id => user.id
      can :read, :all, :company_id => user.company_id
    else
      can [:update, :destroy], User, :id => user.id
    end
  end
end
