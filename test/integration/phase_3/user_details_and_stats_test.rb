require "test_helper"

# Phase 3 - User Details and Stats
#
# The client will request the user details after login and each time the application opens to get the latest stats and any changes to the user details. This will be a GET request to http://localhost:3000/api/user/ .
#
# {
#   "user": {
#     "id": 54321,
#     "email": "test@example.com"
#     "stats": {
#       "total_games_played": 5,
#     }
#   }
# }
#
# Response to GET http://localhost:3000/api/user/

class Phase3UserDetailsAndStatsTest < ActionDispatch::IntegrationTest
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

  test "user details and stats" do
    get "/api/user", headers: {"Authorization" => "Bearer #{@user.token}"}

    assert_response :success
    json_response = JSON.parse(@response.body)

    assert_equal @user.id, json_response["user"]["id"]
    assert_equal @user.email, json_response["user"]["email"]
    assert_equal 5, json_response["user"]["stats"]["total_games_played"]
  end

  test "non-logged users cannot see user details and stats" do
    get "/api/user", headers: {"Authorization" => "Bearer 123"}

    assert_response :unauthorized
  end
end
