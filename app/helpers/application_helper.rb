# -*- encoding : utf-8 -*-
module ApplicationHelper
  include Mistral::ApplicationHelperExtention

  def domain_root_url
    root_url(domain: CONFIG[:domain], subdomain: false) # "#{request.protocol}#{CONFIG[:domain]}#{request.port_string}"
  end

  def current_company_root_url
    options = { domain: CONFIG[:domain] }
    options[:subdomain] = (current_company.subdomain if current_company) || false
    root_url(options)
  end

  def url_for_current_company
    options = { domain: CONFIG[:domain] }
    options[:subdomain] = (current_company.subdomain if current_company) || false
    url_for options
  end

  def current_path(args = {})
    url_params = args.dup
    if args[:save_params]
      url_params.delete(:save_params)
      url_params.reverse_merge!(params)
    end
    url_for(url_params)
  end

  def domain_new_user_session_url
    new_user_session_url(domain: CONFIG[:domain], subdomain: false)
  end

  def redirect_back(options = {})
    default = options.delete(:default) || root_path
    redirect_to (request.referer.present? && request.referer != request.original_url ? :back : default), options
  end

  def link_for_view_switcher
    label = params[:list_type] == 'manager_list' ? 'accountant_list' : 'manager_list'
    link_to t('claims.index.' << label), claims_path(:list_type => label), :class =>  'accountant_login', :list_type => params[:list_type]
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to(name, '#', :class => 'remove')
  end

  def li_class(claim, target)
    if [:contract, :permit, :warranty, :act].include? target
      printer = "#{target}_printer".to_sym
      (claim && !claim.new_record? && claim.company.try(printer)) ? 'enabled' : 'disabled'
    elsif target == :memo
      (claim && !claim.new_record? && claim.company.try(:memo_printer_for, claim.country)) ? 'enabled' : 'disabled'
    end
  end

  def per_page(default = nil)
    default = CONFIG[:per_page_list][(CONFIG[:per_page_list].length / 2 + 1)] if CONFIG[:per_page_list] && !default
    if user_signed_in?
      per_page_key = "#{current_user.login}-per_page".to_sym
      cookies[per_page_key] = params[:per_page] if params[:per_page].present?
      (cookies[per_page_key] || default).to_i
    else
      (params[:per_page] || default).to_i
    end
  end

  def next_page
    next_page = params[:page].to_i + 1
    next_page = 2 if next_page < 2
    next_page
  end

  def write_manifest_file
    assets = {
      :js => parse_js_paths_from_tags(view_context.javascript_include_tag 'application'),
      :css => parse_css_paths_from_tags([view_context.stylesheet_link_tag('application'), view_context.stylesheet_link_tag('jquery-ui')].join),
      :img => get_asset_paths[:img]
    }
    manifest_path = File.join(Rails.root, "public/tourism.manifest")
    File.open(manifest_path, 'w') do |file|
      file.puts manifest_default_text
      assets[:js].sort.each { |js| file.puts js }
      file.puts "\n"
      assets[:css].sort.each { |css| file.puts css }
      file.puts "\n"
      assets[:img].sort.each do |k, v|
        img = k == v ? "/assets/#{k}" : "/assets/#{k}\n/assets/#{v}"
        file.puts img
      end
    end
  end

  def javascript_local_data
    if @javascript_local_data.nil?
      text = "";
      text += "window.tourism_offline = true;" if params[:offline]
      text += "window.tourism_current_user = '#{current_user.login}';" if current_user
      text += "window.tourism_current_company = '#{current_company.name}';" if current_company

      @javascript_local_data = text.length > 0 ? text : false
    end
    @javascript_local_data
  end

  # Helper to filter and order the search results for model class based on params
  def search_and_sort(model, _options = {})
    options = search_and_sort_options(_options)

    if options[:with_current_abilities]
      options.delete(:with_current_abilities)
      abilities_hash = current_ability.attributes_for(:read, model) || {}
      if options[:with].present? and options[:with].kind_of? Hash
        options[:with].reverse_merge!(abilities_hash)
      else
        options[:with] = abilities_hash
      end
    end

    if model.respond_to?(:search_and_sort)
      model.send(:search_and_sort, options)
    else
      filter = options.delete(:filter)
      model.search(filter, options)
    end
  end

  def search_and_sort_options(options = {})
    defaults = options.delete(:defaults) || {}
    defaults.reverse_merge!({
      :star => /[[[:word:]]+,-.@]+/u,
      :filter => params[:filter] || '',
      :page => params[:page],
      :per_page => per_page
    })
    if params[:sort].present?
      defaults.merge!({
        :order => sort_col,
        :sort_mode => sort_dir,
        :ignore_default => true
      })
      # defaults[:sql_order] = "#{sort_col} #{sort_dir.upcase}"
    end
    options.reverse_merge!(defaults)
  end

  def search_or_sort?
    params[:filter].present? or params[:sort].present?
  end

  # To paginate scoped relation after it was searched by thinking sphinx
  def search_paginate(rel, options = {})
    if rel.respond_to? :search_info
      search_info = rel.search_info
    elsif rel.respond_to?(:klass) && rel.klass.respond_to?(:search_info)
      search_info = rel.klass.search_info
    else
      search_info = {
        :total_pages => options[:total_pages],
        :total_entries => options[:total_entries]
      }
    end
    rel.paginate({
      :page => options[:page] || params[:page],
      :per_page => options[:per_page] || per_page,
      :count => search_info[:total_pages],
      :total_entries => search_info[:total_entries]
    }).offset(0) # use it to skip offset provided by will_paginate, because thinking sphinx return 1 page
  end

  def limit_collection_total_entries(collection)
    if collection.total_entries > CONFIG[:total_entries]
      collection.total_entries = CONFIG[:total_entries]
    end
  end

  def sort_col(default = :id)
    params[:sort] ? params[:sort].to_sym : default
  end

  def sort_dir(default = :asc)
    %w[asc desc].include?(params[:dir]) ? params[:dir].to_sym : default
  end

  def sort_toggle_direction(dir)
    dir.to_sym == :asc ? :desc : :asc
  end

  def sort_link(column, title = nil, default_and_dir = nil)
    col = column.to_sym
    title ||= col.titleize
    css_class = col == sort_col(default_and_dir ? col : nil) ? "sort_active #{sort_dir(default_and_dir == :desc ? :desc : :asc)}" : nil
    dir = if col == sort_col(default_and_dir ? col : nil)
      sort_dir(default_and_dir == :desc ? :desc : :asc)
    else
      (Claim.columns_hash[column].try(:type).try(:to_s) =~ /^date/ ? :desc : :asc)
    end
    link_to title.to_s, '#', { :id => "#{col}_link",  :class => css_class, :data => { :sort => col, :dir => dir } }
  end

  def availability_filter_options
    I18n.t('availability_filter_options').invert.to_a
  end

  def availability_filter(options)
    options[:with] ||= {}
    case params[:availability]
    when 'own'
      options[:with][:common] = false
      options[:with][:company_id] = current_company.id
    when 'common'
      options[:with][:common] = true
      options[:with][:company_id] = 0
    else
      unless is_admin?
        options[:sphinx_select] = "*, IF(common = 1 OR company_id = #{current_company.id}, 1, 0) AS company"
        options[:with]['company'] = 1
        options[:with].delete(:company_id)
        options[:with].delete(:common)
      end
    end
  end

  # Client resolution parameters base on cookie
  def client_resolution
    return @client_resolution if @client_resolution.present?
    @client_resolution = if cookies[:screen_size]
      ActiveSupport::JSON.decode(cookies[:screen_size], :symbolize_keys => true) rescue { :width => 1024, :height => 768 }
    else
      { :width => 1024, :height => 768 }
    end
  end

  def ac_data(data = {})
    { ac: data }
  end

  def current_zone_datetime(only_time = false)
    # Time.zone.now.to_i == Time.now.to_i, it doesn't account zone
    format = !only_time ? "%Y.%m.%d %H:%M:%S" : "%H:%M:%S"
    Time.zone.now.strftime(format)
  end

  def demo_company
    @demo_company ||= Company.where(subdomain: 'demo').first
  end

  def demo_company?
    current_company == demo_company
  end

  # Nested fields
  def fields_for_add_button(text, form, association, options = {})
    new_object = form.object.send(association).klass.new
    id = new_object.object_id
    partial = options.delete(:partial) || association.to_s.singularize + '_fields'
    button_class = options.delete(:class) || 'nested-fields-add'
    fields = form.fields_for(association, new_object, child_index: id) do |builder|
      render partial, f: builder
    end
    link_data = { id: id, fields: fields.gsub("\n", '') }.reverse_merge(options)
    link_to text, '#', class: button_class, data: link_data
  end

  def export_notification_data
    {
      export_notification: can?(:export_notification, :user) ? current_user.try(:export_notification).to_s : false,
      export_n_message: I18n.t('export_n_message')
    }
  end

  def html_data
    if current_user.start_trip
      {
        start_trip_step: current_user.start_trip.step
      }
    end
  end

  private

    def manifest_default_text
      text = <<-MANIFEST_TEXT
        CACHE MANIFEST
        # #{Time.zone.now.utc}

        FALLBACK:
        / /offline.html

        NETWORK:
        *

        SETTINGS:
        prefer-online

        CACHE:
        /offline.html

        MANIFEST_TEXT
      text.gsub!(/^[ \t]+/m, '')
    end

    def get_asset_paths
      paths = {}
      app = Rails.application
      assets = app.assets
      assets.each_logical_path do |logical_path|
        if File.basename(logical_path)[/[^\.]+/, 0] == 'index'
          logical_path.sub!(/\/index\./, '.')
        end

        # grabbed from Sprockets::Environment#find_asset
        pathname = Pathname.new(logical_path)
        if pathname.absolute?
          return unless stat(pathname)
          logical_path = assets.attributes_for(pathname).logical_path
        else
          begin
            pathname = assets.resolve(logical_path)
          rescue Sprockets::FileNotFound
            return nil
          end
        end

        asset = Sprockets::Asset.new(assets, logical_path, pathname)

        key = File.extname(logical_path)[1..-1].to_sym
        key = :img unless [:js, :css].include?(key)
        paths[key] = {} unless paths[key]
        paths[key][logical_path] = app.config.assets.digest ? asset.digest_path : asset.logical_path
      end
      paths
    end

    def parse_js_paths_from_tags(text)
      paths = []
      text.scan(/src="([^"]+)"/) { |path| paths << path }
      paths
    end

    def parse_css_paths_from_tags(text)
      paths = []
      text.scan(/href="([^"]+)"/) { |path| paths << path }
      paths
    end

    def resource_name
      :user
    end

    def resource
      @resource ||= User.new
    end

    def devise_mapping
      @devise_mapping ||= Devise.mappings[:user]
    end

end
