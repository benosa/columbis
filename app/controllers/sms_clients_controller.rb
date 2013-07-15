class SmsClientsController < ApplicationController
  authorize_resource
  
  respond_to :html
  
  def index
    @clients = Tourist.where('company_id = ? and length(phone_number) > 5', current_company.id).paginate(:page => params[:page], :per_page => per_page)
    
    render :partial => 'list' if request.xhr?
  end
  
  def show
    
  end
  
  def birthday
    @clients = Tourist.where('company_id = ? AND date_part(\'day\', date_of_birth) = date_part(\'day\', CURRENT_DATE) AND date_part(\'month\', date_of_birth) = date_part(\'month\', CURRENT_DATE)', current_company.id).paginate(:page => params[:page], :per_page => per_page)
    
    
    render :partial => 'list' if request.xhr?
  end
end
