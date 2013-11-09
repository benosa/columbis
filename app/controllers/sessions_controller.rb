require 'openssl'
require 'base64'

class SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token, :if => :skip_verify_authenticity_token?
  before_filter :check_demo_access, :only => :create, :if => :demo_sign_in?
  before_filter :set_demo_message, :if => proc{ request.subdomain == 'demo' }

  def create
    respond_to do |format|
      format.json do
        resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
        sign_in_with_json(resource_name, resource)
      end

      format.html do
        self.resource = warden.authenticate!(auth_options)
        set_flash_message(:notice, :signed_in) if is_navigational_format?
        sign_in(resource_name, resource)
        session_name_cookie('set', resource)
        respond_with resource, :location => after_sign_in_path_for(resource)
      end
    end
  end

  def sign_in_with_json(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    session_name_cookie('set', resource)
    render :json => {:success => true, name: resource.first_name.to_s + ' ' + resource.last_name.to_s}
  end

  def destroy
    redirect_path = after_sign_out_path_for(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out && is_navigational_format?
    session_name_cookie('delete')
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to redirect_path }
    end
  end

  def failure()
    return render :json => {:success => false, :errors => I18n.t('devise.failure.invalid') }
  end

  private

    def sign_in_with_json(resource_or_scope, resource=nil)
      scope = Devise::Mapping.find_scope!(resource_or_scope)
      resource ||= resource_or_scope
      sign_in(scope, resource) unless warden.user(scope) == resource
      session_name_cookie('set', resource)
      render :json => {:success => true, name: resource.first_name.to_s + ' ' + resource.last_name.to_s}
    end

    def encipher(data_to_encode)
      cipher = OpenSSL::Cipher::Cipher.new("des-ede3-cbc")
      key = "123,ewq"
      cipher.encrypt(key)
      encoded_data = cipher.update(data_to_encode)
      encoded_data << cipher.final
      return Base64.encode64(encoded_data)
    end

    def session_name_cookie(action, resource=nil)
      cookie_key = (CONFIG[:session_key] + '_username').to_sym
      cookie_domain = '.' + CONFIG[:domain] # usefull for subdomain
      if action == 'set'
        cookies[cookie_key] = {
          value: encipher(resource.full_name),
          domain: cookie_domain
        }
      else
        cookies.delete cookie_key, domain: cookie_domain
      end
    end

    def demo_sign_in?
      params[:user][:login] == 'demo' if params[:user]
    end

    def check_demo_access
      cookie_key = (CONFIG[:session_key] + '_visitor').to_sym
      access_allowed = if cookies[cookie_key].present?
        Visitor.find(cookies[cookie_key]).confirmed? rescue false
      else
        false
      end

      unless access_allowed
        sign_out
        set_flash_message :alert, 'demo_reg', :href => CONFIG[:domain] + '/#visitor'
        redirect_to new_user_session_path
      end
    end

    def set_demo_message
      flash.now[:notice] = I18n.t('devise.sessions.new.demo_message')
    end
end