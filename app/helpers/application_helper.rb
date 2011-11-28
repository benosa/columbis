module ApplicationHelper
  def sortable(column, title = nil, search = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to({ :sort => column, :direction => direction }, { :class => css_class }) do
      raw(title.to_s + tag('span', :class => 'sort_span ' << css_class.to_s))
    end
  end

  def currency_select(field)

  end
end

class Float
  def to_money
    sprintf("%0.2f", self)
  end
end
