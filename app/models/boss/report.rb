# -*- encoding : utf-8 -*-
module Boss
  class Report
    include ActiveAttr::Model

    attribute :company
    attribute :user
    attribute :name
    attribute :start_date, type: Date, default: Date.current.beginning_of_month
    attribute :end_date, type: Date, default: Date.current.end_of_month
    attribute :row_count, type: Integer, default: 10
    attribute :show_others, type: Boolean, default: true
    attribute :sort_col, default: :amount
    attribute :sort_dir, default: :desc

    attr_accessible :company, :user, :name, :start_date, :end_date, :row_count, :show_others, :sort_col, :sort_dir

    attr_reader :results

    # delegate :[], :each, :to => :results

    validates_presence_of :company, :start_date, :end_date

    # Instance methods

    def initialize(attributes = nil, options = {})
      @results = {}
      super
    end

    # Must be overrided to get actual results
    def prepare
      self
    end
    alias_method :run, :prepare

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