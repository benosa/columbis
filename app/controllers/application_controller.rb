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

  helper_method :"logged_as_another_user?"

  before_filter :set_user_time_zone, :except => [:set_time]

  before_filter :check_company_office, :except => [:set_time]
  skip_before_filter :check_company_office, :only => [:sign_out] # it's doesn't work :(

  before_filter :set_current_controller, :except => [:set_time]

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
    render :text => params[:amount].to_f.amount_in_word(params[:currency] || CurrencyCourse.PRIMARY_CURRENCY)
  end

  def get_currency_course
    render :text => CurrencyCourse.actual_course(params[:currency] || CurrencyCourse.PRIMARY_CURRENCY)
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
  
  def set_time
    respond_to do |format|
      format.js { render :text => "#{Time.zone.now.strftime("%H:%M:%S")}" }
    end
  end

  protected

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
  
  def set_user_time_zone
    Time.zone = 'Moscow'
     if !current_user.nil? && !current_company.time_zone.nil?
       Time.zone = current_company.time_zone
     end
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
