# -*- encoding : utf-8 -*-
module Boss
  class OfficesIncomeWidgetReport < OfficesIncomeReport

    protected

      def base_query
        payms = query.project(claims[:office_id].as("office_id"), claims[:reservation_date].as("reservation_date"))
          .group(:office_id, :reservation_date)
          .as("pyments")

        offices.project(offices[:id].as('id'), offices[:name].as('name'),
            payms[:amount].sum.as("amount"), payms[:reservation_date].as("reservation_date"))
          .join(payms, Arel::Nodes::OuterJoin).on(payms[:office_id].eq(offices[:id]))
          .where(offices[:company_id].eq(company.id))
          .group(:id, :reservation_date)
      end
  end
end