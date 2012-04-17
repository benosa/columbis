class Dashboard::UsersController < ApplicationController
  load_and_authorize_resource

  def edit_password
    render :partial => 'edit_password'
  end

  def update_password
    flash[:info] = "Successfully ololol user."
    redirect_to dashboard_users_url
  end

  def new
  end

  def create
    @user = User.new(params[:user])
    @user.company = current_user.company
    @user.role = params[:user][:role] if current_user.available_roles.include?(params[:user][:role])

    @user.password = @user.office.default_password

    if @user.save
      @user.send_reset_password_instructions if @user.office.default_password.blank?
      redirect_to dashboard_users_url, :notice => "Successfully created user."
    else
      render :action => 'new'
    end
  end

  def index
    @offices = Office.accessible_by(current_ability).order(:name)
    @users = User.accessible_by(current_ability).order(:role)
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
