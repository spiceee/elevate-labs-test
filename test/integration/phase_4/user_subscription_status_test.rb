require "test_helper"

# Phase 4 - User Subscription status
#
# The last step of this take home is to show the user’s subscription status on the /api/user GET request.
#
# {
#   "user": {
#     "id": 54321,
#     "email": "test@example.com"
#     "stats": {
#       "total_games_played": 5,
#     },
#     "subscription_status": "active"
#   }
# }
#
# Response to GET http://localhost:3000/api/user/
#
#
#
# In order to do so, you will have to integrate with the billing service that will return static values for the sake of this exercise. The service has been built as a testing ground. Thus, you can test for intermittent failures with the user_id=5 and every user_id > 100 will return a not_found error.

class Phase4UserSubscriptionStatusTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @token = @user.token
    @subscription = @user.subscription

    stub_request(:get, @subscription.gateway_url).with(
      headers: {"Authorization" => /Bearer .*/}
    ).to_return(
      status: 200, body: JSON.generate({subscription_status: "active"}), headers: {}
    )
  end

  test "user subscription status" do
    get "/api/user", headers: {"Authorization" => "Bearer #{@user.token}"}

    assert_response :success
    json_response = JSON.parse(@response.body)

    assert_equal "active", json_response["user"]["subscription_status"]
  end

  class With404FromBillingGateway < ActionDispatch::IntegrationTest
    setup do
      @user = users(:one)
      @token = @user.token
      @subscription = @user.subscription

      stub_request(:get, @subscription.gateway_url).with(
        headers: {"Authorization" => /Bearer .*/}
      ).to_return(
        status: 404, body: JSON.generate({error: "not_found"}), headers: {}
      )
    end

    test "should not touch user subscription status" do
      @subscription.update(active: true, last_checked_at: 3.days.ago)
      get "/api/user", headers: {"Authorization" => "Bearer #{@user.token}"}

      assert_response :success
      json_response = JSON.parse(@response.body)

      assert_equal "active", json_response["user"]["subscription_status"]
    end
  end

  class WithExpiredStatusFromBillingGateway < ActionDispatch::IntegrationTest
    setup do
      @user = users(:one)
      @token = @user.token
      @subscription = @user.subscription

      stub_request(:get, @subscription.gateway_url).with(
        headers: {"Authorization" => /Bearer .*/}
      ).to_return(
        status: 200, body: JSON.generate({subscription_status: "expired"}), headers: {}
      )
    end

    test "should not touch user subscription status" do
      @subscription.update(active: true, last_checked_at: 3.days.ago)
      get "/api/user", headers: {"Authorization" => "Bearer #{@user.token}"}

      assert_response :success
      json_response = JSON.parse(@response.body)

      assert_equal "expired", json_response["user"]["subscription_status"]
    end
  end
end
