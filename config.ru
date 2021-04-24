require_relative "lib/app"

# Persist event stream between runs
EventStore.new("./events.yml", event_bus: EventBus.default)

run App.new
