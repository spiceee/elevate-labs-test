module Authentication
  include ActionController::HttpAuthentication::Token::ControllerMethods
  extend ActiveSupport::Concern
  class InvalidApiToken < StandardError; end

  included do
    rescue_from Authentication::InvalidApiToken, with: :sign_out_as_unauthorized

    # the assignment doesn't mention what should be the auth methods between client and API!
    # it does mention the concept of a session, hence attaching a stateful session to a client cookie is supported.
    # but the assignment also mentions a token payload should be in the response to /api/sessions so a Bearer token
    # stateless behavior is also supported.
    def authenticate_user!
      signed_in? || login_with_api_token!
    end

    def login_with_api_token!
      token = authenticate_with_http_token { |token| ApiToken.find_by_token(token) }
      raise Authentication::InvalidApiToken if !token

      session[:user_id] = token.user_id
    end

    def signed_in?
      session[:user_id].present?
    end

    def sign_out_as_unauthorized
      reset_session
      render status: :unauthorized, json: {error: "Invalid credentials"}
    end

    def current_user
      @current_user ||= User.find(session[:user_id])
    end
  end
end
