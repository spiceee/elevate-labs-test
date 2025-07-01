# == Schema Information
#
# Table name: game_events
#
#  id          :integer          not null, primary key
#  game_name   :string
#  kind        :integer          default(0)
#  occurred_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_game_events_on_game_name  (game_name)
#  index_game_events_on_user_id    (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class GameEvent < ApplicationRecord
  belongs_to :user
  before_save :convert_type_to_int

  # <<type>> is not a great attribute name to anything inheriting from ActiveRecord::Base
  # so GameEvent uses event_type internally since <<type>> is what the API contract uses in client submissions
  attr_accessor :event_type

  # depending on the db storage solution, we could use native enum support and bypass this map.
  EVENT_TYPE_TO_KIND = {
    ONGOING: 0,
    COMPLETED: 1,
    CANCELLED: 2
  }.freeze

  private

  def convert_type_to_int
    if event_type.present? && EVENT_TYPE_TO_KIND.key?(event_type.to_sym)
      self.kind = EVENT_TYPE_TO_KIND[event_type.to_sym]
    end
  end
end
