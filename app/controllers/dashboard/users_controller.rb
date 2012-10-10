class Dashboard::UsersController < ApplicationController
  load_and_authorize_resource

  def sign_in_as
    authorize! :users_sign_in_as, current_user

    self.remember_admin_id = current_user.id
    sign_in :user, User.find(params[:user_id])

    redirect_to root_path
  end

  def edit_password
    unless can? :create, User
      redirect_to dashboard_users_url
    end
  end

  def update_password
    if can? :create, User
      if @user.update_attributes(params[:user])
        Mailer.registrations_info(@user).deliver
      else
        render :edit_password
        return
      end
    end
    redirect_to dashboard_users_url
  end

  def new
  end

  def create
    @user = User.new(params[:user])
    @user.company = current_user.company
    @user.role = params[:user][:role] if current_user.available_roles.include?(params[:user][:role])
    @user.password = @user.office.default_password if @user.password.blank?

    if @user.save
      Mailer.registrations_info(@user).deliver
      redirect_to dashboard_users_url, :notice => "Successfully created user."
    else
      render :action => 'new'
    end
  end

  def index
    @can_search_by_office = (is_admin? or is_boss? or is_supervisor?)
    @can_search_by_office = false
    @users =
      if search_or_sort?
        search_and_sort(User, {
          :with_current_abilities => true,
          :include => :office,
          :order => "office asc, #{sort_col} #{sort_dir}",
          :sort_mode => :extended
        })
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
    @user.role = params[:user][:role] if current_user.available_roles.include?(params[:user][:role])
    params[:user][:role] = @user.role
    if @user.update_by_params(params[:user])
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
