require "test_helper"

class Api::UsersControllerTest < ActionDispatch::IntegrationTest
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

  test "should create user" do
    assert_difference("User.count") do
      post api_user_url, params: {email: Faker::Internet.email, password: Faker::Internet.password}, as: :json
    end

    assert_response :created
  end

  test "should show user stats" do
    get api_user_url, headers: {"Authorization" => "Bearer #{@user.token}"}, as: :json

    assert_response :success
    assert_not_nil JSON.parse(@response.body)["user"]["stats"]["total_games_played"]
  end

  test "should return unauthorized when requesting user stats with no credentials" do
    get api_user_url, as: :json

    assert_response :unauthorized
  end

  test "should show user subscription status" do
    get api_user_url, headers: {"Authorization" => "Bearer #{@user.token}"}, as: :json

    assert_response :success
    assert_not_nil JSON.parse(@response.body)["user"]["subscription_status"]
  end

  test "should show user subscription status as active" do
    @user.subscription.update(active: true)
    get api_user_url, headers: {"Authorization" => "Bearer #{@user.token}"}, as: :json

    assert_response :success
    subscription_status = JSON.parse(@response.body)["user"]["subscription_status"]
    assert subscription_status == "active"
  end

  test "should show user subscription status as expired" do
    @user.subscription.update(active: false)
    stub_request(:get, @subscription.gateway_url).with(
      headers: {"Authorization" => /Bearer .*/}
    ).to_return(
      status: 200, body: JSON.generate({subscription_status: "expired"}), headers: {}
    )
    get api_user_url, headers: {"Authorization" => "Bearer #{@user.token}"}, as: :json

    assert_response :success
    subscription_status = JSON.parse(@response.body)["user"]["subscription_status"]
    assert subscription_status == "expired"
  end
end
