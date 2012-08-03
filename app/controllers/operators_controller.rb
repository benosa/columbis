class OperatorsController < ApplicationController
  load_and_authorize_resource

  def index
    @operators = current_company.operators
  end

  def show
  end

  def new
    @operator.build_address
  end

  def create
    @operator.company = current_company
    @operator.address.company = current_company
    if @operator.save
      redirect_to @operator, :notice => "Successfully created operator."
    else
      render :action => 'new'
    end
  end

  def edit
    if !@operator.address.present?
      @operator.build_address
    end
  end

  def update
    @operator.company ||= current_company
    @operator.address.company ||= current_company
    if @operator.update_attributes(params[:operator])
      redirect_to @operator, :notice  => "Successfully updated operator."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @operator.destroy
    redirect_to operators_url, :notice => "Successfully destroyed operator."
  end
end
