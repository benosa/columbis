# -*- encoding : utf-8 -*-
module Boss
  class DateIntervalReport < Report

    attribute :intervals # [1, 7, 31]

    def initialize(attributes = nil, options = {})
      super

      # Default intervals
      self.intervals = [1, 7, 31] unless intervals

      self.end_date = Date.current unless end_date
      # Set start_date properly, because report must have data from previous periods
      min_start_date = end_date - (2 * intervals.max + 1).days
      self.start_date = min_start_date if !start_date or start_date > min_start_date
    end

    def interval_field(column, value, range)
      expr = ''
      expr += "WHEN '#{range.first}' < #{column} AND #{column} <= '#{range.last}'"
      expr += " THEN #{value} "
      "(CASE #{expr} END)"
    end

    def ranges_field(column, ranges)
      expr = ''
      ranges.each_with_index do |range, index|
        expr += "WHEN '#{range.first}' < #{column} AND #{column} <= '#{range.last}'"
        expr += " THEN #{index} "
      end
      expr.blank? ? column : "(CASE #{expr} END)"
    end

    def all_intervals_field(column, prev_interval = false)
      expr = ''
      ranges_from_end_date(prev_interval) do |value, range|
        expr += "WHEN '#{range.first}' < #{column} AND #{column} <= '#{range.last}'"
        expr += " THEN #{value} "
      end
      expr.blank? ? column : "(CASE #{expr} END)"
    end

    def ranges_from_end_date(prev_interval = false)
      ranges = {}
      current_date = end_date
      intervals.each_with_index do |value, i|
        unless prev_interval
          prev_date = current_date - value.days
        else
          current_date = end_date - value.days
          prev_date = current_date - value.days
        end
        range = [prev_date, current_date]

        yield value, range if block_given?

        ranges[value] = range
      end
      ranges
    end

    def ranges_by_step_from_end_date(value = false, count = 10)
      value ||= intervals
      ranges = []
      current_date = end_date
      count.times do |i|
        prev_date = current_date - value.days
        range = [prev_date, current_date]

        yield value, range if block_given?

        ranges << range
        current_date = prev_date
      end
      ranges
    end

  end
end