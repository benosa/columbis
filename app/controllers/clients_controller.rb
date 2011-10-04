class ClientsController < ApplicationController
  def new
    @client = Client.new
  end

  def create
    @client = Client.new(params[:client])

    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, :notice => 'Client was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])

    respond_to do |format|
      if @client.update_attributes(params[:client])
        format.html { redirect_to @client, :notice => 'Client was successfully updated.' }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def index
    @clients = Client.find(:all)
  end

  def show
    @client = Client.find(params[:id])
  end

  def destroy
    @client = Client.find(params[:id])
    @client.destroy

    respond_to do |format|
      format.html { redirect_to clients_url }
    end
  end
end
