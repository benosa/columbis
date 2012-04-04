class PaymentsController < ApplicationController
  load_and_authorize_resource

  def index
    @payments = Payment.where(:company_id => current_company.id).order('claim_id ASC')
  end

  def show
  end

  def new
  end

  def create
    @payment.company = current_company
    if @payment.save
      redirect_to @payment, :notice => "Successfully created payment."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    @payment = Payment.find(params[:id])
    if @payment.update_attributes(params[:payment])
      redirect_to @payment, :notice  => "Successfully updated payment."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy
    redirect_to payments_url, :notice => "Successfully destroyed payment."
  end
end
