# -*- encoding : utf-8 -*-
class ClientsController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def new
  end

  def create
    @client.company = current_company
    if @client.save
      redirect_to @client, :notice => 'Client was successfully created.'
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    @client.company = current_company
    if @client.update_attributes(params[:client])
      redirect_to @client, :notice => 'Client was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    @client.destroy
    redirect_to clients_url
  end
end
