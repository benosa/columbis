# -*- encoding : utf-8 -*-
class AddressesController < ApplicationController
  def new
    @address = Address.new
  end

  def create
    @address = Address.new(params[:address])
    @address.company_id = current_user.company_id

    respond_to do |format|
      if @address.save
        format.html { redirect_to addresses_url, :notice => t('addresses.messages.created') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @address = Address.accessible_by(current_ability).find(params[:id])
  end

  def update
    @address = Address.accessible_by(current_ability).find(params[:id])

    respond_to do |format|
      if @address.update_attributes(params[:address])
        format.html { redirect_to addresses_url, :notice => t('addresses.messages.updated') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def index
    @addresses =
      if search_or_sort?
        search_and_sort(Address, { :with_current_abilities => true })
      else
        Address.accessible_by(current_ability).paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def show
    @address = Address.accessible_by(current_ability).find(params[:id])
  end

  def destroy
    @address = Address.accessible_by(current_ability).find(params[:id])
    @address.destroy

    respond_to do |format|
      format.html { redirect_to addresses_url, :notice => t('addresses.messages.destroyed') }
    end
  end
end
