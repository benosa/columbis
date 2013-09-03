class SessionsController < Devise::SessionsController
  respond_to :html, :json

  def create
     self.resource = warden.authenticate!(auth_options)
     set_flash_message(:notice, :signed_in) if is_navigational_format?
     sign_in(resource_name, resource)
     # Rails.logger.debug "@session.errors: #{resource.inspect}"
     respond_to do |format|
       format.html {  respond_with resource, :location => after_sign_in_path_for(resource) }
       format.json { render :json => {:success => true} }
     end
  end

  def failure
    render json: { success: false, errors: ['Login information is incorrect, please try again'] }
  end
end