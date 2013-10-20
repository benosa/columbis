class UserPaymentsController < ApplicationController
  load_and_authorize_resource

  def index
    @user_payments = UserPayment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_payments }
    end
  end

  def show
    @user_payment = UserPayment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_payment }
    end
  end

  def new
  end

  def edit
  end

  def create
    @user_payment = UserPayment.new(params[:user_payment])

    respond_to do |format|
      if @user_payment.save
        format.html { redirect_to @user_payment, notice: 'User payment was successfully created.' }
        format.json { render json: @user_payment, status: :created, location: @user_payment }
      else
        format.html { render action: "new" }
        format.json { render json: @user_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user_payment = UserPayment.find(params[:id])

    respond_to do |format|
      if @user_payment.update_attributes(params[:user_payment])
        format.html { redirect_to @user_payment, notice: 'User payment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user_payment = UserPayment.find(params[:id])
    @user_payment.destroy

    respond_to do |format|
      format.html { redirect_to user_payments_url }
      format.json { head :no_content }
    end
  end
end
