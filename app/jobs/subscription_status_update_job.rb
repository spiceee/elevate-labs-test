class SubscriptionStatusUpdateJob < ApplicationJob
  queue_as :default

  # This is kinda crass and inefficient but added just to show I understood that there is a need to check the statuses of
  # subscriptions in a remote gateway that is recalculated every 24 hours.
  # Better ways to do this would be to check on other columns or actions that could trigger that for a given user that has
  # become active in the system there is the need to have a sub status refresh.
  # This way, we would only execute jobs for a cohort of active users.
  def perform(*args)
    Subscription.where("last_checked_at > ?", 24.hours.ago).find_each do |subscription|
      subscription.check_status_in_gateway
    end
  end
end
