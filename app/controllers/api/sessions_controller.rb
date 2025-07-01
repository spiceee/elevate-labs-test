class Api::SessionsController < ApplicationController
  before_action :authenticate_user!, except: :create

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      render status: :created, json: {token: user.token}
    else
      render status: :unauthorized, json: {error: "Invalid email or password"}
    end
  end

  # logout
  def destroy
    reset_session
    head :no_content
  end
end
