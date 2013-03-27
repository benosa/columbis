# -*- encoding : utf-8 -*-
module Boss
  class BaseController < ApplicationController
    include BossHelper

    before_filter { redirect_to root unless is_admin? or is_boss? }

    def index
      widget = {
        type: :data,
        width: :small,
        title: 'Путевок продано',
        data: [
          ['Среда', '7 дней', '31 день'],
          ['31', '5,420', '338,786'],
          [{class: 'sign-up'}, '&ndash;'.html_safe, {class: 'sign-down'}],
          ['00.01%', '17.30%', '21.40%']
        ],
        total: {
          title: 'Всего',
          data: '23,460 <span>p.<span/>'.html_safe,
          text: '(не включая продажи по другим <br> каналам)'.html_safe
        }
      }
      @widgets = []
      4.times{ @widgets << widget.dup }

      @tourists_widget = {
        type: :table,
        width: :large,
        title: 'Новые туристы',
        data: Tourist.clients.accessible_by(current_ability).includes(:address).paginate(page: 1, per_page: 10)
      }

      render 'boss/index'
    end

  end
end