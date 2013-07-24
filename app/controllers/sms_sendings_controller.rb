class SmsSendingsController < ApplicationController
  load_and_authorize_resource
  
  respond_to :html
  
  def index
    @sms_sendings = SmsSending.where('company_id = ?', current_company.id).paginate(:page => params[:page], :per_page => per_page)
    render :partial => 'list' if request.xhr?
  end

  def show

  end

  def new
    @sms_sendings = SmsSending.new
    @sms_groups = SmsGroup.where('company_id = ?', current_company.id)
  end

  def edit
    
  end

  def create
    @cart = SmsSending.new(params[:sms_sending])

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: 'added sms sending' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update

  end

  def destroy

  end
end
