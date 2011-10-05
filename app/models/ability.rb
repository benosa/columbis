class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role == "admin"
      can :manage, :all
    elsif user.role == "accountant"
      can :manage, CurrencyCourse
    else
      can [:update, :destroy], User, :id => user.id
      can :read, :all
    end
  end
end

