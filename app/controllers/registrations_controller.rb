class RegistrationsController < Devise::RegistrationsController
  def update
    if current_user.update_by_params(params[:user])
      redirect_to edit_user_registration_path, :notice => t('users.messages.updated')
    else
      render :action => 'edit'
    end
  end
end