class ItemField < ActiveRecord::Base
  belongs_to :catalog
  has_many :notes, :dependent => :destroy
end
