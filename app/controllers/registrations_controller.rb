class RegistrationsController < Devise::RegistrationsController
  def update
    if current_user.update_by_params(params[:user])
      redirect_to edit_user_registration_path, :notice => t('users.messages.updated')
    else
      render :action => 'edit'
    end
  end

  private

    def after_sign_up_path_for(resource)
      new_user_session_path
    end

    def after_inactive_sign_up_path_for(resource)
      new_user_session_path
    end
end