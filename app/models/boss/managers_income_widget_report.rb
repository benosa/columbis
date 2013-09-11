# -*- encoding : utf-8 -*-
module Boss
  class ManagersIncomeWidgetReport < ManagersIncomeReport

    protected

      def base_query
        payms = query.project(claims[:user_id].as("user_id"), payments[:date_in].as("date_in"))
          .group(:user_id, :date_in)
          .as("payments")
        users.project(users[:id].as('id'), users[:color].as('color'),
            "(CASE WHEN users.first_name != '' OR users.last_name != '' THEN users.first_name || ' ' || users.last_name ELSE users.login END) AS name",
            payms[:amount].sum.as("amount"), payms[:date_in].as("date_in"))
          .join(payms, Arel::Nodes::OuterJoin).on(payms[:user_id].eq(users[:id]))
          .where(users[:company_id].eq(company.id))
          .group(:id, :date_in)
      end
  end
end