# Custom delayed jobs for export
require 'render_anywhere'
require 'fileutils'

RenderAnywhere::RenderingController.send :helper, ClaimsHelper

module ExportJobs

  def self.export_file(company_id)
    Delayed::Job.enqueue ExportFile.new(company_id)
  end

  class ExportFile < Struct.new(:company_id)
    include RenderAnywhere
    include FileUtils

    def perform
      company = Company.find(company_id)

      inluded_tables = [:user, :office, :operator, :country, :city, :applicant, :dependents, :assistant]
      @totals = Claim.where(:company_id => company_id).includes(inluded_tables).order('claims.reservation_date desc')

      @tourists = Tourist.where(:company_id => company_id).includes([:address, :user])

      @clients = Tourist.where(:company_id => company_id).includes(:address).potentials.order('tourists.created_at DESC')

      @managers = User.where(:company_id => company_id)

      @operators = Operator.by_company_or_common(company).includes(:address).order(:name)

      @tourists_payments = Payment.where(:company_id => company_id, :payer_type => 'Tourist').order('date_in desc')

      @operator_payments = Payment.where(:company_id => company_id, :recipient_type => 'Operator').order('date_in desc')

      html = render :template => 'dashboard/data_transfer/claims', :formats => [:xls],
        :locals => {:@totals => @totals, :@managers => @managers, :@tourists => @tourists, :@clients => @clients,
          :@operators => @operators, :@tourists_payments => @tourists_payments, :@operator_payments => @operator_payments }

      path = Rails.root.join "uploads/#{company_id}"

    # Rails.logger.debug "qwert33: #{path}"
      FileUtils.mkdir_p path if !File.directory?(path)

      IO.write("#{path}/export.xls", html)
    end
  end

  def self.excel_date(date)
    if date && date.year > 1900 && date.year < 2100
      "<Data ss:Type=\"DateTime\">#{date.to_s + "T00:00:00.000"}</Data>".html_safe
    else
      ""
    end
  end

  def self.excel_styles(users)
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

  def self.excel_element(element, style_id, styles, check = true)
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