class TariffPlansController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def show
    redirect_to tariff_plans_path
  end

  def new
  end

  def edit
  end

  def create
    if @tariff_plan.save
      redirect_to tariff_plans_path, notice: t('.tariff_plans.messages.created')
    else
      render action: "new"
    end
  end

  def update
    if @tariff_plan.update_attributes(params[:tariff_plan])
      redirect_to tariff_plans_path, notice: t('.tariff_plans.messages.updated')
    else
      render action: "edit"
    end
  end

  def destroy
    @tariff_plan.destroy

    redirect_to tariff_plans_path, notice: t('.tariff_plans.messages.destroyed')
  end
end