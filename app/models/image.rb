class Image < ActiveRecord::Base
  attr_accessible :file, :company_id
  belongs_to :imageable, polymorphic: true
  belongs_to :company
  mount_uploader :file, ImageUploader

  validates :file, :file_size => { :maximum => CONFIG[:max_image_size].megabytes.to_i  }
end
