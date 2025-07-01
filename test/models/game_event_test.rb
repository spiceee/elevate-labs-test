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
require "test_helper"

class GameEventTest < ActiveSupport::TestCase
  test "should save a converted type value to its proper db value" do
    game_event = GameEvent.new(game_name: "Test Game", event_type: "COMPLETED", occurred_at: Time.now, user_id: users(:one).id)

    assert game_event.save
    assert_equal GameEvent::EVENT_TYPE_TO_KIND[:COMPLETED], game_event.kind
  end

  test "should leave type/kind as is if type is not valid" do
    game_event = GameEvent.new(game_name: "Test Game", event_type: "UNKNOWN", occurred_at: Time.now, user_id: users(:one).id)

    assert game_event.save
    assert_equal GameEvent::EVENT_TYPE_TO_KIND[:ONGOING], game_event.kind
  end
end
