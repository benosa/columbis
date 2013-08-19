# -*- encoding : utf-8 -*-
module Boss
  class BaseController < ApplicationController
    include BossHelper

    before_filter { raise CanCan::AccessDenied unless is_admin? or is_boss? }

    def index
      @widgets = Widget.where(:company_id => current_company.id)
        .where(:user_id => current_user.id)
      if @widgets.length == 0
        @widgets = Widget.create_default_widgets(current_user, current_company)
      end

      render 'boss/index'
    end

  end
end