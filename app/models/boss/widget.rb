# -*- encoding : utf-8 -*-
module Boss
  class Widget

    attr_accessor :type, :view, :title, :data, :total

    # Instance methods

    def initialize(attributes = {})
      attributes.each do |method, value|
        send(:"#{method}=", value)
      end
      @data = [] unless @data
      @total = {} unless @total
    end

    def [](attribute)
      send(attribute)
    end

    # Class methods

    class << self

      def factor(attributes = {})
        new attributes.merge(type: :factor, view: :small)
      end

      def chart(attributes = {})
        new attributes.merge(type: :chart, view: :medium)
      end

      def small_chart(attributes = {})
        new attributes.merge(type: :chart, view: :small2)
      end

      def large_chart(attributes = {})
        new attributes.merge(type: :chart, view: :large)
      end

      def table(attributes = {})
        new attributes.merge(type: :table, view: :large )
      end

    end

  end
end