# -*- encoding : utf-8 -*-
module Boss
  class BaseController < ApplicationController
    include BossHelper

    before_filter { raise CanCan::AccessDenied unless is_admin? or is_boss? }

    def index
      @widgets = Widget.where(:company_id => current_company.id)
        .where(:user_id => current_user.id).order("position ASC")
      if @widgets.length == 0
        @widgets = Widget.create_default_widgets(current_user, current_company)
      end

      render 'boss/index'
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
        widget = Widget.find(params["format"])
        widget.update_attributes(params["boss_widget"])
        respond_to do |format|
          format.js { render }
        end
      else
        head :bad_request
        render nothing: true
      end
    end

  end
end