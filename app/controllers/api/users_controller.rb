class Api::UsersController < ApplicationController
  before_action :authenticate_user!, only: :show
  before_action :check_subscription_status, only: :show

  def create
    @user = User.new(email: params[:email], password: params[:password])

    if @user.save
      render json: {success: true}, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def show
    @stats = {
      user: {
        id: current_user.id,
        email: current_user.email,
        stats: {
          total_games_played: 5
        },
        subscription_status: current_user.subscription.active? ? "active" : "expired" # this is an oversimplification as per business logic there are more states like pending, cancelled etc.
      }
    }

    render json: @stats, status: :ok
  end

  private

  def check_subscription_status
    # TBD: does this _possible_ external call to the billing gateway needs to be blocking the #show response?
    # What are the tradeoffs to a faster response in this stats-grabbing action? How accurate the subscription status need to be at this view level? Is it OK to serve a mildly stale status? :shrug:
    if current_user.subscription.needs_status_refresh?
      current_user.subscription.check_status_in_gateway
    end
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.expect(:email, :password)
  end
end
