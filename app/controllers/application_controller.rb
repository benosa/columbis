class ApplicationController < ActionController::Base
  CURRENTS = %w[company office]
  protect_from_forgery

  CURRENTS.each do |elem|
    helper_method :"current_#{elem}"
  end

  User::ROLES.each do |role|
    helper_method :"is_#{role}?"
  end

  before_filter :check_company_office

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
    render :text => params[:amount].to_f.amount_in_word(params[:currency])
  end

  def get_currency_course
    render :text => CurrencyCourse.actual_course(params[:currency])
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

  protected

  def check_company_office
    if user_signed_in? and (request.path != destroy_user_session_path)
      unless current_company
        redirect_to new_dashboard_company_path unless
          (request.path == new_dashboard_company_path or (request.path == dashboard_companies_path and request.method == 'POST'))
      else
        unless current_office
          redirect_to new_dashboard_office_path unless
            (request.path == new_dashboard_office_path or (request.path == dashboard_offices_path and request.method == 'POST'))
        end
      end
    end
  end

  private

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end

class Float
  def amount_in_word( currency)
    str = RuPropisju.amount_in_word(self, currency)
    str.mb_chars.capitalize.to_s
  end
end
