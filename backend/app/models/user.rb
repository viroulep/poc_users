class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :identities

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def self.create_from_oauth(auth)
    puts "all info:"
    puts auth
    User.create!(email_address: auth.info.email, password: SecureRandom.base64(64).truncate_bytes(64))
  end
end
