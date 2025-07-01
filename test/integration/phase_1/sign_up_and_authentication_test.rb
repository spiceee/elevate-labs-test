require "test_helper"

# Phase 1 - Sign-up and Authentication
#
# The client should be able to sign up a new user and, once signed-up, provide a user’s credentials to the backend and have that user become “logged-in”. We would like this to follow best practices for security.
#
# The signup endpoint will be hosted at /api/user using a POST verb. A user should have an email and password. The API will receive the new user’s information in JSON format and reply with a “201 Created” on success.
#
# {
#     "email": "example@example.com",
#     "password": "strong_password"
# }
#
# Request Payload to POST http://localhost:3000/api/user
#
#
#
# For login the path should be /api/sessions and the request will arrive as a POST with the credentials in JSON format similar to the create endpoint. Return a token for the user.
# {
#   "token": ...
# }
#
# Response to POST http://localhost:3000/api/sessions
# Subsequent API requests should be restricted to logged-in users.

class Phase1 < ActionDispatch::IntegrationTest
  class WithSignUp < ActionDispatch::IntegrationTest
    test "can signup user with valid input" do
      post "/api/user", params: {email: "test@example.com", password: "password"}, as: :json

      assert_response :created
    end

    test "cannot signup user with invalid email" do
      post "/api/user", params: {email: "", password: "password"}, as: :json

      assert_response :unprocessable_entity
    end

    test "cannot signup user with invalid password" do
      post "/api/user", params: {email: "test@example.com", password: ""}, as: :json

      assert_response :unprocessable_entity
    end
  end

  class WithSessionCreate < ActionDispatch::IntegrationTest
    test "can create session with valid credentials" do
      post "/api/user", params: {email: "test@example.com", password: "password"}, as: :json

      assert_response :created

      post "/api/sessions", params: {email: "test@example.com", password: "password"}, as: :json

      assert_response :created
      assert_not_nil JSON.parse(@response.body)["token"]
    end

    test "gets an auth token with a successful response" do
      post "/api/user", params: {email: "test@example.com", password: "password"}, as: :json

      assert_response :created

      post "/api/sessions", params: {email: "test@example.com", password: "password"}, as: :json

      assert_not_nil JSON.parse(@response.body)["token"]
    end

    test "cannot create session with invalid email" do
      post "/api/user", params: {email: "test@example.com", password: "password"}, as: :json

      assert_response :created

      post "/api/sessions", params: {email: "", password: "password"}, as: :json

      assert_response :unauthorized
    end

    test "cannot create session with invalid password" do
      post "/api/user", params: {email: "test@example.com", password: "password"}, as: :json

      assert_response :created

      post "/api/sessions", params: {email: "test@example.com", password: ""}, as: :json

      assert_response :unauthorized
    end
  end
end
