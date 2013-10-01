class PasswordsController < Devise::PasswordsController
  def create
    if params[:user][:email].to_s == ''
      params[:user][:email] = params[:user][:check]
      params[:user].delete('check')
      if params[:user][:generate_password] == '0'
        self.resource = resource_class.send_reset_password_instructions(resource_params)
      else
        self.resource = User.generate_password_by_mail(resource_params)
      end
      if successfully_sent?(resource)
        respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
      else
        resource.errors.messages[:email] = [I18n.t('errors.messages.maybe_not_found')]
        respond_with(resource)
      end
    else
      redirect_to new_user_password_path
    end
  end
end