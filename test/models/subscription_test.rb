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
require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "#gateway_url" do
    assert_equal "https://interviews-accounts.elevateapp.com/api/v1/users/#{@user.id}/billing", @user.subscription.gateway_url
  end

  test "#needs_status_refresh? should be true if last_checked_at is nil" do
    subscription = Subscription.create(last_checked_at: nil, user: @user)
    assert subscription.needs_status_refresh?
  end

  test "#needs_status_refresh? should be true if last_checked_at is more than a day old" do
    subscription = Subscription.create(last_checked_at: 4.days.ago, user: @user)
    assert subscription.needs_status_refresh?
  end

  test "#needs_status_refresh? should be false if last_checked_at is within the last 2 hours" do
    subscription = Subscription.create(last_checked_at: 2.hours.ago, user: @user)
    assert_not subscription.needs_status_refresh?
  end

  test "#active? should be truthy if active is true" do
    subscription = Subscription.new(active: true)
    assert subscription.active?
  end

  test "#active? should be falsey if active is false" do
    subscription = Subscription.new(active: false)
    assert_not subscription.active?
  end

  test "#active? should be false if active is nil" do
    subscription = Subscription.new(active: nil)
    assert_not subscription.active?
  end

  test "#expired? should be truthy if active is false" do
    subscription = Subscription.new(active: false)
    assert subscription.expired?
  end

  test "#expired? should be false if active is nil" do
    subscription = Subscription.new(active: nil)
    assert_not subscription.expired?
  end

  test "#expired? should be false if active is true" do
    subscription = Subscription.new(active: true)
    assert_not subscription.expired?
  end

  test "Subscription#needs_status_refresh should be true if last_checked_at is nil" do
    subscription = Subscription.create(last_checked_at: nil, user: @user)
    assert Subscription.needs_status_refresh.include?(subscription)
  end

  test "Subscription#needs_status_refresh should be true if last_checked_at is older than 24 hours" do
    subscription = Subscription.create(last_checked_at: 25.hours.ago, user: @user)
    assert Subscription.needs_status_refresh.include?(subscription)
  end

  test "Subscription#needs_status_refresh should be false if last_checked_at is within 24 hours" do
    subscription = Subscription.create(last_checked_at: 23.hours.ago, user: @user)
    assert_not Subscription.needs_status_refresh.include?(subscription)
  end

  test "Subscription#needs_status_refresh should be false if last_checked_at was 2 hours ago" do
    subscription = Subscription.create(last_checked_at: 2.hours.ago, user: @user)
    assert_not Subscription.needs_status_refresh.include?(subscription)
  end

  test "Subscription#active should include an active subscription" do
    subscription = Subscription.create(active: true, user: @user)
    assert Subscription.active.include?(subscription)
  end

  test "Subscription#expired should include an expired subscription" do
    subscription = Subscription.create(active: false, user: @user)
    assert Subscription.expired.include?(subscription)
  end

  test "Subscription#active should not include an expired subscription" do
    subscription = Subscription.create(active: false, user: @user)
    assert_not Subscription.active.include?(subscription)
  end

  test "Subscription#expired should not include an active subscription" do
    subscription = Subscription.create(active: true, user: @user)
    assert_not Subscription.expired.include?(subscription)
  end

  test "should update the status to active according to the billing gateway response" do
    subscription = Subscription.create(active: false, user: @user)
    assert subscription.expired?

    stub_request(:get, subscription.gateway_url).with(
      headers: {"Authorization" => /Bearer .*/}
    ).to_return(
      status: 200, body: JSON.generate({subscription_status: "active"}), headers: {}
    )

    subscription.check_status_in_gateway
    assert subscription.reload.active?
  end

  test "should update the status to expired to the billing gateway response" do
    subscription = Subscription.create(active: true, user: @user)
    assert subscription.active?

    stub_request(:get, subscription.gateway_url).with(
      headers: {"Authorization" => /Bearer .*/}
    ).to_return(
      status: 200, body: JSON.generate({subscription_status: "expired"}), headers: {}
    )

    subscription.check_status_in_gateway
    assert subscription.reload.expired?
  end

  # as mentioned in the assignment, the gateway will return 404s intermitently for some IDs (> 100)
  # the assignment doesn't mention what would be the business logic for a 404, so we leave
  # the subscription status untouched
  test "should not update the subscription if upstream response from the gateway is 404" do
    subscription = Subscription.create(active: true, user: @user)
    assert subscription.active?

    stub_request(:get, subscription.gateway_url).with(
      headers: {"Authorization" => /Bearer .*/}
    ).to_return(
      status: 404, body: "Not found", headers: {}
    )

    subscription.check_status_in_gateway
    assert_not subscription.reload.expired?
  end
end
