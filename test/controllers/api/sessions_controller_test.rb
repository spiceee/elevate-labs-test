require "test_helper"

class Api::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should start a session with valid credentials" do
    post api_sessions_url, params: {email: @user.email, password: "testpassword1"}, as: :json

    assert_response :created
    assert_not_nil JSON.parse(@response.body)["token"]
  end

  test "should return an unauthorized response with invalid credentials" do
    post api_sessions_url, params: {email: @user.email, password: "wrongpassword"}, as: :json

    assert_response :unauthorized
    assert_not_nil JSON.parse(@response.body)["error"]
  end

  test "should be able to destroy a session when logged in" do
    post api_sessions_url, params: {email: @user.email, password: "testpassword1"}, as: :json

    assert_response :created
    assert_not_nil JSON.parse(@response.body)["token"]

    delete api_session_url(@user), as: :json

    assert_response :no_content
  end

  test "should be able to destroy a session with an API Bearer token" do
    delete api_session_url(@user), headers: {"Authorization" => "Bearer #{@user.token}"}, as: :json
    assert_response :no_content
  end

  test "should respond as unauthorized when trying to destroy a session without a valid token" do
    delete api_session_url(@user), headers: {"Authorization" => "Bearer 1234"}, as: :json
    assert_response :unauthorized
  end

  test "should respond as unauthorized when trying to destroy a session without a valid token or a valid session" do
    delete api_session_url(@user), as: :json
    assert_response :unauthorized
  end
end
