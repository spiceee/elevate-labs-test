# 🧘🏽 Elevate Labs Take-home Assignment 🧘🏻‍♂️

This repo tries to solve the requirements of the backend take-home assignment, which is a multi-step task, divided in phases, each phase has a specific deliverable.

You can use the [integration tests](https://github.com/spiceee/elevate-labs-test/tree/main/test/integration) as both the specification and proof of completion for every phase mentioned in the assignment.

* Ruby version
3.3.5 (per request)

## Assumptions

I've added comments colocated to their respective files/callsites.
I've mostly assumed this API to be a RESTful API with a hybrid stateless/stateful architecture.

That means the client gets a cookie that can be used to identify the user across requests.
It also receives a bearer token that it can use in the header to authenticate each request independently.

This stemmed from the assignment requirement that a session would start after a user signs on. A session implies a stateful experience, hence the need for cookie support.

However, there's also a mention of a token as the payload for a successful sign-on, which implies that the client could also authenticate with a token via header authentication.

I'm not sure this architecture decision was part of the assignment. It could also be that mention to http sessions are, abeit wrongly, used to infer that the API flow should start with a valid credential handshake. Who knows?

I've assumed there is a remote billing gateway service that holds the user's billing and subscription status.
User subscription statuses are calculated every 24 hours, and the API needs to be in sync with this as much as possible, or at least that's what I assumed from this specific info drop 💣.

## Caveats

There are several caveats with this assignment and they stem from the following asks not being formalized in a proper specification:

1. The assignment requirement that a session would start after a user signs on. A session implies a stateful experience, hence the need for cookie support.
2. The mention of a token (JWT? Static? Has TTL?) as the payload for a successful sign-on, which implies that the client could also authenticate with a token via header authentication.
3. Why game_events should only take "COMPLETED" as a status? What is the real business case for this?
4. The assumption that user subscription statuses are calculated every 24 hours, and the API needs to be in sync with this as much as possible.
5. What about the mention some user_ids will 404 with the billing gateway? What is the real business case for this?

This could have never been a task assigned to me via a Jira ticket. This needs serious requirement gathering.

Finally, this is not a _"an evening of your time to complete"_ assignment, as mentioned in the task description AND the screening interview. This is a **SOLID** 5 to 8 Jira ticket. I'm not sure if playing this down to a 3 to 4 hours is part of the assignment. Don't rush this. _Take your time_!

## Tests
I really don't care too much about Minitest and would have used RSpec instead.
However, I had to force myself to use whatever Rails 8 ships as the default for tests and everything else.

Run `bundle install` to install the required gems.
Run `bin/rails db:test:prepare test`

```bash
bundle install
bin/rails db:test:prepare test
```

There is an ongoing issue with `simplecov` and how Rails 8 parallelizes tests so in order to get a consolidated report, you need to run the tests with:

```bash
rm -rf coverage/ && DISABLE_SPRING=1 COVERAGE=1 bin/rails test
```
