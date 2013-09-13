class PasswordsController < Devise::PasswordsController
  def create
    if params[:user][:generate_password] == '0'
      self.resource = resource_class.send_reset_password_instructions(resource_params)

      if successfully_sent?(resource)
        respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
      else
        respond_with(resource)
      end
    else
      
  end
end