require_relative "lib/ansi"
require_relative "lib/events"

event_bus = EventBus.new

all_events = EventStream.new(event_bus)
person_events = EventStream.new(event_bus, topic: "person:*")
alice_events = EventStream.new(event_bus, topic: "person:alice")
bob_events = EventStream.new(event_bus, topic: "person:bob")

event_bus.publish(Event.new("Start of scene"), topic: "scene")

event_bus.publish(Event.new("Alice enters"), topic: "person:alice")
event_bus.publish(Event.new("Bob enters"), topic: "person:bob")
event_bus.publish(Event.new("Alice greets Bob"), topic: ["person:alice", "person:bob"])
event_bus.publish(Event.new("Midpoint of the scene"), topic: "scene")
event_bus.publish(Event.new("Alice leaves"), topic: "person:alice")
event_bus.publish(Event.new("Bob leaves"), topic: "person:bob")

handler_a = EventHandler.new { |event| puts Ansi["A: #{event.data}", :fg_red] }
handler_b = EventHandler.new { |event| puts Ansi["B: #{event.data}", :fg_green] }
handler_c = EventHandler.new { |event| puts Ansi["C: #{event.data}", :fg_blue] }
handler_d = EventHandler.new { |event| puts Ansi["D: #{event.data}"] }

alice_events.subscribe!(handler_a)
bob_events.subscribe!(handler_b)
person_events.subscribe!(handler_c)
all_events.subscribe!(handler_d)

event_bus.publish(Event.new("End of scene"), topic: "scene")
