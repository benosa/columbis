# -*- encoding : utf-8 -*-
module Boss
  class OfficesIncomeReport < ManagersIncomeReport
    arel_tables :offices

    protected

      def base_query
        query.project(offices[:id].as('id'), offices[:name].as('name'))
          .join(offices).on(claims[:office_id].eq(offices[:id]))
          .group(offices[:id])
      end

      def total_query
        base_table = base_query.as('base_table')

        ret = payments.project(base_table[:id].as('id'), base_table[:name], base_table[:amount].sum.as('total'))
          .from(base_table)
          .group(:id, :name)
          .order(:total)

        if total_filter
          ret.where(base_table[:id].in(total_filter))
        end

        ret
      end

      def get_total_names(data)
        data.map { |d| { :id => d['id'], :name => d['name'] } }.uniq
      end
  end
end