class RegistrationsController < Devise::RegistrationsController

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
        return render :json => {:success => true}
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        return render :json => {:success => true}
      end
    else
      clean_up_passwords resource
      return render :json => {:success => false}
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