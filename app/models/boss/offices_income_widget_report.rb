# -*- encoding : utf-8 -*-
module Boss
  class OfficesIncomeWidgetReport < OfficesIncomeReport

    protected

      def base_query
        payms = query.project(claims[:office_id].as("office_id"), payments[:date_in].as("date_in"))
          .group(:office_id, :date_in)
          .as("payments")
        offices.project(offices[:id].as('id'), offices[:name].as('name'),
            payms[:amount].sum.as("amount"), payms[:date_in].as("date_in"))
          .join(payms, Arel::Nodes::OuterJoin).on(payms[:office_id].eq(offices[:id]))
          .where(offices[:company_id].eq(company.id))
          .group(:id, :date_in)
      end
  end
end