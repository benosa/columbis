# -*- encoding : utf-8 -*-
class Dashboard::DropdownValuesController < ApplicationController
  load_and_authorize_resource

  def index
    @dropdown_values =
      if search_or_sort?
        options =
          if is_admin?
            {
              :sphinx_select => "*, IF(company_id = #{current_user.company_id} OR common = 1, 1, 0) AS with_common",
              :with => { :with_common => 1 }
            }
          else
            {
              :with_current_abilities => true,
              :with => { :company_id => current_user.company_id }
            }
          end
        options[:conditions] = { :list => params[:list] } if params[:list].present?
        options[:sort_mode] = sort_dir == :asc ? :desc : :asc if sort_col == :common
        search_and_sort(DropdownValue, options)
      else
        scoped =
          if is_admin?
            DropdownValue.where("company_id = ? OR common = ?", current_user.company_id, true)
          else
            DropdownValue.where(:company_id => current_user.company_id).accessible_by(current_ability)
          end
        scoped.order([:list, :id]).paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def new
  end

  def create
    @dropdown_value.company_id = current_company.id
    if @dropdown_value.save
      redirect_to dashboard_dropdown_values_url, :notice => t('dropdown_values.messages.successfully_created_dropdown_value')
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    @dropdown_value.company_id ||= current_company.id unless @dropdown_value.common?
    if @dropdown_value.update_attributes(params[:dropdown_value])
      redirect_to dashboard_dropdown_values_url, :notice  => t('dropdown_values.messages.successfully_updated_dropdown_value')
    else
      render :action => 'edit'
    end
  end

  def destroy
    @dropdown_value.destroy
    redirect_to dashboard_dropdown_values_url, :notice => t('dropdown_values.messages.successfully_destroyed_dropdown_value')
  end
end
