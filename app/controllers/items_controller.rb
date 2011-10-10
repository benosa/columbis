class ItemsController < ApplicationController
  before_filter :get_catalog

  def new
    @item = Item.new(:catalog_id => params[:catalog_id])
    @catalog.item_fields.each do
      @item.notes.build
    end
  end

  def create
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to catalog_path(@item.catalog_id), :notice => 'Item was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to catalog_path(@item.catalog_id), :notice => 'Item was successfully updated.' }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def index
  end

  def show
    @item = Item.find(params[:id])
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to catalogs_url }
    end
  end
end
