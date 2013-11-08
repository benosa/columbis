class UserPaymentsController < ApplicationController
  load_and_authorize_resource

  before_filter :deny_new_payment, only: [:new, :create], :unless => :can_create_new_payment?

  helper_method :can_create_new_payment?

  def index
    @user_payments =
      if search_or_sort?
        options = search_and_sort_options(:with => current_ability.attributes_for(:read, UserPayment))
        set_filter_to(options)
        search_paginate(UserPayment.search_and_sort(options), options)
      else
        UserPayment.where(:status => 'new').accessible_by(current_ability).order("updated_at ASC").paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def new
    @user_payment.tariff = current_company.tariff
  end

  def create
    @user_payment.user = current_user
    @user_payment.company = current_company
    if @user_payment.save
      redirect_to user_payments_path, :notice => t('.user_payments.messages.created')
    else
      render :action => 'new'
    end
  end

  def destroy
    @user_payment.destroy
    redirect_to user_payments_path, :notice => t('.user_payments.messages.destroyed')
  end

  private

    def can_create_new_payment?
      current_company.ready_for_payment? && UserPayment.can_create_new?(current_company)
    end

    def deny_new_payment
      redirect_to user_payments_path, :alert => t('.user_payments.messages.already_exists')
    end

    def set_filter_to(options)
      if params[:approvedable] == "all" || params[:approvedable].blank?
        options[:with].delete(:status_crc32)
      else
        options[:with][:status_crc32] = params[:approvedable].to_crc32
      end
    end
end
