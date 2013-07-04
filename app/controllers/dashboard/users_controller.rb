# -*- encoding : utf-8 -*-
class Dashboard::UsersController < ApplicationController
  load_and_authorize_resource

  def sign_in_as
    authorize! :users_sign_in_as, current_user

    self.remember_admin_id = current_user.id
    sign_in :user, User.find(params[:user_id])

    redirect_to root_path
  end

  def new
  end

  def create
    if @user.create_new(params[:user].merge(:company_id => current_user.company))
      Mailer.registrations_info(@user).deliver
      redirect_to dashboard_users_url, :notice => t('users.messages.created')
    else
      render :action => 'new'
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
  end

  def update
    if params[:user][:password].present? && params[:user][:id] != current_user
      if @user.update_attribute(:password, params[:user][:password])
        Mailer.registrations_info(@user).deliver
        params[:user].delete(:password)
      end
    end

    if @user.update_by_params(params[:user])
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