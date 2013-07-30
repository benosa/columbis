class SmsSendingsController < ApplicationController
  load_and_authorize_resource
  
  respond_to :html
  
  def index
    @sms_sendings = SmsSending.all
  end

  def show

  end

  def new
    @sms_sendings = SmsSending.new
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
