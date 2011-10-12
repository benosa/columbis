class ItemsController < ApplicationController
  before_filter :get_catalog
  before_filter :load_item, :only => [:edit, :update, :show, :destroy]

  def new
    @item = Item.new(:catalog_id => params[:catalog_id])
    @catalog.item_fields.each do |item_field|
      @item.notes.build(:item_field_id => item_field.id)
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
   @catalog.item_fields.each do |item_field|
     if !item_field.notes.present?
       @item.notes.build(:item_field_id => item_field.id)
     end
   end
  end

  def update

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
  end

  def destroy
    @item.destroy

    respond_to do |format|
      format.html { redirect_to catalogs_url }
    end
  end

  private
    def load_item
      @item = Item.find(params[:id])
    end
end
