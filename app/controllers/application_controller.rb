class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_path, :alert => exception.message
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
end

class Float
  def amount_in_word( currency)
    str = RuPropisju.amount_in_word(self, currency)
    str.mb_chars.capitalize.to_s
  end
end
