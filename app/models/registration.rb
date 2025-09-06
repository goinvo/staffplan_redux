# frozen_string_literal: true

class Registration < ApplicationRecord
  belongs_to :user, optional: true

  validates :name, presence: true
  validates :company_name, presence: true
  validates :email, presence: true
  validates :expires_at, presence: true
  validates :token_digest, presence: true
  validates :ip_address, presence: true

  before_validation :set_defaults # rubocop:disable Layout/OrderedMethods

  scope(
    :available,
    -> { where('expires_at > ?', Time.current) },
  )

  class RegistrationNotAvailableError < StandardError; end

  attr_reader :token

  def available?
    !expired?
  end

  def expired?
    expires_at <= Time.current
  end

  def register!
    raise RegistrationNotAvailableError if registered?

    CreateNewCompany.new(
      company_name:,
      email:,
      name:,
      registration_id: id,
    ).call

    reload
  end

  def registered?
    registered_at.present?
  end

  def to_param
    identifier
  end

  def token=(plaintext)
    self.token_digest = Registration.digest(plaintext)
    @token = plaintext
  end

  def valid_token_digest?(token_param)
    token_digest == Registration.digest(token_param)
  end

  def self.digest(string)
    key = ActiveSupport::KeyGenerator.new(
      Rails.application.secret_key_base,
    ).generate_key(
      Rails.application.credentials.registration_salt,
    )
    OpenSSL::HMAC.hexdigest('SHA256', key, string)
  end

  private

  def generate_token
    SecureRandom.hex(16)
  end

  def set_defaults
    self.expires_at ||= 1.day.from_now

    return if token_digest

    self.token, self.token_digest = loop do
      token = generate_token
      digest = Registration.digest(token)
      break [token, digest] if token_digest_available?(digest)
    end
  end

  def token_digest_available?(token_digest)
    Registration.available.where(token_digest: token_digest).none?
  end
end
