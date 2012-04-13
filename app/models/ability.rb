class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.role == 'admin'
      can :manage, :all, :company_id => user.company_id
    elsif user.role == 'boss'
      can :manage, :all, :company_id => user.company_id
      cannot :manage, User, :role => 'admin'
      can :dasboard_index, :user
    elsif user.role == 'accountant'
      can :switch_view, User
      can :manage, [CurrencyCourse, Client, Claim, Tourist, Payment], :company_id => user.company_id
      can [:update, :destroy], User, :id => user.id
      can :read, :all, :company_id => user.company_id
    elsif user.role == 'supervisor'
      can :manage, [Client, Tourist], :company_id => user.company_id
      can [:create, :update], Claim, :company_id => user.company_id
      can [:update], User, :id => user.id
    elsif user.role == 'manager'
      can :manage, [Client, Tourist], :company_id => user.company_id
      can [:create, :update], Claim, :company_id => user.company_id, :office_id => user.office_id, :user_id => user.id
      can :read, Claim, :company_id => user.company_id, :office_id => user.office_id
      can [:update], User, :id => user.id
    else
      can [:update, :destroy], User, :id => user.id
    end
  end
end
