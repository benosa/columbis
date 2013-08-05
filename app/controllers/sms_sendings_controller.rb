class SmsSendingsController < ApplicationController
  load_and_authorize_resource
  before_filter :sms_groups
  
  respond_to :html
  
  def index
    @sms_sendings = SmsSending.current_company(current_company.id).paginate(:page => params[:page], :per_page => per_page)
    render :partial => 'list' if request.xhr?
  end

  def show
    
  end

  def new
    @sms_sendings = SmsSending.new
  end

  def edit
    @sms_sendings = SmsSending.find(params[:id])
  end

  def create
    params[:sms_sending][:company_id] = current_company.id
    @sms_sending = SmsSending.new(params[:sms_sending])

    if @sms_sending.save
      redirect_to sms_sendings_path, notice: 'добавлена новая рассылка'
    else
      render action: 'new', alert: 'error =('
    end
  end

  def update
    
  end

  def destroy
    @sms_sendings = SmsSending.find(params[:id])
    @sms_sendings.destroy
    redirect_to sms_sendings_path, notice: 'рассылка была удалена'
  end

private

  def sms_groups
    @sms_groups = SmsGroup.current_company(current_company.id)
  end
end
