# -*- encoding : utf-8 -*-
module Boss
  class ClaimIntervalReport < DateIntervalReport

    arel_tables :claims
    available_results :count, :total

    def prepare(options = {})
      # current_res = build_result(query: current_query, typecast: {interval: :to_i, count: :to_f})
      # prev_res = build_result(query: prev_query, typecast: {interval: :to_i, prev_count: :to_f})
      # @results[:count] = build_result.merge(current_res, prev_res, key: 'interval').sort!(col: 'interval', dir: :asc)
      # @results[:count] = build_result(query: count_query, typecast: {interval: :to_i, count: :to_f, prev_count: :to_f}).sort!(col: 'interval', dir: :asc)
      # @results[:count].data.delete_if{ |row| row['interval'] === 0 }.each do |row|
      #   row['percent'] = (row['count'] - row['prev_count']) / row['count'] * 100 unless row['count'] === 0
      #   row['percent'] = 0 if row['count'] === 0
      # end
      current_date_ranges = ranges_from_end_date
      current_res = build_result(query: query(current_date_ranges), typecast: {interval: :to_i, count: :to_f})
      prev_date_ranges = ranges_from_end_date(true)
      prev_res = build_result(query: query(prev_date_ranges, 'prev_count'), typecast: {interval: :to_i, prev_count: :to_f})
      @results[:count] = build_result.merge(current_res, prev_res, key: 'interval').sort!(col: 'interval', dir: :asc)
      @results[:count].each do |row|
        row['percent'] = (row['count'] - row['prev_count']) / row['count'] * 100 unless row['count'] === 0
        row['percent'] = 0 if row['count'] === 0
      end
      total = build_result(query: total_query, typecast: {count: :to_f}).data
      @results[:total] = !total.empty? ? total.first['count'] : 0
      self
    end

    private

      def base_query(options = {})
        start_date = options[:start_date] || self.start_date
        end_date = options[:end_date] || self.end_date
        claims
          .where(claims[:company_id].eq(company.id))
          .where(claims[:canceled].eq(false))
          .where(claims[:reservation_date].gt(start_date))
          .where(claims[:reservation_date].lteq(end_date))
      end

      def query(ranges, factor_alias = 'count')
        full_query = false
        ranges.each do |value, range|
          query = base_query(start_date: range.first, end_date: range.last)
            .project("#{value} AS interval", claims[:id].count.as(factor_alias))
            .group('interval')
          unless full_query
            full_query = query.to_sql
          else
            full_query += " UNION #{query.to_sql}"
          end
        end
        Rails.logger.debug "full_query: #{full_query}"
        full_query
      end

      def count_query
        current_query = base_query
          .project("#{all_intervals_field('claims.reservation_date')} AS interval", claims[:id].count.as('count'))
          .group('interval')
          .as('current_query')

        prev_query = base_query
          .project("#{all_intervals_field('claims.reservation_date', true)} AS interval", claims[:id].count.as('prev_count'))
          .group('interval')
          .as('prev_query')

        manager = Arel::SelectManager.new Arel::Table.engine
        # manager.project(Arel.sql('current_query.interval'), Arel.sql('count'), Arel.sql('prev_count'))
        manager.project('*')
          .from(current_query)
          .join(prev_query).on(prev_query[:interval].eq(current_query[:interval]))
      end

      def current_query
        base_query.project("#{all_intervals_field('claims.reservation_date')} AS interval", claims[:id].count.as('count'))
          .group('interval')
      end

      def prev_query
        base_query.project("#{all_intervals_field('claims.reservation_date')} AS interval", claims[:id].count.as('prev_count'))
          .group('interval')
      end

      def total_query
        claims.project(claims[:id].count.as('count'))
      end

  end
end