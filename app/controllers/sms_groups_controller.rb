class SmsGroupsController < ApplicationController
  
  load_and_authorize_resource
  
  before_filter :sms_groups, :except => [:create]
  before_filter :sms_group_new, :only => [:index, :birthday, :show]
  
  respond_to :html
  
  def index
    @clients = Tourist.where('company_id = ? and length(phone_number) > 5', current_company.id).paginate(:page => params[:page], :per_page => per_page)
    render :partial => 'list' if request.xhr?
  end
  
  def show
    @sms_group = SmsGroup.find(params[:id])
    @clients = @sms_group.tourists.where('company_id = ? and length(phone_number) > 5', current_company.id).paginate(:page => params[:page], :per_page => per_page)
    render :partial => 'list' if request.xhr?
  end

  def create
    @sms_group = SmsGroup.new(params[:sms_group])

    respond_to do |format|
      @sms_group[:company_id] = current_company.id
      if @sms_group.save
        format.html { redirect_to sms_groups_path, notice: 'added sms group' }
      else
        format.html { render action: 'index' }
      end
    end
  end
  
  def birthday
    @clients = Tourist.where('company_id = ? AND date_part(\'day\', date_of_birth) = date_part(\'day\', CURRENT_DATE) AND date_part(\'month\', date_of_birth) = date_part(\'month\', CURRENT_DATE)', current_company.id).paginate(:page => params[:page], :per_page => per_page)
    render :partial => 'list' if request.xhr?
  end
  
  def batch_add_to_group
    redirect_to sms_groups_path
  end
  
private

  def sms_group_new
    @sms_group_new = SmsGroup.new
  end
  
  def sms_groups
    @sms_groups = SmsGroup.where('company_id = ?', current_company.id)
  end
end
