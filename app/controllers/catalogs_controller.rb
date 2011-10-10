class CatalogsController < ApplicationController
  def new
    @catalog = Catalog.new
    3.times {@catalog.item_fields.build}
  end

  def create
    @catalog = Catalog.new(params[:catalog])

    respond_to do |format|
      if @catalog.save
        format.html { redirect_to @catalog, :notice => 'Catalog was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @catalog = Catalog.find(params[:id])
  end

  def update
    @catalog = Catalog.find(params[:id])

    respond_to do |format|
      if @catalog.update_attributes(params[:catalog])
        format.html { redirect_to @catalog, :notice => 'Catalog was successfully updated.' }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def index
    @catalogs = Catalog.find(:all)
  end

  def show
    @catalog = Catalog.find(params[:id])
  end

  def destroy
    @catalog = Catalog.find(params[:id])
    @catalog.destroy

    respond_to do |format|
      format.html { redirect_to catalogs_url }
    end
  end
end
