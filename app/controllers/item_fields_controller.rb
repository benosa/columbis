class ItemFieldsController < ApplicationController
  before_filter :get_catalog

  def new
    @item_field = ItemField.new(:catalog_id => params[:catalog_id])
  end

  def create
    @item_field = ItemField.new(params[:item_field])

    respond_to do |format|
      if @item_field.save
        format.html { redirect_to catalog_path(@item_field.catalog_id), :notice => 'ItemField was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @item_field = ItemField.find(params[:id])
  end

  def update
    @item_field = ItemField.find(params[:id])

    respond_to do |format|
      if @item_field.update_attributes(params[:item])
        format.html { redirect_to catalog_path(@item_field.catalog_id), :notice => 'ItemField was successfully updated.' }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def index
  end

  def show
    @item_field = ItemField.find(params[:id])
  end

  def destroy
    @item_field = ItemField.find(params[:id])
    @item_field.destroy

    respond_to do |format|
      format.html { redirect_to catalog_path(@item_field.catalog_id) }
    end
  end
end
