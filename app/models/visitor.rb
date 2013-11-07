class Visitor < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :email, :name, :phone, :confirmation_token, :confirmed_at, :confirmed

  belongs_to :user

  validates :name, presence: true
  validates :phone, presence: true, length: { minimum: 8 }
  validates :email, email: true, presence: true, :uniqueness => true
  validates_with VisitorPhoneValidator
  before_save :generate_confirmation_token

  after_create do |company|
    Mailer.visitor_was_created(self).deliver
  end if CONFIG[:support_delivery]

  def generate_confirmation_token
    if !confirmation_token
      loop do
        @token = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
        break @token unless Visitor.where(confirmation_token: @token).first
      end
    	self.confirmation_token = @token
    end
  end

  def confirm
    self.confirmed = true
    self.confirmed_at = Time.zone.now
    self.save
  end

  def confirmed?
    self.confirmed
  end
end
