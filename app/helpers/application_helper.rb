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
end

class Float
  def to_money
    sprintf("%0.0f", self)
  end
end
