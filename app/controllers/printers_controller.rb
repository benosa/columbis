class PrintersController < ApplicationController
  load_and_authorize_resource

  def index
    @printers =
      if search_or_sort?
        options = search_and_sort_options(:with => current_ability.attributes_for(:read, Printer))
        set_filter_to(options)
        search_paginate(Printer.search_and_sort(options).with_template_name, options)
      else
        Printer.accessible_by(current_ability).with_template_name.paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def new
    @printer = Printer.new
    @printer.country = Country.new
  end

  def create
    @printer.company = current_company
    if @printer.assign_reflections_and_save(params[:printer])
      redirect_to printers_path, :notice => t('printers.messages.successfully_created_printer')
    else
      @printer.country = Country.new
      render :action => :new
    end
  end

  def edit
    @printer = Printer.where(:id => params[:id]).first

    if !@printer.template?
      file, filename = template_file(@printer)
      @printer.template = File.open(file)
      @printer.save
    end
    set_charset(@printer) if @printer.template?
    @doc_body = get_doc_part(@printer, 'body') if @printer.template?
    @doc_style = get_doc_part(@printer, 'style') if @printer.template? && is_admin?
  end

  def update
    if @printer.update_attributes(params[:printer])
      set_doc_part(@printer, 'body', params[:doc_body]) if @printer.template?
      set_doc_part(@printer, 'style', params[:doc_style]) if @printer.template? && is_admin?
      redirect_to printers_path, :notice => t('printers.messages.successfully_updated_printer')
    else
      render :action => :edit
    end
  end

  def destroy
    @printer = Printer.destroy(params[:id])
    if request.xhr?
      index
    else
      redirect_to printers_path, :notice => t('printers.messages.successfully_deleted_printer')
    end
  end

  def download
    printer = current_company.printers.find(params[:template]) if params[:template]
    file, filename = template_file(printer) if printer

    if file
      send_file file, filename: filename, x_sendfile: true
    else
      redirect_to printers_path
    end
  end

  def print_vars
    @vars = YAML.load_file("#{Rails.root}/app/assets/print_vars.yml")
    @table = []
    @vars.each do |key, value|
      @table << [key.to_s, '', value['.'].to_s.html_safe]
      value.each do |key2, value2|
        @table << ['', key2.mb_chars.upcase.to_s, value2.to_s.html_safe]
      end
    end
  end

  private

    def get_doc_part(printer, part)
      page = Nokogiri::HTML(open(printer.template.path))
      if page.at_css(part)
        page.at_css(part).inner_html
      else
        nil
      end
    end

    def set_charset(printer)
      page = Nokogiri::HTML(open(printer.template.path), nil, 'utf-8')
      encoding = page.meta_encoding
      if !encoding
        page.meta_encoding = 'utf-8'
        IO.write(printer.template.path, page.to_html)
      end
    end

    def set_doc_part(printer, part, value)
      page = Nokogiri::HTML(open(printer.template.path))
      page_part = page.at_css(part)
      if page_part
        page_part.inner_html = value
      else
        head = page.at_css "head"

        if head
          page_part = Nokogiri::XML::Node.new part, page
          page_part.content = value
          head.add_next_sibling(page_part)
        elsif part == "body"
          page = Nokogiri::HTML::DocumentFragment.parse ""
          Nokogiri::HTML::Builder.with(page) do |doc|
            doc.html {
              doc.head
              doc.body
            }
          end
          page_part = page.at_css(part)
          page_part.inner_html = value
        end
      end

      if part == 'body'
        width = 'width:640px'
        style = page_part['style']
        if style && !style.include?(width)
          style += ';' + width
        else
          style = width
        end
        page_part.set_attribute('style', style)
      end
      IO.write(printer.template.path, page.to_html)
    end

    def set_filter_to(options)
      unless params[:mode_filter].nil? || params[:mode_filter] == 'all'
        options.merge! ( {:conditions => {:mode => t(".activerecord.attributes.printer.#{params[:mode_filter]}") }})
      end
    end

    def template_file(printer)
      if printer.template?
        file = printer.template.path
        filename = printer.template.file.identifier
      else
        default_forms_path = Rails.root.join "app/views/printers/default_forms/#{I18n.locale}"
        if printer.mode == "memo"
          path = default_forms_path.join "memo_#{printer.country.name}.html"
          path = default_forms_path.join "memo.html" unless File.exist?(path)
        else
          path = default_forms_path.join "#{printer.mode}.html"
        end
        if File.exist?(path)
          file = path
          filename = "#{I18n.t('activerecord.attributes.printer.' + printer.mode.to_s)} - #{I18n.t('.printers.default')}.html"
        end
      end
      [file, filename]
    end
end