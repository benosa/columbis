# -*- encoding : utf-8 -*-
module ClaimsHelper
  include Mistral::ClaimsHelperExtention # special for Mistral
  # def sort_column
  #   params[:sort] ? params[:sort] : Claim::DEFAULT_SORT[:col]
  # end

  # def sort_direction
  #   %w[asc desc].include?(params[:direction]) ? params[:direction] : Claim::DEFAULT_SORT[:dir]
  # end

  # def sortable(column, title = nil)
  #   title ||= column.titleize
  #   css_class = column == sort_column ? "sort_active #{sort_direction}" : nil
  #   direction = column == sort_column ? sort_direction : "asc"
  #   link_to({ :sort => column, :direction => direction }, { :class => css_class }) do
  #     raw(title.to_s) # + tag('span', :class => 'sort_span ' << css_class.to_s))
  #   end
  # end

  # def claims_params(refresh = false)
  #   return @claims_params if @claims_params.present? and !refresh
  #   @claims_params = {
  #     :sort => sort_column,
  #     :direction => sort_direction
  #   }
  #   [:filter, :office_id, :user_id, :list_type, :page].each { |param| @claims_params[param] = params[param] }
  #   @claims_params
  # end

  def truncate(text, options = {})
    options.reverse_merge!(:omission => '')
    super
  end

  def operator_price(claim)
    claim.operator_price.to_money + CurrencyCourse.currency_symbol(claim.operator_price_currency)
  end

  def operator_advance(claim)
    claim.operator_advance.to_money + CurrencyCourse.currency_symbol(claim.operator_price_currency)
  end

  def operator_debt(claim)
    claim.operator_debt.to_money + CurrencyCourse.currency_symbol(claim.operator_price_currency)
  end

  def approved_advance(claim, who)
    case who
    when :tourist
      claim.approved_tourist_advance.to_money + CurrencyCourse.currency_symbol(CurrencyCourse::PRIMARY_CURRENCY)
    when :operator
      claim.approved_operator_advance.to_money
    when :operator_prim
      claim.approved_operator_advance_prim.to_money + CurrencyCourse.currency_symbol(claim.operator_price_currency)
    end
  end

  def as_money(amount, currency = nil)
    amount.to_money + CurrencyCourse.currency_symbol(currency || CurrencyCourse::PRIMARY_CURRENCY)
  end

  def tourists_list(claim)
    ([claim.applicant.try(:full_name)] + claim.dependents.map{ |o| o.try(:full_name) }).join(', ')
  end

  def text_for_visa(claim, short = nil)
    statuses_key = 'visa_statuses'
    statuses_key += '_short' if short
    if claim.visa_confirmation_flag
      t("claims.#{statuses_key}.#{claim.visa}")
    else
      t("claims.#{statuses_key}.unrequired")
    end
  end

  def check_date_status(claim)
    return '' if claim.canceled?
    return 'hot' unless claim.check_date

    if claim.closed?
      'departed'
    elsif claim.check_date.to_date <= Date.current
      'hot'
    else
      'soon'
    end
  end

  def color_for_tourist_advance(claim)
    return '' if claim.canceled?

    color = 'blue_back'
    color = 'red_back' if claim.has_tourist_debt?
    color
  end

  def color_for_operator_price(claim)
    return '' if claim.canceled?

    color = 'blue_back'
    if claim.operator_price == 0
      color = 'red_back'
    elsif claim.has_operator_debt?
      color = 'green_back' if claim.early_reservation?
      color = (claim.operator_advance > 0 ? 'orange_back' : 'red_back') unless claim.early_reservation?
    end
    color
  end

  # def color_for_operator_advance(claim)
  #   'red_back' if !claim.canceled? and claim.operator_advance > 0
  # end

  def color_for_operator_debt(claim)
    'red_back' if !claim.canceled? && claim.operator_debt > 0
  end

  def color_for_visa(claim)
    return '' if claim.canceled?

    # return 'nothing_done' if claim.new_record?
    !claim.visa_confirmation_flag ? 'all_done' : claim.visa
  end

  def color_for_visa_check(claim)
    return '' if claim.canceled?

    if claim.visa_confirmation_flag?
      (%w[docs_sent visa_approved all_done].include?(claim.visa)) ? 'green_back' : 'red_back'
    end
  end

  def visa_select_options(value)
    options = options_for_select([ [t("claims.visa_statuses.unrequired"), 'unrequired'] ], value)
    status_options = Claim::VISA_STATUSES.map {|s| [ t("claims.visa_statuses.#{s}"), s ] }
    options += grouped_options_for_select({ t("claims.visa_statuses.required_group_label") => status_options }, value)
  end

  def color_for_flight(claim)
    return '' unless claim.arrival_date
    return '' if claim.canceled?

    if claim.arrival_date > Date.current + 8.day
     'soon'
    elsif claim.arrival_date >= Date.current
      'hot'
    else
      'departed'
    end
  end

  def text_value(value)
    return I18n.t(:nope) if value.nil? or value.is_a?(String) and value.blank?
    value.to_s
  end

  def total_years
    query = <<-QUERY
      SELECT EXTRACT(YEAR FROM reservation_date) as year
      FROM claims
      GROUP BY EXTRACT(YEAR FROM reservation_date)
      ORDER BY year DESC
      QUERY
    years = ActiveRecord::Base.connection.select_values(query)
  end

  def show_office
    (is_admin? or is_boss? or is_accountant? or is_supervisor?) and current_company.offices.count > 1
  end

  def show_accountant_columns
    (is_admin? or is_boss? or is_accountant?) and params[:list_type] == 'accountant_list'
  end

  def show_bonus_columns
    is_admin? or is_boss?
  end

  def profit_tooltip(claim)
    pcs = CurrencyCourse.currency_symbol(CurrencyCourse::PRIMARY_CURRENCY)
    ocs = CurrencyCourse.currency_symbol(claim.operator_price_currency)
    tooltip = claim.profit.to_money + pcs
    tooltip += ' = ' + claim.primary_currency_price.to_money + pcs
    tooltip += ' - ' + claim.primary_currency_operator_price.to_money + pcs
    if claim.operator_price_currency != CurrencyCourse::PRIMARY_CURRENCY
      tooltip += ' (' + claim.operator_price.to_f.to_money + ocs + '*' + claim["course_#{claim.operator_price_currency}"].to_s + ')'
    end
    tooltip
  end

  def profit_in_percent_tooltip(claim)
    pcs = CurrencyCourse.currency_symbol(CurrencyCourse::PRIMARY_CURRENCY)
    tooltip = claim.profit_in_percent.to_percent + '%'
    tooltip += ' = ' + claim.profit.to_money + pcs
    tooltip += ' / ' + claim.primary_currency_price.to_money + pcs
    tooltip += ' * 100%'
  end

  def profit_tooltip_acc(claim)
    tooltip = ''
    if claim.profit_acc > 0
      pcs = CurrencyCourse.currency_symbol(CurrencyCourse::PRIMARY_CURRENCY)
      tooltip = claim.profit_acc.to_money + pcs
      tooltip += ' = ' + claim.primary_currency_price.to_money + pcs
      tooltip += ' - ' + claim.approved_operator_advance.to_money + pcs
    end
    tooltip
  end

  def profit_in_percent_tooltip_acc(claim)
    tooltip = ''
    if claim.profit_acc > 0
      pcs = CurrencyCourse.currency_symbol(CurrencyCourse::PRIMARY_CURRENCY)
      tooltip = claim.profit_in_percent_acc.to_percent + '%'
      tooltip += ' = ' + claim.profit_acc.to_money + pcs
      tooltip += ' / ' + claim.primary_currency_price.to_money + pcs
      tooltip += ' * 100%'
    end
  end

  def tourist_stat_options(claim)
    options = nil
    if is_mistral? # Temporary solution for Mistral
      options = mistral_tourist_stat_options(current_user, claim)
    end
    options || current_company.dropdown_values_for('tourist_stat')
  end

  def claim_title(claim)
    title = t('.title', :num => claim.num, :created_at => l(claim.created_at, :format => :long))
    if claim.locked?
      title += ' ' + I18n.t('claims.messages.locked_by', user: claim.editor.try(:name_for_list))
    elsif claim.edited?
      title += ' ' + I18n.t('claims.messages.locked')
    end
    title
  end

  def claim_form_data(claim)
    data = {
      data: {
        lockpath: lock_claims_path,
        unlockpath: unlock_claims_path,
        warning: I18n.t('claims.messages.warning_of_editing')
      }
    }
    data[:data][:locked] = claim.locked_by if claim.locked?
    data
  end

  def claims_cache_key(claims)
    claims.map(&:cache_key).hash
  end

  def currency_courses_for_select
    CurrencyCourse::CURRENCIES.map { |o| [ t(o.upcase), o ] }
  end

  def documents_statuses_for_select
    Claim::DOCUMENTS_STATUSES.map { |o| [ t('claims.documents_statuses.' << o), o ] }
  end

  def excel_date(date)
    if date && date.year > 1900 && date.year < 2100
      "<Data ss:Type=\"DateTime\">#{date.to_s + "T00:00:00.000"}</Data>".html_safe
    else
      ""
    end
  end

  def excel_styles(users)
    styles = {
      :companies => {
        :gray_back => 'companies-gray_back',
        :departed => 'companies-departed',
        :hot => 'companies-hot',
        :soon => 'companies-soon',
        :nothing_done => 'companies-nothing_done',
        :all_done => 'companies-all_done',
        :docs_got => 'companies-docs_got',
        :docs_sent => 'companies-docs_sent',
        :visa_approved => 'companies-visa_approved',
        :red_back => 'companies-red_back',
        :blue_back => 'companies-blue_back',
        :green_back => 'companies-green_back',
        :orange_back => 'companies-orange_back',
        :dates => {
          :gray_back => 'companies-dates-gray_back',
          :departed => 'companies-dates-departed',
          :hot => 'companies-dates-hot',
          :soon => 'companies-dates-soon',
          :nothing_done => 'companies-dates-nothing_done',
          :all_done => 'companies-dates-all_done',
          :docs_got => 'companies-dates-docs_got',
          :docs_sent => 'companies-dates-docs_sent',
          :visa_approved => 'companies-dates-visa_approved',
          :red_back => 'companies-dates-red_back',
          :blue_back => 'companies-dates-blue_back',
          :green_back => 'companies-dates-green_back',
          :orange_back => 'companies-dates-orange_back'
        }
      },
      :users => {}
    }
    users.each do |user|
      if user.try(:color)
        styles[:users].merge!({ user.id.to_s.to_sym => "users-#{user.id.to_s}" })
      end
    end
    styles
  end

  def excel_element(element, style_id, styles, check = true)
    path = style_id.to_s.split('-')
    style = styles
    path.each do |i|
      style = style[i.to_sym]
      unless style
        break
      end
    end
    if check && style && style.kind_of?(String)
      "<#{element} ss:StyleID=\"#{style}\">".html_safe
    else
      "<#{element}>".html_safe
    end
  end
end