# -*- encoding : utf-8 -*-
if Object.const_defined?('HoganAssets') # avoiding uninitialized constant error in rake tasks
  HoganAssets::Config.configure do |config|
    config.lambda_support = true
    config.template_namespace = 'JST'
    config.path_prefix = 'templates'
  end
end
