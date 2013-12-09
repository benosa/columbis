# -*- encoding : utf-8 -*-
# Extending active record models with thinking sphinx integration for searching and sorting
module SearchAndSort

  def search_for_ids_with_options(options)
    filter = options.delete(:filter)
    search_results = search_for_ids(filter, options)
    @search_info = {
      :ids => search_results.to_a,
      :total_entries => search_results.total_entries,
      :total_pages => search_results.total_pages
    }
    search_results
  end

  def search_and_sort(options = {})
    search_results = search_for_ids_with_options(options)
    scoped = where(:id => search_results)
    if !options[:sql_order].nil?
      scoped = options[:sql_order] ? scoped.reorder(options[:sql_order]) : scoped.reorder()
    elsif options[:order].present?
      if options[:order] == :joint_address
        scoped = scoped.joins(Address.left_join(self)).reorder(Address.order_text(:joint_address, options[:sort_mode]))
      elsif options[:sort_mode] == :extended
        scoped = scoped.reorder options[:order]
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

  def in_search?(id)
    @search_info[:ids].include? id if @search_info
  end

  def date_indexes(*fields)
    return unless block_given?
    formats = %w[DD.MM.YY DD.MM.YYYY]
    fields.each do |field|
      formats.each_with_index do |format, i|
        yield "to_char(#{table_name}.#{field}, '#{format}')", :"#{field}_index#{i}"
      end
    end
  end

end
