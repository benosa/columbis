# -*- encoding : utf-8 -*-
class DashboardController < ApplicationController
  TABLES = %w[claims tourists payments operators addresses companies cities offices].freeze

  before_filter :only => [:offline, :local_tables, :local_data] do
    authorize! :offline_version, current_user
  end

  def index
    authorize! :dasboard_index, current_user
  end

  def offline
    render :file => Rails.root.join("public/offline.html.erb"), :layout => 'application', :locals => { :assets => !(request.url =~ /\.html$/) }
  end

  def local_tables
    data = Hash[*local_table_list.map{ |table| [table, table_columns(table)] }.flatten(1)]
    render :json => data
  end

  def local_data
    updated_at = Time.parse(params[:updated_at]) if params[:updated_at] and params[:updated_at] != 'null'
    data = get_local_data(updated_at)
    render :json => data
  end

  def create_manifest
    require 'lib/tourism_manifest'
    TourismManifest.write_manifest_file(view_context)
    render :text => 'OK' if request.present?
  end

  private

    def table_columns(table)
      model = table.classify.constantize
      #model.columns.sort!{ |x,y| x.name <=> y.name }.map{ |c| c.name + ' ' + to_js_type(c) }
      columns = model.columns
      model.local_data.map do |name|
        column = columns.find { |c| c.name == name.to_s }
        if column
          "#{name} #{to_js_type(column)}"
        else
          "#{name} #{to_js_type(name)}"
        end
      end.sort!
    end

    def to_js_type(column)
      case column.try(:type)
      when :integer
        'INTEGER' + (' PRIMARY KEY' if column.primary).to_s
      when :boolean
        'INTEGER' # Converts to 0 or 1
      when :float
        'REAL'
      when :text
        'TEXT'
      else
        # 'VARCHAR(255)'
        'TEXT'
      end
    end

    def accessible_local_tables
      return @accessible_local_tables if @accessible_local_tables.present?
      @accessible_local_tables = TABLES.select{ |table| can? :read, table.classify.constantize }
    end

    def local_table_list
      if (params[:tables])
        params[:tables].to_a.select{ |t| accessible_local_tables.include? t }
      else
        accessible_local_tables
      end
    end

    def get_local_data(updated_at = nil)
      data = {
        :tables => [],
        :data => {}
      }

      local_table_list.each do |table|
        data[:tables] << table
        scoped = local_data_scoped(table, updated_at)
        data[:data][table] = scoped.all.map(&:local_data)
      end

      if (updated_at.nil? or current_user.updated_at > updated_at) and params[:tables].nil?
        data[:settings] = current_user_local_settings
      end

      data
    end

    def local_data_scoped(table, updated_at = nil)
      model = table.classify.constantize
      scoped = model.local_data_scoped
      scoped = model.scoped_by_ability(current_ability) if scoped.nil?

      if updated_at.present?
        if model.attribute_names.include?('updated_at')
          scoped = scoped.where('updated_at > ?', updated_at)
        else
          scoped = scoped.where('1 = 0')
        end
      end
      scoped
    end

    def current_user_local_settings
      {
        :login => current_user.login,
        :first_name => current_user.first_name,
        :last_name => current_user.last_name,
        :middle_name => current_user.middle_name,
        :full_name => current_user.full_name,
        :email => current_user.email,
        :role => current_user.role,
        :color => current_user.color,
        :color_name => User.available_colors.select {|pair| pair[1] == current_user.color }.fetch(0,[])[0],
        :office_id => current_user.office_id,
        :office => current_user.office.name
      }
    end
end
