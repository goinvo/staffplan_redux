class Registration < ApplicationRecord
  belongs_to :user, optional: true

  validates :name, presence: true
  validates :email, presence: true
  validates :expires_at, presence: true
  validates :token_digest, presence: true
  validates :ip_address, presence: true

  before_validation :set_defaults

  scope(
    :available,
    lambda { where("expires_at > ?", Time.current) }
  )

  class RegistrationNotAvailableError < StandardError; end

  attr_reader :token

  def token=(plaintext)
    self.token_digest = Passwordless.digest(plaintext)
    @token = (plaintext)
  end

  def expired?
    expires_at <= Time.current
  end

  def available?
    !expired?
  end

  def register!
    raise RegistrationNotAvailableError if registered?

    company = Company.create(name: "#{name}'s' Company")

    user = AddUserToCompany.new(
      email:, name:, company:, role: "owner"
    ).call

    update(user:, registered_at: Time.current)
  end

  def registered?
    !registered_at.blank?
  end

  def to_param
    identifier
  end

  private

  def token_digest_available?(token_digest)
    Registration.available.where(token_digest: token_digest).none?
  end

  def set_defaults
    self.expires_at ||= Passwordless.config.expires_at.call

    return if self.token_digest

    self.token, self.token_digest = loop {
      token = Passwordless.config.token_generator.call(self)
      digest = Passwordless.digest(token)
      break [token, digest] if token_digest_available?(digest)
    }
  end
end
