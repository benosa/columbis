class ConfirmationsController < Devise::ConfirmationsController
  def create
    if params[:user][:email].to_s == ''
      params[:user][:email] = params[:user][:check]
      params[:user].delete('check')
      self.resource = resource_class.send_confirmation_instructions(resource_params)

      if successfully_sent?(resource)
        respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))
      else
        resource.errors.messages[:email] = [I18n.t('errors.messages.maybe_not_found')]
        respond_with(resource)
      end
    else
      redirect_to new_user_confirmation_path
    end

  end
end