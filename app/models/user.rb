# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  include ActiveModel::SecurePassword

  has_secure_password
  has_one :api_token, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_many :game_events, dependent: :destroy
  after_create -> { create_subscription }

  validates :email, presence: true, uniqueness: true

  def token
    @token ||= (api_token || create_api_token).token
  end

  private

  def create_subscription
    Subscription.create(user: self)
  end

  def create_api_token
    ApiToken.create(user: self)
  end
end
