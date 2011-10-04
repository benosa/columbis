class TouristsController < ApplicationController
  
  def new
    @tourist = Tourist.new
  end

  def create
    @tourist = Tourist.new(params[:tourist])

    respond_to do |format|
      if @tourist.save
        format.html { redirect_to @tourist, :notice => 'Tourist was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @tourist = Tourist.find(params[:id])
  end

  def update
    @tourist = Tourist.find(params[:id])

    respond_to do |format|
      if @tourist.update_attributes(params[:tourist])
        format.html { redirect_to @tourist, :notice => 'Tourist was successfully updated.' }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def index
    @tourists = Tourist.find(:all)
  end

  def show
    @tourist = Tourist.find(params[:id])
  end

  def destroy
    @tourist = Tourist.find(params[:id])
    @tourist.destroy

    respond_to do |format|
      format.html { redirect_to tourists_url }
    end
  end

end
