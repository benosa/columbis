# -*- encoding : utf-8 -*-
module Boss
  class BaseController < ApplicationController
    include BossHelper

    before_filter { raise CanCan::AccessDenied unless is_admin? or is_boss? }
    before_filter :set_widget_date

    def index
      @widgets = Widget.where(:company_id => current_company.id)
        .where(:user_id => current_user.id).order("position ASC")
      if @widgets.length == 0
        @widgets = Widget.create_default_widgets(current_user, current_company)
      end

      if request.xhr?
        render partial: 'boss/index'
      else
        render 'boss/index'
      end
    end

    def sort_widget
      if request.xhr?
        positions = {}
        params["data"].split(/,/).each_with_index { |id, i| positions.merge!({id.to_i => {"position" => (i+1)}}) }
        Widget.update(positions.keys, positions.values)
      else
        head :bad_request
      end
      render nothing: true
    end

    def save_widget_settings
      if request.xhr?
        @widget = Widget.find(params["format"])
        @widget.update_attributes params["boss_widget"]
        render 'boss/save_widget_settings'
      else
        render nothing: true
      end
    end

    private

    def set_widget_date
      unless params["widget_date"].nil?
        session.merge!({"widget_date" => params["widget_date"]})
      else
        unless request.xhr?
          session.delete("widget_date")
        end
      end

      if session["widget_date"].nil?
        @date = Time.zone.now.to_date
      else
        @date = session["widget_date"].to_date
      end
    end

  end
end