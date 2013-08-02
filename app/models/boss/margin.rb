module Boss
  module Margin
    extend ActiveSupport::Concern

    MARGIN_TYPES = ['profit', 'profit_acc', 'profit_in_percent', 'profit_in_percent_acc']

    included do

      attribute :margin_type, :default => 'profit_acc'
      attr_accessible :margin_type
    end

    module InstanceMethods
      protected

        def query
          query = claims
            .where(claims[:company_id].eq(company.id))
            .where(claims[:reservation_date].gteq(@start_date))
            .where(claims[:reservation_date].lteq(@end_date))
            .where(claims[:canceled].eq(false))
            .where(claims[:excluded_from_profit].eq(false))
          case margin_type
          when 'profit'
            query.project(claims[:profit].sum.as('amount'))
          when 'profit_in_percent'
            query.project(claims[:profit_in_percent].average.as('amount'))
          when 'profit_in_percent_acc'
            query.project(claims[:profit_in_percent_acc].average.as('amount'))
          else
            query.project(claims[:profit_acc].sum.as('amount'))
          end
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

        def days_settings(categories, series)
          settings = super
          if margin_type == 'profit_in_percent' || margin_type == 'profit_in_percent_acc'
            settings[:yAxis].merge!(:stackLabels => {:enabled => false})
            settings.merge!(:plotOptions => {:column => {:stacking => 'percent'}})
          end
          settings
        end

        def months_settings(categories, series)
          settings = super
          if margin_type == 'profit_in_percent' || margin_type == 'profit_in_percent_acc'
            settings[:yAxis].merge!(:stackLabels => {:enabled => false})
            settings.merge!(:plotOptions => {:column => {:stacking => 'percent'}})
          end
          settings
        end

        def weeks_settings(categories, series)
          settings = super
          if margin_type == 'profit_in_percent' || margin_type == 'profit_in_percent_acc'
            settings[:yAxis].merge!(:stackLabels => {:enabled => false})
            settings.merge!(:plotOptions => {:column => {:stacking => 'percent'}})
          end
          settings
        end

        def years_settings(categories, series)
          settings = super
          if margin_type == 'profit_in_percent' || margin_type == 'profit_in_percent_acc'
            settings[:yAxis].merge!(:stackLabels => {:enabled => false})
            settings.merge!(:plotOptions => {:column => {:stacking => 'percent'}})
          end
          settings
        end
    end
  end
end