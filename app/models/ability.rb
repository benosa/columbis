class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role == "admin"
      can :manage, :all
    else
      can [:update, :destroy], User, :id => user.id
      can :read, :all
    end
  end
end
