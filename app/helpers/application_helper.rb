# -*- encoding : utf-8 -*-
module ApplicationHelper
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

  def per_page(default = 30)
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

  def current_path(args = {})
    url_params = args.dup
    if args[:save_params]
      url_params.delete(:save_params)
      url_params.reverse_merge!(params)
    end
    url_for(url_params)
  end

  def redirect_back(options = {})
    default = options.delete(:default) || root_path
    redirect_to (request.referer.present? && request.referer != request.original_url ? :back : default), options
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
      :star => true,
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
    dir = col == sort_col(default_and_dir ? col : nil) ? sort_dir(default_and_dir == :desc ? :desc : :asc) : :asc
    link_to title.to_s, '#', { :class => css_class, :data => { :sort => col, :dir => dir } }
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

  # Current site width calculated relative to client resolution
  # available site resolutions: 1024x768 1600x900 1920x1080
  def current_width
    return @current_width if @current_width.present?
    width = (current_user.screen_width if current_user).to_i
    width = client_resolution[:width].to_i unless width > 0
    @current_width = case width
      when 0...1600 then :small
      else :medium
      # when 1600...1920 then :medium
      # else :large
    end
  end

  # Set current width explicitly
  def current_width=(width)
    if [:small, :medium, :large].include?(width)
      @current_width = width
    else
      @current_width = current_width
    end
  end

  # For using in views
  def set_current_width(width)
    # self.current_width = (width)
  end

  # Define helpers: small_width?, medium_width?, large_width?
  [:small, :medium, :large].each do |w|
    define_method :"#{w}_width?" do
      current_width == w
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

end
