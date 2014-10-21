# -*- encoding : utf-8 -*-
class Dashboard::UsersController < ApplicationController
  include UsersHelper

  load_and_authorize_resource
  skip_authorize_resource only: :edit

  rescue_from CanCan::AccessDenied do |exception|
    if [:update, :destroy].include?(exception.action) && can?(:read, exception.subject)
      flash.now[:alert] = t("users.messages.user_cant_be_#{exception.action == :update ? 'updated' : 'destroyed'}")
      render :action => 'edit'
    else
      redirect_to root_path, :alert => exception.message
    end
  end

  def sign_in_as
    authorize! :users_sign_in_as, current_user

    begin
      user = User.find(params[:user_id])
      sign_in :user, user
      self.original_user, @current_user = current_user, user
    ensure
      redirect_to root_path
    end
  end

  def new
    if can?(:add_user, :user)
      @user.role = 'manager'
    else
      redirect_to dashboard_users_url, :alert => t('users.messages.user_cant_be_created')
    end
  end

  def create
    if can?(:add_user, :user)
      @user.company = current_company
      if @user.create_new(params[:user], current_user)
        redirect_to dashboard_users_url, :notice => t('users.messages.created')
      else
        render :action => 'new'
      end
    else
      redirect_to dashboard_users_url, :alert => t('users.messages.user_cant_be_created')
    end
  end

  def index
    @can_search_by_office = (is_admin? or is_boss? or is_supervisor?)
    @users =
      if search_or_sort?
        options = {
          :with_current_abilities => true,
          :include => :office,
          :order => "office asc, #{sort_col} #{sort_dir}",
          :sort_mode => :extended
        }
        options[:with] = { :office_id => params[:office_id] } if params[:office_id].present?
        options[:with] = { :company_id => params[:company_id] } if params[:company_id].present?
        search_and_sort(User, options)
      else
        User.accessible_by(current_ability).
            includes(:office).reorder(['offices.name', :last_name, :first_name, :middle_name]).
            paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def show
  end

  def edit
    authorize! :read, @user
  end

  def update
    if @user.update_by_params(params[:user], current_user)
      redirect_to dashboard_users_url, :notice => t('users.messages.updated')
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to dashboard_users_url, :notice => t('users.messages.destroyed')
  end
end