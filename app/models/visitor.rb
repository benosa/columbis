class Visitor < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :email, :name, :phone, :confirmation_token, :confirmed_at, :confirmed

  belongs_to :user
  scope :confirmed1, :conditions => {:confirmed => true}
  validates :phone, presence: true, length: { minimum: 8 }, :uniqueness => { :scope => self.confirmed1 }#{:conditions => {:confirmed => true}}#{ :scope => (:confirmed == true) }
  validates :email, email: true, presence: true, :uniqueness => true

  after_create do |company|
    Mailer.visitor_was_created(self).deliver
  end if CONFIG[:support_delivery]

  def self.friendly_token
    SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
  end
end
