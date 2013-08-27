# -*- encoding : utf-8 -*-
module Boss
  class NormalPriceReport < IncomeReport

    arel_tables :tourist_claims

    private

      def query
        tourists_number = tourist_claims.project(tourist_claims[:claim_id], tourist_claims[:claim_id].count.as('number'))
          .group(:claim_id)
          .as('tourists_number')

        claims.project("AVG(claims.primary_currency_price/tourists_number.number) AS amount")
          .join(tourists_number).on(tourists_number[:claim_id].eq(claims[:id]))
          .where(claims[:company_id].eq(company.id))
          .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
          .where(claims[:canceled].eq(false))
          .where(claims[:excluded_from_profit].eq(false))
          .group(:reservation_date)
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