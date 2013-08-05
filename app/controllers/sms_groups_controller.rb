class SmsGroupsController < ApplicationController
  
  load_and_authorize_resource
  
  before_filter :sms_groups
  before_filter :sms_group_new, :only => [:index, :birthday, :show, :create]
  
  respond_to :html
  
  def index
    @clients =
      if search_or_sort?
        options = search_and_sort_options(
                                          with:      current_ability.attributes_for(:read, Tourist),
                                          condition: {company_id: current_company.id},
                                          without:   {phone_number_crc32: 0})
        if options[:order] == :full_name
          options[:sql_order] = %w[last_name first_name middle_name].map{|f| "#{f} #{options[:sort_mode]}"}.join(',')
        end
        scoped = Tourist.search_and_sort(options)
        scoped = search_paginate(scoped, options)
      else
        scoped = Tourist.where('company_id = ? and length(phone_number) > 0', current_company.id).paginate(:page => params[:page], :per_page => per_page)
      end
    
    render :partial => 'list' if request.xhr?
  end
  
  def show
    @sms_group = SmsGroup.find(params[:id])
    @clients = @sms_group.tourists.where('company_id = ?', current_company.id).paginate(:page => params[:page], :per_page => per_page)
    render :partial => 'list' if request.xhr?
  end

  def create
    @sms_group = SmsGroup.new(params[:sms_group])

    respond_to do |format|
      @sms_group[:company_id] = current_company.id
      if @sms_group.save
        format.html { redirect_to sms_groups_path, notice: 'added sms group' }
      else
        format.html { redirect_to sms_groups_path, alert: 'cant add sms group' }
      end
    end
  end
  
  def birthday
    @clients = Tourist.where('company_id = ? AND date_part(\'day\', date_of_birth) = date_part(\'day\', CURRENT_DATE) AND date_part(\'month\', date_of_birth) = date_part(\'month\', CURRENT_DATE)', current_company.id).paginate(:page => params[:page], :per_page => per_page)
    render :partial => 'list' if request.xhr?
  end
  
  def batch_add_to_group
    tourists = Tourist.find_all_by_id(params[:client_ids])
    if params[:new_group_name].empty?
      group = params[:selected_group_name]
    else
      group = SmsGroup.new(name: params[:new_group_name], company_id: current_company.id)
      group.save
      group = group.id
    end
    tourists.map do |e|
      sms_touristgroup = SmsTouristgroup.new(tourist_id: e.id, sms_group_id: group)
      sms_touristgroup.save
    end
    redirect_to sms_groups_path
  end
  
  def destroy
    @sms_group = SmsGroup.find(params[:id])
    @sms_group.destroy
    
    redirect_to sms_groups_path
  end
  
private

  def sms_group_new
    @sms_group_new = SmsGroup.new
  end
  
  def sms_groups
    @sms_groups = SmsGroup.where('company_id = ?', current_company.id)
  end
end
