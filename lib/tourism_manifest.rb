# -*- encoding : utf-8 -*-
module TourismManifest

  class << self

    def write_manifest_file(view_context)
      js_assets = %w[application css3-mediaqueries]
      css_assets = %w[application new_design/css/low new_design/css/middle new_design/css/high common]
      assets = {
        :js => parse_js_paths_from_tags(js_assets.map{ |js| view_context.javascript_include_tag(js) }.join),
        :css => parse_css_paths_from_tags(css_assets.map{ |css| view_context.stylesheet_link_tag(css) }.join),
        :img => get_asset_paths(:img)
      }
      manifest_path = File.join(Rails.root, "public/tourism.manifest")
      File.open(manifest_path, 'w') do |file|
        file.puts manifest_default_text
        assets[:js].sort.each { |js| file.puts js } if assets[:js]
        file.puts "\n"
        assets[:css].sort.each { |css| file.puts css } if assets[:css]
        file.puts "\n"
        if assets[:img]
          assets[:img].sort.each do |k, v|
            img = k == v ? "/assets/#{k}" : "/assets/#{k}\n/assets/#{v}"
            file.puts img
          end
        end
      end
    end

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

    def get_asset_paths(*keys)
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
      keys.empty? ? paths : paths.select{ |k,v| keys.include?(k) }
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
end
