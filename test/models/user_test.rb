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

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "authenticates user with valid password" do
    user = User.create!(email: "test@example.com", password: "securepassword", password_confirmation: "securepassword")
    authenticated_user = user.authenticate("securepassword")
    assert_equal user, authenticated_user, "User should be authenticated with valid password"
  end

  test "does not authenticate user with invalid password" do
    user = User.create!(email: "test@example.com", password: "securepassword", password_confirmation: "securepassword")
    authenticated_user = user.authenticate("wrongpassword")
    assert_not authenticated_user, "User should not be authenticated with invalid password"
  end

  test "user is valid with valid attributes" do
    user = User.new(email: "test@example.com", password: "securepassword", password_confirmation: "securepassword")
    assert user.valid?, "User should be valid with valid attributes"
  end

  test "user is invalid without email" do
    user = User.new(password: "securepassword", password_confirmation: "securepassword")
    assert_not user.valid?, "User should be invalid without email"
  end

  test "user is invalid without password" do
    user = User.new(email: "test@example.com", password_confirmation: "securepassword")
    assert_not user.valid?, "User should be invalid without password"
  end

  test "user is valid when password confirmation is not set" do
    user = User.new(email: "test@example.com", password: "securepassword")
    assert user.valid?, "User should be valid with nil password_confirmation"
  end
end
