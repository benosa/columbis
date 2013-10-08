# -*- encoding : utf-8 -*-
CarrierWave::SanitizedFile.sanitize_regexp = /[^a-zA-Zа-яА-ЯёЁ0-9\.\-\+_]/u

CarrierWave.configure do |config|
  # These permissions will make dir and files available only to the user running
  # the servers
  config.permissions = 0600
  config.directory_permissions = 0700
  config.storage = :file
  # This avoids uploaded files from saving to public/ and so
  # they will not be available for public (non-authenticated) downloading
  config.root = Rails.root
end
