# -*- encoding : utf-8 -*-
module Boss
  class Report
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend  ActiveModel::Naming

    attr_accessor :company, :user, :name,
                  :start_date, :end_date, #, :period
                  :row_count, :sort_col, :sort_dir #, :currency
    attr_reader   :results

    delegate :[], :each, :to => :results

    validates_presence_of :company, :start_date, :end_date

    # Instance methods

    def initialize(attributes = {})
      attributes.each do |name, value|
        a = "#{name}="
        send(a, value) if respond_to?(a)
      end
      @start_date ||= Date.current.beginning_of_month
      @end_date ||= Date.current.end_of_month
      @row_count ||= 10
      @sort_col ||= :amount
      @sort_dir ||= :desc
      # @currency ||= ::CurrenceCourse::PRIMARY_CURRENCY
      @results = {}
    end

    def persisted?
      false
    end

    # Must be overrided to get actual results
    def prepare
      self
    end

    def order_expr(column)
      "(CASE WHEN #{column} IS NULL THEN 0 ELSE #{column} END) DESC"
    end

    def build_result(options = {})
      ReportResult.new(self, options)
    end

    # Class methods

    class << self

      def arel_tables(*tables)
        tables.each do |method|
          self.class_eval <<-EOS, __FILE__, __LINE__
            def #{method}
              @#{method} ||= Arel::Table.new(:#{method})
            end
          EOS
        end
      end

      def available_results(*results)
        @available_results ||= []
        undefined = results - @available_results

        undefined.each do |method|
          self.class_eval <<-EOS, __FILE__, __LINE__
            def #{method}
              @results[:#{method}]
            end
          EOS
        end

        @available_results += undefined
      end

    end

  end
end