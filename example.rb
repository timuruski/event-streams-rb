require_relative "lib/ansi"
require_relative "lib/events"

at_exit do
  event_bus = EventBus.new

  all_events = EventStream.new(event_bus)
  alice_events = EventStream.new(event_bus, topic: "alice")
  bob_events = EventStream.new(event_bus, topic: "bob")

  all_events.publish Event.new("Start of scene")

  alice_events.publish Event.new("Alice enters")
  bob_events.publish Event.new("Bob enters")
  alice_events.publish Event.new("Alice greets Bob"), include_topic: "bob"
  bob_events.publish Event.new("Bob leaves")
  alice_events.publish Event.new("Alice leaves")

  handler_a = EventHandler.new { |event| puts Ansi["A: #{event.data}", :fg_red] }
  handler_b = EventHandler.new { |event| puts Ansi["B: #{event.data}", :fg_green] }
  handler_c = EventHandler.new { |event| puts Ansi["C: #{event.data}", :fg_blue] }

  alice_events.subscribe!(handler_a)
  bob_events.subscribe!(handler_b)
  all_events.subscribe!(handler_c)

  all_events.publish Event.new("End of scene")
end
