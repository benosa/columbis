class SessionsController < Devise::SessionsController
  #skip_before_filter :verify_authenticity_token, :only => :create
  #skip_before_filter :allow_params_authentication!, :only => :create

  def create
    if params[:user] && params[:user][:login].to_s == ''
      allow_params_authentication!
      params[:user][:login] = params[:user][:check]
      params[:user].delete('check')
      respond_to do |format|
        format.json do
          resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
          sign_in_with_json(resource_name, resource)
        end

        format.html do
          self.resource = warden.authenticate!(auth_options)
          set_flash_message(:notice, :signed_in) if is_navigational_format?
          sign_in(resource_name, resource)
          respond_with resource, :location => after_sign_in_path_for(resource)
        end
      end
    else
      redirect_to new_user_session_path
    end
  end

  def sign_in_with_json(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    render :json => {:success => true, name: resource.first_name.to_s + ' ' + resource.last_name.to_s}
  end

  def failure()
    return render :json => {:success => false, :errors => I18n.t('devise.failure.invalid') }
  end
end