class Dashboard::UsersController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => :new

  def new
    @user = User.new
  end

  def index
    @users = User.where(:company_id => current_user.company_id).accessible_by(current_ability)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to @user, :notice => 'User was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to root_url, :notice => "Successfully destroyed user."
  end
end
