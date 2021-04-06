require_relative "lib/ansi"
require_relative "lib/events"

simple_play = EventStream.new(EventBus.default, topic: "simple_play")

simple_play.publish(Event.new("Start of scene"))
simple_play.publish(Event.new("Alice enters"))
bob_enters = simple_play.publish(Event.new("Bob enters"))
simple_play.publish(Event.new("Alice greets Bob"))
simple_play.publish(Event.new("Midpoint of the scene"))

handler_a = SimpleHandler.new { |event| puts Ansi["A: #{event.data}", :fg_red] }
handler_b = SimpleHandler.new { |event| puts Ansi["B: #{event.data}", :fg_green] }
handler_c = SimpleHandler.new { |event| puts Ansi["C: #{event.data}", :fg_blue] }

simple_play.subscribe!(handler_a)
simple_play.subscribe(handler_b)
simple_play.subscribe(handler_c, last_event: bob_enters)

simple_play.publish(Event.new("Alice leaves"))
simple_play.publish(Event.new("Bob leaves"))
simple_play.publish(Event.new("End of scene"))
