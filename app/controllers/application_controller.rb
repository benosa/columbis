class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to users_path, :alert => exception.message
  end

  def get_catalog
    @catalog = Catalog.find(params[:catalog_id])
  end

  def amount_in_word
    render :text => RuPropisju.amount_in_word(params[:amount], params[:currency])
  end

  def get_currency_course
    render :text => CurrencyCourse.actual_course(params[:currency])
  end
end
