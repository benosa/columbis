class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to users_path, :alert => exception.message
  end

  def get_catalog
    @catalog = Catalog.find(params[:catalog_id])
  end
end
