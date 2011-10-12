class CatalogsController < ApplicationController
  before_filter :load_catalog, :only => [:edit, :update, :show, :destroy]

  def new
    @catalog = Catalog.new
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
  end

  def update

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
  end

  def destroy
    @catalog.destroy

    respond_to do |format|
      format.html { redirect_to catalogs_url }
    end
  end

  private
    def load_catalog
      @catalog = Catalog.find(params[:id])
    end
end
