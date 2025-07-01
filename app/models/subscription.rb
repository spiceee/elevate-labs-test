# == Schema Information
#
# Table name: subscriptions
#
#  id              :integer          not null, primary key
#  active          :boolean
#  last_checked_at :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer          not null
#
# Indexes
#
#  index_subscriptions_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class Subscription < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(active: true) }
  scope :expired, -> { where(active: false) }
  scope :needs_status_refresh, -> { where("last_checked_at IS NULL OR last_checked_at < ?", 24.hours.ago) }

  GATEWAY_URI = "https://interviews-accounts.elevateapp.com/api/v1"
  JWT_TOKEN = Rails.application.credentials.billing_gateway&.jwt_token

  def gateway_url
    "#{GATEWAY_URI}/users/#{user_id}/billing"
  end

  def active?
    active == true
  end

  def expired?
    active == false
  end

  def needs_status_refresh?
    last_checked_at.nil? || last_checked_at < 24.hours.ago
  end

  def check_status_in_gateway
    response = Faraday.get(gateway_url) do |req|
      req.headers["Authorization"] = "Bearer #{JWT_TOKEN}"
      req.headers["Accept"] = "application/json"
    end

    if response.success?
      data = JSON.parse(response.body)
      subscription_remote_status = data["subscription_status"]
      pp data if Rails.env.development?

      ActiveRecord::Base.transaction do
        if subscription_remote_status
          if subscription_remote_status == "active"
            self.active = true
          elsif subscription_remote_status == "expired"
            self.active = false # expired
          end

          self.last_checked_at = Time.now
          save!
        else
          Rails.logger.error "Billing API error: #{response.status} – #{response.body}"
        end
      end
    else
      Rails.logger.error "Billing API error: #{response.status} – #{response.body}"
    end
  rescue => e
    Rails.logger.error "Error checking subscription status: #{e.message}"
  end
end
