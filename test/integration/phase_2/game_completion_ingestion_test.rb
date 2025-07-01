require "test_helper"

# Phase 2 - Game Completion Ingestion

# The client will post a completion event every time a game is completed. (A game can be completed multiple times.) This will be a POST to the endpoint /api/user/game_events. The only accepted type field is "COMPLETED"

# {
#   "game_event": {
#     "game_name":"Brevity",
#     "type":"COMPLETED",
#     "occurred_at":"2025-01-01T00:00:00.000Z"
#   }
# }

# Request payload POST http://localhost:3000/api/user/game_events

class Phase2GameCompletionIngestionTest < ActionDispatch::IntegrationTest
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

  test "logged-in user can submit game completion events" do
    post "/api/user/game_events", params: @valid_payload, headers: {"Authorization" => "Bearer #{@user.token}"}, as: :json

    assert_response :created
  end

  test "logged-in user cannot submit game completion events with invalid type" do
    post "/api/user/game_events", params: @bad_payload, headers: {"Authorization" => "Bearer #{@user.token}"}, as: :json

    assert_response :unprocessable_entity
  end

  test "not logged-in user cannot submit game completion events" do
    post "/api/user/game_events", params: @valid_payload, as: :json

    assert_response :unauthorized
  end
end
