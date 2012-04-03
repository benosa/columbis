module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to({ :sort => column, :direction => direction, :filter => params[:filter] }, { :class => css_class }) do
      raw(title.to_s + tag('span', :class => 'sort_span ' << css_class.to_s))
    end
  end

  def link_for_view_switcher
    label = params[:list_type] == 'manager_list' ? 'accountant_list' : 'manager_list'
    link_to t('claims.index.' << label), claims_path(:list_type => label), :class =>  'accountant_login', :list_type => params[:list_type]
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to(name, '#', :class => 'remove')
  end

  def li_class(claim, target)
    if target == :contract
      (claim && !claim.new_record? && claim.company.try(:contract_printer)) ? 'enabled' : 'disabled'
    elsif target == :memo
      (claim && !claim.new_record? && claim.company.try(:memo_printer_for, claim.country)) ? 'enabled' : 'disabled'
    end
  end
end

class Float
  def to_money
    sprintf("%0.0f", self)
  end

  def to_percent
    sprintf("%0.2f", self)
  end
end

class String
  def initial
    self.chars.first + '.'
  end
end

module ActionView
  module Helpers
    module TranslationHelper
      def localize(*args)
        #Avoid I18n::ArgumentError for nil values
        I18n.localize(*args) unless args.first.nil?
      end
      # l() still points at old definition
      alias l localize
    end
  end
end
