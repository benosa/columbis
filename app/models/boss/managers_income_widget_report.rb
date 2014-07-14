# -*- encoding : utf-8 -*-
module Boss
  class ManagersIncomeWidgetReport < ManagersIncomeReport

    protected

      def base_query
        payms = query.project(claims[:user_id].as("user_id"), claims[:reservation_date].as("reservation_date"))
          .group(:user_id, :reservation_date)
          .as("payments")
        users.project(users[:id].as('id'), users[:color].as('color'),
            "(CASE WHEN users.first_name != '' OR users.last_name != '' THEN users.first_name || ' ' || users.last_name ELSE users.login END) AS name",
            payms[:amount].sum.as("amount"), payms[:reservation_date].as("reservation_date"))
          .join(payms, Arel::Nodes::OuterJoin).on(payms[:user_id].eq(users[:id]))
          .where(users[:company_id].eq(company.id))
          .group(:id, :reservation_date)
      end
  end
end