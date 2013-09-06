# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  include ApplicationHelper
  include SignInAs::Concerns::RememberAdmin

  CURRENTS = %w[company office]
  UNSUBDOMAIN_CONTROLLERS = ["devise/sessions", "devise/passwords", "registrations"]
  protect_from_forgery

  CURRENTS.each do |elem|
    helper_method :"current_#{elem}"
  end

  User::ROLES.each do |role|
    helper_method :"is_#{role}?"
  end

  helper_method :"logged_as_another_user?"

  around_filter :set_time_zone

  before_filter :check_company_office, :except => [:current_timestamp]
  skip_before_filter :check_company_office, :only => [:sign_out] # it's doesn't work :(

  before_filter :set_current_controller, :except => [:current_timestamp]
  before_filter :check_subdomain
  before_filter :set_session_options_domain

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      redirect_to root_path, :alert => exception.message
    else
      redirect_to new_user_session_path, :alert => exception.message
    end
  end

  def get_catalog
    @catalog = Catalog.find(params[:catalog_id])
  end

  def amount_in_word
    render :text => params[:amount].to_f.amount_in_word(params[:currency] || CurrencyCourse::PRIMARY_CURRENCY)
  end

  def get_currency_course
    render :text => CurrencyCourse.actual_course(params[:currency] || CurrencyCourse::PRIMARY_CURRENCY)
  end

  def current_timestamp
    render :text => current_zone_datetime
  end

  CURRENTS.each do |elem|
    define_method :"current_#{elem}" do
      current_user.try(:"#{elem}") if current_user
    end
  end

  # this block provides methods like is_admin? or is_accountant?
  # wich is dynamically created from the User::ROLES array
  User::ROLES.each do |role|
    define_method :"is_#{role}?" do
      if current_user
        current_user.role == role
      else
        false
      end
    end
  end

  class << self

    attr_accessor :current

  end

  protected

  def set_session_options_domain
    request.session_options[:domain] = request.domain
  end

  def check_subdomain
    base_host = request.host.split('.')
    l = base_host.length
    if base_host[l-2] == "test"
      return
    end
    host = ""
    if l >= 2 && (base_host[l-3] == "dev" || base_host[l-3] == "staging")
      host = base_host[l-3] + "."
    end
    host = host + base_host[l-2] + "." + base_host[l-1]
    port = request.port.blank? ? "" : ":" + request.port.to_s
    protocol = request.protocol

    if user_signed_in?
      if base_host[0] != current_company.subdomain && !UNSUBDOMAIN_CONTROLLERS.any? {|u| u == params[:controller] }
        redirect_to protocol + current_company.subdomain + "." + host + port
      end
    else
      if request.host != host
        redirect_to protocol + host + port + new_user_session_path
      end
    end
  end

  def check_company_office
    if user_signed_in? and request.path != destroy_user_session_path
      unless current_company
        redirect_to(new_dashboard_company_path, :alert => t('you_must_add_company_info')) unless
          (request.path == new_dashboard_company_path or (request.path == dashboard_companies_path and request.method == 'POST'))
      else
        unless current_office
          redirect_to(dashboard_edit_company_path, :alert => t('you_must_add_office')) unless
            (request.path == dashboard_edit_company_path or (request.path == dashboard_company_path(current_company) and request.method == 'POST'))
        end
      end
    end
  end

  private

  def set_time_zone
    old_time_zone = Time.zone
    if user_signed_in? && current_company && current_company.time_zone
      new_time_zone = ActiveSupport::TimeZone[current_company.time_zone]
    end
    Time.zone = new_time_zone || 'Moscow'
    yield
  ensure
    Time.zone = old_time_zone
  end

  def logged_as_another_user?
    self.remember_admin_id?
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def set_current_controller
    ::ApplicationController.current = self
  end

end
