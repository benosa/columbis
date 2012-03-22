class Dashboard::UsersController < ApplicationController
  load_and_authorize_resource

  def resent_password
    @user.update_attribute(:reset_password_token, User.reset_password_token)
    @user.send_reset_password_instructions
    redirect_to dashboard_users_url, :notice => "Mail with instrictions send to user"
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.company = current_user.company
    @user.password = User.reset_password_token #won't actually be used...
    @user.reset_password_token = User.reset_password_token
    @user.role = params[:user][:role] if current_user.available_roles.include?(params[:user][:role])
    if @user.save
      @user.send_reset_password_instructions
      redirect_to dashboard_users_url, :notice => "Successfully created user."
    else
      render :action => 'new'
    end
  end

  def index
    @users = User.where(:company_id => current_user.company_id).accessible_by(current_ability)
  end

  def show
  end

  def edit
  end

  def update
    @user.role = params[:user][:role] if current_user.available_roles.include?(params[:user][:role])
    params[:user][:role] = @user.role
    if @user.update_attributes(params[:user])
      redirect_to dashboard_users_url, :notice => 'User was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to dashboard_users_url, :notice => "Successfully destroyed user."
  end
end
