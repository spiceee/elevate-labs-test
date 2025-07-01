module Api
  module User
    class GameEventsController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_completed_status, only: :create
      before_action :fix_params, only: :create

      def create
        game_event = current_user.game_events.build(game_event_params)
        if game_event.save
          render json: game_event, status: :created
        else
          render json: game_event.errors, status: :unprocessable_entity
        end
      end

      private

      def ensure_completed_status
        return if params.dig(:game_event, :type) == "COMPLETED"

        render json: {error: "Only type 'COMPLETED' is allowed."},
          status: :unprocessable_entity
      end

      def game_event_params
        params.expect(game_event: [:game_name, :type, :event_type, :occurred_at])
      end

      # type is not a great attribute name to anything inheriting from ActiveRecord::Base
      # so GameEvent uses event_type internally
      def fix_params
        if params[:game_event][:type].present?
          params[:game_event][:event_type] = params[:game_event][:type]
          params[:game_event].delete(:type)
        end
      end
    end
  end
end
