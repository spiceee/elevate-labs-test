require "test_helper"

class Api::User::GameEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @token = @user.token
    @valid_payload = {
      game_event: {
        game_name: "Brevity",
        type: "COMPLETED",
        occurred_at: "2025-01-01T00:00:00.000Z"
      }
    }
    @bad_payload = {
      game_event: {
        game_name: "Brevity",
        type: "ONGOING",
        occurred_at: "2025-01-01T00:00:00.000Z"
      }
    }
  end

  test "should register a game event" do
    post api_user_game_events_url, headers: {"Authorization" => "Bearer #{@token}"}, params: @valid_payload, as: :json
    assert_response :success
  end

  test "should not register a game event with invalid payload" do
    post api_user_game_events_url, headers: {"Authorization" => "Bearer #{@token}"}, params: @bad_payload, as: :json
    assert_response :unprocessable_entity
  end
end
