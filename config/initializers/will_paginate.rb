# Set default form builder
ActionView::Base.default_form_builder = TourismFormBuilder

class WillPaginateLinkRenderer < WillPaginate::ActionView::LinkRenderer

  protected

    def page_number(page)
      if @options[:link_id]
        id = "#{@options[:link_id]}_page#{page}"
      else
        prefix = @collection.to_s
        prefix = @collection.klass.to_s if @collection.try(:klass)
        id = "#{prefix.tableize}_page#{page}"
      end
      unless page == current_page
        tag(:li, link(page, page, :rel => rel_value(page), :id => id, 'data-param' => 'page', 'data-value' => page))
      else
        tag(:li, tag(:span, page, :class => 'active'), :id => id, :class => "active")
      end
    end

    def previous_or_next_page(page, text, classname)
      if page
        tag(:li, link(text, page, 'data-param' => 'page', 'data-value' => page), :class => classname)
      else
        tag(:li, tag(:span, text), :class => classname + ' disabled')
      end
    end

    def gap
      text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
      %(<li class="disabled"><a>#{text}</a></li>)
    end

    def html_container(html)
      tag(:ul, html, container_attributes)
    end

end