# -*- encoding : utf-8 -*-
module Boss
  class OfficesMarginReport < OfficesIncomeReport
    protected

      def query
        claims.project(claims[:profit].sum.as('amount'))
          .where(claims[:company_id].eq(company.id))
          .where(claims[:reservation_date].gteq(@start_date))
          .where(claims[:reservation_date].lteq(@end_date))
          .where(claims[:canceled].eq(false))
          .where(claims[:excluded_from_profit].eq(false))
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