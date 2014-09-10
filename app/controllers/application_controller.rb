# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  include ApplicationHelper
  include SignInAs::Concerns::RememberAdmin

  CURRENTS = %w[company office]
  protect_from_forgery

  CURRENTS.each do |elem|
    helper_method :"current_#{elem}"
  end

  User::ROLES.each do |role|
    helper_method :"is_#{role}?"
  end

  helper_method :original_user=, :original_user, :logged_as_another_user?

  around_filter :set_time_zone
  around_filter :check_start_trip, :if => :current_user_start_trip?

  before_filter :check_company_office
  skip_before_filter :check_company_office, :only => :sign_out # it's doesn't work :(

  before_filter :check_company_access, :if => :current_company_inactive?
  before_filter :check_subdomain

  before_filter :set_current_controller
  before_filter :check_page_param, :only => [:index, :scroll], :if => proc{ params[:page].present? }

  skip_filter :check_company_office, :check_company_access, :check_subdomain, :only => :current_timestamp

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      if exception.action == :inactive && exception.subject == Company
        redirect_path = dashboard_edit_company_path
      end
      redirect_to redirect_path || root_path, :alert => exception.message
    else
      redirect_to new_user_session_path
    end
  end

  def routing_error
    user_signed_in? ? redirect_to(current_company_root_url) : redirect_to(new_user_session_path)
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

  # def set_session_options_domain
  #   request.session_options[:domain] = request.domain
  # end

  def check_subdomain
    # current_company.subdomain = nil if current_company # To local production
    # Check subdomain only for remote GET requests to proper domain
    return unless request.get? && !request.local? && request.host.index(CONFIG[:domain])
    subdomain = request.host.sub(/\.?#{CONFIG[:domain]}\Z/, '')
    is_public_controller = CONFIG[:public_controllers].include?(params[:controller])
    redirect_url = nil

    if user_signed_in?
      if current_company && !is_public_controller && subdomain != current_company.subdomain
        redirect_url = url_for_current_company
      end
    elsif subdomain.present? && !is_public_controller
      redirect_url = new_user_session_url
    end
    if redirect_url && redirect_url != request.original_url
      flash.keep
      redirect_to redirect_url
    end
  end

  def check_page_param
    entries = params[:page].to_i * per_page
    if CONFIG[:total_entries] && entries > CONFIG[:total_entries]
      params.delete(:page)
      unless request.xhr?
        redirect_to current_path
      else
        render text: ''
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
          message = current_company.name ? t('you_must_add_office') : t('you_must_add_company_name_and_office')
          redirect_to(dashboard_edit_company_path, :alert => message) unless
            (request.path == dashboard_edit_company_path or (request.path == dashboard_company_path(current_company) and request.method == 'POST'))
        end
      end
    end
  end

  def check_company_access
    accessible_controllers = %w[companies user_payments robokassa uploads]
    unless accessible_controllers.include?(controller_name) || is_admin? || devise_controller? || demo_company?
      raise CanCan::AccessDenied.new(I18n.t('companies.messages.company_inactive'), :inactive, Company)
    end
  end

  def skip_verify_authenticity_token?
    request.format == 'application/json'
  end

  private
    def check_start_trip
      path = current_user.start_trip.check_step_actions_path({path: request.path, get: request.get?}, controller, params) if current_user
      redirect_to(path) if path

      yield

      current_user.start_trip.check_step_actions_cookie(cookies[:start_trip_step].to_i, @company, @user, @claim) if current_user
      cookies.delete :start_trip_step
    end

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

    # Overwriting the sign_out redirect path method
    def after_sign_in_path_for(resource)
      current_company ? current_company_root_url : new_dashboard_company_path
    end

    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      new_user_session_url #domain_new_user_session_url
    end

    def set_current_controller
      ::ApplicationController.current = self
    end

    def current_company_inactive?
      !current_company.is_active? if current_company
    end

    def current_user_start_trip?
      current_user.try(:start_trip)
    end

    def original_user=(user)
      self.remember_admin_id = user.id rescue nil
    end

    def original_user
      @original_user ||= (User.find remember_admin_id rescue nil)
    end

    def logged_as_another_user?
      original_user.present?
    end

end
