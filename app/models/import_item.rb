class ImportItem < ActiveRecord::Base
  attr_accessible :data, :file_line, :import_info_id, :model_class, :model_id, :success
  belongs_to :import_info
end
