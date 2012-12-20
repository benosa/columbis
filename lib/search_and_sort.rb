# Extending active record models with thinking sphinx integration for searching and sorting
module SearchAndSort
  def search_and_sort(options = {})
    filter = options.delete(:filter)
    @search_results = search_for_ids(filter, options).to_a
    @search_info = {
      :total_entries => @search_results.total_entries,
      :total_pages => @search_results.total_pages
    }
    scoped = where(:id => @search_results)
    if options[:order].present?
      if options[:order] == :joint_address
        scoped = scoped.joins(Address.left_join(self)).reorder(Address.order_text(:joint_address, options[:sort_mode]))
      elsif options[:sql_order]
        scoped = scoped.reorder(options[:sql_order])
      else
        scoped = scoped.reorder("#{options[:order]} #{options[:sort_mode]}")
      end
    end
    scoped
  end

  def search_info
    @search_info
  end

  def search_results
    @search_results
  end

  def sort_by_search_results(collection)
    return collection unless @search_results
    collection.sort_by{ |o| @search_results.index(o.id) }
  end
end