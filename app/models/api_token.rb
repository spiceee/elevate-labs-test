# == Schema Information
#
# Table name: api_tokens
#
#  id         :integer          not null, primary key
#  active     :boolean
#  token      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_api_tokens_on_token    (token) UNIQUE
#  index_api_tokens_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#

# Ideally, a user should have as many API tokens as they have clients consuming the API.
# And API tokens should hold some metadata on which clients they are associated with and also have TTLs.
# They should be able to be revoked at any time.
# Recently, Netflix has done just that. The user API tokens can be revoked at any time. It is on the client to
# request that a new token be generated. Seems to work for them.

class ApiToken < ApplicationRecord
  belongs_to :user

  before_create :generate_token
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  encrypts :token, deterministic: true

  private

  def generate_token
    self.token = BCrypt::Password.create(SecureRandom.hex)
    self.active = true
  end
end
