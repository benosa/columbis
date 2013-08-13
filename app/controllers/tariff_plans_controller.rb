class TariffPlansController < ApplicationController
  load_and_authorize_resource

  def index
    @tariff_plans = TariffPlan.all
  end

  def show
    redirect_to tariff_plans_path
  end

  def new
  end

  def edit
  end

  def create
    @tariff_plan = TariffPlan.new(params[:tariff_plan])

    if @tariff_plan.save
      redirect_to tariff_plans_path, notice: t('.tariff_plans.messages.created')
    else
      render action: "new"
    end
  end

  def update
    @tariff_plan = TariffPlan.find(params[:id])

    if @tariff_plan.update_attributes(params[:tariff_plan])
      redirect_to tariff_plans_path, notice: t('.tariff_plans.messages.updated')
    else
      render action: "edit"
    end
  end

  def destroy
    @tariff_plan = TariffPlan.find(params[:id])
    @tariff_plan.destroy

    redirect_to tariff_plans_path, notice: t('.tariff_plans.messages.destroyed')
  end
end
