class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role == 'admin'
      can :manage, :all
    elsif user.role == 'accountant'
      can :manage, CurrencyCourse
      can :manage, Country
      can :manage, City
      can :manage, DropdownValue
      can :manage, Claim
      can :manage, Tourist
      can :manage, Payment
      can [:update, :destroy], User, :id => user.id
      can :read, :all
    elsif user.role == 'manager'
      can :manage, Country
      can :manage, City
      can :manage, DropdownValue

      can :manage, Claim
      can :manage, Tourist
      can :manage, Payment
      can [:update, :destroy], User, :id => user.id
      can :read, :all
    else
      can [:update, :destroy], User, :id => user.id
    end
  end
end
