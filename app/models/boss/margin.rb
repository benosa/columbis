module Boss
  module Margin
    extend ActiveSupport::Concern

    MARGIN_TYPES = ['profit', 'profit_acc']

    included do
      available_results :percent
      available_results :data
      attribute :margin_type, :default => 'profit_acc'
      attr_accessible :margin_type
    end

    def prepare(options = {})
      @query_type = margin_type
      super
      case margin_type
        when 'profit'
          @query_type = 'profit_in_percent'
        else
          @query_type = 'profit_in_percent_acc'
      end
      case period
        when 'day'
          @results[:percent]  = build_result(query: days_query)
        when 'week'
          @results[:percent]  = build_result(query: weeks_query)
        when 'year'
          @results[:percent]  = build_result(query: years_query)
        else
          @results[:percent]  = build_result(query: months_query)
      end
      @results[:data] = @results[:amount].data.map!{|e| e.merge("percent" => false)} +
        @results[:percent].data.map!{|e| e.merge("percent" => true)}
      self
    end

    protected

      def query
        query = claims
          .where(claims[:company_id].eq(company.id))
          .where(claims[:reservation_date].gteq(@start_date))
          .where(claims[:reservation_date].lteq(@end_date))
          .where(claims[:canceled].eq(false))
          .where(claims[:excluded_from_profit].eq(false))
        case @query_type
        when 'profit'
          query.project(claims[:profit].sum.as('amount'), claims[:profit_in_percent].average.as('percent'))
        when 'profit_in_percent'
          query.project(claims[:profit_in_percent].average.as('amount'))
        when 'profit_in_percent_acc'
          query.project(claims[:profit_in_percent_acc].average.as('amount'))
        else
          query.project(claims[:profit_acc].sum.as('amount'), claims[:profit_in_percent_acc].average.as('percent'))
        end
      end

      def years_query
        base_query.project("extract(year from reservation_date) AS year")
          .group(:year)
          .order(:year)
      end

      def months_query
        years_query.project("extract(month from reservation_date) AS month")
          .group(:month)
          .order(:month)
      end

      def days_query
        months_query.project("extract(day from reservation_date) AS day")
          .group(:day)
          .order(:day)
      end

      def weeks_query
        years_query.project("extract(week from reservation_date) AS week")
          .group(:week)
          .order(:week)
      end
  end
end
