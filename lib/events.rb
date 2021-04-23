# NOTE None of this is thread-safe.
#
# Event -> Stream (topic) -> Bus -> Stream (topic) -> Subscription -> Handler
require "securerandom"
require "yaml"

$LOAD_PATH.unshift(__dir__)

autoload(:Event, "event")
autoload(:EventBus, "event_bus")
autoload(:EventHandler, "event_handler")
autoload(:EventStream, "event_stream")
autoload(:EventStore, "event_store")
autoload(:Repository, "repository")
autoload(:SimpleHandler, "simple_handler")
autoload(:Subscription, "subscription")
autoload(:Topic, "topic")
