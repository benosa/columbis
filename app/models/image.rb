class Image < ActiveRecord::Base
  attr_accessible :file
  belongs_to :imageable, polymorphic: true
  mount_uploader :file, ImagesUploader
end
