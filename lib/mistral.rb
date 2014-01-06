# Mistral module for special Mistral company functionality
module Mistral

  module ClaimsHelperExtention

    def mistral_tourist_stat_options(user, claim)
      specific_options = %w(Повтор Знакомые Рекомендации Интернет Медиа Соседи Инфотур Сами)
      all_options = DropdownValue.values_for('tourist_stat', user.company.id, false)

      # For manual set of specific options
      special_value_index = all_options.index{ |val| val =~ /\A%{.+}/ }
      if special_value_index
        special_value = all_options.delete_at(special_value_index)
        new_specific_options = special_value[2..-2].split(';')
        specific_options = new_specific_options unless new_specific_options.empty?
      end

      if user.is_admin? or user.is_boss? # Bring specific options to top
        options = specific_options + all_options.select{ |o| !specific_options.include?(o) }
      else
        options = specific_options
      end

      current_value = claim.tourist_stat.to_s
      options << current_value if !specific_options.include?(current_value)
      options
    end

    def mistral_operator_list(user, term)
      specific_operators = Mistral.mistral_specific_operators
      specific_field = "(CASE WHEN btrim(operators.name) in (#{specific_operators.map{|o| ActiveRecord::Base.sanitize(o) }.join(',')}) THEN 0 ELSE 1 END)" unless specific_operators.empty?
      specific_field = '1' if specific_operators.empty?

      list = user.company.operators
        .select("min(operators.id) id, btrim(operators.name) as name, #{specific_field} as spec")
        .where(["operators.name ILIKE '%' || ? || '%'", term])
        .where('operators.name NOT ILIKE \'\%{%}\'')
        .group('btrim(operators.name)')
        .reorder('spec, name')
        # .limit(50)

      if user.is_admin? or user.is_boss?
        # Special operators must be on top
        list = list.all
        i = list.index{ |operator| !specific_operators.include?(operator.name) }
        list.insert(i, Operator.new(id: '', name: '=' * 15)) if i && i > 0
      else
        list = list.where(name: specific_operators) unless specific_operators.empty?
      end

      list
    end
  end

  module ClaimExtention
    extend ActiveSupport::Concern

    included do
      validate :check_specific_operator, :if => proc{ Mistral.is_mistral? company }
    end

    def check_specific_operator
      if current_editor && !(current_editor.is_admin? or current_editor.is_boss?)
        errors.add(:operator, :is_selected_from_existing) if operator && !Mistral.mistral_specific_operators.include?(operator.name)
      end
    end
  end

  module ApplicationHelperExtention

    def is_mistral?
      Mistral.is_mistral? current_company
    end

    def top_managers
      return @top_managers if @top_managers

      days_from_beginning_of_month = (Date.current - Date.current.beginning_of_month).to_i

      report_options = {
        period: 'month',
        company: current_company,
        user: current_user,
        margin_type: "profit",
        check_date: true # use start_date and end_date
      }
      @report = nil

      if days_from_beginning_of_month > 3
        report_options.merge!({
          start_date: Date.current.beginning_of_month,
          end_date: Date.current.end_of_month
        })
        @report = Boss::ManagersMarginReport.new(report_options).prepare
      end

      # If data in current month are empty, get it from previous
      if !@report || @report.data.empty?
        @i = 1
        while !@report || @report.data.empty? do
          report_options.merge!({
            start_date: (Date.current - @i.month).beginning_of_month,
            end_date: (Date.current - @i.month).end_of_month
          })
          @i += 1
          @report = Boss::ManagersMarginReport.new(report_options).prepare
        end
      end

      @mistral_top_managers_report = @report
      @top_managers = @report.data.select{|data| !data['percent']}.sort_by{|data| -data['amount']}[0,3]
    end

    def top_manager(pos = 0, attribute = false)
      manager = top_managers[pos]
      value = manager[attribute] if manager && attribute
      value || manager
    end

    def manager_pos(user)
      id = user.id.to_s if user
      if id == top_manager(0, 'id')
        return 'first'
      elsif id == top_manager(1, 'id')
        return 'second'
      elsif id == top_manager(2, 'id')
        return 'third'
      end
      false
    end

    def top_managers_tooltip_text
      start_date = @mistral_top_managers_report.try(:start_date)
      end_date = @mistral_top_managers_report.try(:end_date)
      I18n.t 'layouts.main_menu.top_managers_tooltip_text', month: I18n.l(start_date, format: '%B') if start_date && end_date
    end

  end

  def self.is_mistral?(company)
    company.id == 8
  end

  # Specific list of permitted operator for managers
  def self.mistral_specific_operators
    operators = Operator.where('name ILIKE \'\%{%}\'').pluck(:name)
    operators = operators.map{ |value| value[2..-2].gsub(/\s*;\s*/, ';').split(';') }.flatten.uniq unless operators.empty?
    operators
  end

end