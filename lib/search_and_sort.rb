# Extending active record models with thinking sphinx integration for searching and sorting
module SearchAndSort
  def search_and_sort(options = {})
    filter = options.delete(:filter)
    search_results = search_for_ids(filter, options)
    @search_info = {
      :ids => search_results.to_a,
      :total_entries => search_results.total_entries,
      :total_pages => search_results.total_pages
    }
    scoped = where(:id => search_results)
    if !options[:sql_order].nil?
      scoped = options[:sql_order] ? scoped.reorder(options[:sql_order]) : scoped.reorder()
    elsif options[:order].present?
      if options[:order] == :joint_address
        scoped = scoped.joins(Address.left_join(self)).reorder(Address.order_text(:joint_address, options[:sort_mode]))
      else
        scoped = scoped.reorder("#{options[:order]} #{options[:sort_mode]}")
      end
    end
    scoped
  end

  def search_info
    @search_info
  end

  def sort_by_search_results(collection)
    return collection unless @search_info
    collection.sort_by{ |o| @search_info[:ids].index(o.id) }
  end
end