# -*- encoding : utf-8 -*-
module Boss
  class ManagersIncomeReport < IncomeReport
    include IncomeGroup

    arel_tables :users

    protected

      def base_query
        query.project(users[:id].as('id'), users[:color].as('color'),
        "(CASE WHEN users.first_name != '' OR users.last_name != '' THEN users.first_name || ' ' || users.last_name ELSE users.login END) AS name")
          .join(users).on(claims[:user_id].eq(users[:id]))
          .group(users[:id])
      end

      def total_query
        base_table = base_query.as('base_table')

        ret = payments.project(base_table[:id].as('id'), base_table[:name], base_table[:color], base_table[:amount].sum.as('total'))
          .from(base_table)
          .group(:id, :name, :color)
          .order(:total)

        if total_filter
          ret.where(base_table[:id].in(total_filter))
        end

        ret
      end
  end
end