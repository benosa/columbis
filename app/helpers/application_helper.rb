module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to({ :sort => column, :direction => direction, :filter => params[:filter] }, { :class => css_class }) do
      raw(title.to_s + tag('span', :class => 'sort_span ' << css_class.to_s))
    end
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

      @javascript_local_data = text.length > 0 ? text : false
    end
    @javascript_local_data
  end

  private

    def manifest_default_text
      text = <<-MANIFEST_TEXT
        CACHE MANIFEST
        # #{Time.now.utc}

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

class Float
  def to_money
    sprintf("%0.0f", self)
  end

  def to_percent
    sprintf("%0.2f", self)
  end
end

class String
  def initial
    self.chars.first + '.'
  end
end

module ActionView
  module Helpers
    module TranslationHelper
      def localize(*args)
        #Avoid I18n::ArgumentError for nil values
        I18n.localize(*args) unless args.first.nil?
      end
      # l() still points at old definition
      alias l localize
    end
  end
end

module ActiveRecord
  class Base
    def self.local_data(*args)
      if args && args.length > 0
        options = args.extract_options!
        settings = {
          :options => options,
          :args => args.dup
        }        

        # Check extra data hash or method
        if options[:extra_data].present?
          settings[:extra_data] = options[:extra_data]         
        end

        # Check extra data hash or method
        if options[:columns_filter].present?
          settings[:columns_filter] = options[:columns_filter]         
        end

        # Check data filter
        if options[:data_filter].present?
          settings[:data_filter] = options[:data_filter]
        end

        # Check data scope
        if options[:scope].present?
          settings[:scope] = options[:scope]
        end

        @local_data_setting = settings
        
      elsif @local_data.nil?
        @local_data = []
        @local_data_setting ||= {}

        settings = @local_data_setting
        options = settings[:options] || {}
        args = settings[:args] || []
        
        # Add attributes
        if options[:attributes].nil? || options[:attributes] == :all          
          @local_data += attribute_names.map(&:to_sym)
        elsif options[:attributes]
          @local_data += options[:attributes]
        end

        # Add methods
        @local_data += args
        
        # To add extra columns, if they are defined
        # All associations have to defined there
        if options[:extra_columns].present?
          if options[:extra_columns].is_a? Array
            @local_data += options[:extra_columns]
          elsif options[:extra_columns].is_a? Symbol and self.respond_to? options[:extra_columns]
            @local_data += self.send(options[:extra_columns])
          end
        end

        @local_data.uniq!

        # To filter columns, if a columns filter is given        
        if settings[:columns_filter].present? and settings[:columns_filter].is_a? Symbol and self.respond_to? settings[:columns_filter]
          @local_data = @local_data.select { |column| self.send(settings[:columns_filter], column) }
        end               
      end

      # Return all attribute names by default
      @local_data || attribute_names.map(&:to_sym)     
    end

    def self.local_data_settings
      @local_data_setting || {}
    end

    def self.local_data_scoped
      scope = self.local_data_settings[:scope]
      # Rails.logger.debug "settings: #{self.local_data_settings.map{|k,v| k.to_s + ' => ' + v.to_s}.join(', ')}"
      if scope.respond_to?(:call)
        scoped = scope.bind(self).call
      elsif scope.is_a? Symbol and self.respond_to? scope
        scoped = self.send(scope)
      end
      scoped
    end

    def self.scoped_by_ability(ability)
      self.accessible_by(ability)
    end

    def local_data
      data = {}
      settings = self.class.local_data_settings

      extra_data = settings[:extra_data]
      extra_data = self.send(extra_data) if extra_data.is_a?(Symbol)
      extra_data = {} unless extra_data.is_a? Hash
      
      self.class.local_data.each do |atr|        
        if extra_data[atr].present?
          value = origin_value = extra_data[atr]
        elsif self.respond_to? atr
          origin_value = self.send atr
          value = local_data_default_value_handler(origin_value)
        end
        
        # Use data filter, if it's defined
        data_filter = settings[:data_filter]
        if data_filter.respond_to?(:call)
          value = data_filter.bind(self).call(atr, value, origin_value)
        elsif data_filter.is_a? Symbol and self.respond_to? data_filter
          value = self.send(data_filter, atr, value, origin_value)
        end

        # Skip attribute if value is nil
        data[atr] = value unless value.nil?          
      end

      data
    end

    private

      def local_data_default_value_handler(value)
        if value.is_a? Time or value.is_a? Date or value.is_a? DateTime
          I18n.l(value, :format => :long)
        elsif value.is_a? ActiveRecord::Associations
          value.try(:name) || value.try(:id)
        else
          value
        end
      end
    
  end
end