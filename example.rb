# NOTE None of this is thread-safe.
#
# Topic -> Stream
# Subscription -> Handler + Topic

require_relative "lib/events"

ANSI = {
  fg_red: "\e[38;5;1m",
  fg_blue: "\e[38;5;4m",
  fg_green: "\e[38;5;2m",
  bold: "\e[1m",
  reset: "\e[0m"
}

def ansi(str, *elements)
  elements.map(&ANSI).join("").concat(str, ANSI[:reset])
end

at_exit do
  event_bus = EventBus.new

  all_events = EventStream.new(event_bus)
  alice_events = EventStream.new(event_bus, topic: "alice")
  bob_events = EventStream.new(event_bus, topic: "bob")

  alice_greets_bob = Event.new("Alice greets Bob")
  alice_enters = Event.new("Alice enters")
  alice_leaves = Event.new("Alice leaves")
  bob_enters = Event.new("Bob enters")
  bob_leaves = Event.new("Bob leaves")

  alice_events.publish(alice_enters)
  bob_events.publish(bob_enters)
  alice_events.publish(alice_greets_bob, topic: "bob") # Two-topics
  bob_events.publish(bob_leaves)
  alice_events.publish(alice_leaves)

  handler_a = EventHandler.new { |event| puts ansi("A: #{event.data}", :fg_red) }
  handler_b = EventHandler.new { |event| puts ansi("B: #{event.data}", :fg_green) }
  handler_c = EventHandler.new { |event| puts ansi("C: #{event.data}", :fg_blue) }

  alice_events.subscribe!(handler_a)
  bob_events.subscribe!(handler_b)
  all_events.subscribe!(handler_c)

  all_events.publish Event.new("End of scene")
end
