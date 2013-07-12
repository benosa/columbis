class SmsClientsController < ApplicationController
  # load_and_authorize_resource
  
  respond_to :html
  
  def index
    @clients = Tourist.where('company_id = ? and length(phone_number) > 5', current_company.id).paginate(:page => params[:page], :per_page => per_page)
    
    render :partial => 'list' if request.xhr?
  end
  
  def show
    
  end
end
