class RegistrationsController < Devise::RegistrationsController

  before_filter only: [:update, :destroy] do
    authorize! params[:action].to_sym, current_user
  end

  rescue_from CanCan::AccessDenied do |exception|
    if [:update, :destroy].include?(exception.action) && can?(:read, exception.subject)
      message = t("users.messages.user_cant_be_#{exception.action == :update ? 'updated' : 'destroyed'}")
      redirect_to edit_user_registration_path, :alert => message
    else
      redirect_to root_path, :alert => exception.message
    end
  end

  def update
    @user = current_user
    @user.role = params[:user][:role] if current_user && current_user.available_roles.include?(params[:user][:role])
    params[:user][:role] = @user.role
    if @user.update_by_params(params[:user])
      redirect_to edit_user_registration_path, :notice => t('users.messages.updated')
    else
      render :action => 'edit'
    end
  end

  def create
    build_resource
    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_to do |format|
          format.json { render :json => {:success => true} }
          format.html { respond_with resource, :location => after_sign_up_path_for(resource) }
        end
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_to do |format|
          format.json { render :json => {:success => true} }
          format.html { respond_with resource, :location => after_inactive_sign_up_path_for(resource) }
        end
      end
    else
      clean_up_passwords resource
      errors = {}
      resource.errors.messages.each do |key, value|
        errors[key] = resource.errors.full_message(key,value[0])
      end

      respond_to do |format|
        format.json { render :json => {:success => false, :errors => errors } }
        format.html { respond_with resource }
      end
    end
  end

  private

    def sign_up(resource_name, resource)
      sign_in(resource_name, resource)
    end

    def after_sign_up_path_for(resource)
      new_user_session_path
    end

    def after_inactive_sign_up_path_for(resource)
      new_user_session_path
    end
end