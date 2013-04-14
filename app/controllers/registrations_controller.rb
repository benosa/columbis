class RegistrationsController < Devise::RegistrationsController
  def update
    @user = current_user
    @user.role = params[:user][:role] if current_user.available_roles.include?(params[:user][:role])
    params[:user][:role] = @user.role
    if @user.update_by_params(params[:user])
      redirect_to edit_user_registration_path, :notice => t('users.messages.updated')
    else
      render :action => 'edit'
    end
  end
end