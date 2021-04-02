# NOTE None of this is thread-safe.
#
# Topic -> Stream
# Subscription -> Handler + Topic

at_exit do
  handler_a = EventHandler.new { |event| puts "A: #{event.data}" }
  handler_b = EventHandler.new { |event| puts "B: #{event.data}" }

  stream = EventStream.new
  stream.subscribe(handler_a)

  alice_enters = Event.new("Alice enters")
  bob_enters = Event.new("Bob enters")
  bob_leaves = Event.new("Bob leaves")
  alice_leaves = Event.new("Alice leaves")

  stream.publish_each(alice_enters, bob_enters, bob_leaves, alice_leaves)

  stream.subscribe(handler_b, last_event: bob_enters)
end

class EventStream
  def initialize
    @handlers = []
    @published_events = {}
    @ordered_events = []
  end

  def publish_each(*events)
    events.each do |event|
      publish(event)
    end
  end

  def publish(event)
    @published_events[event.id] = @ordered_events.length
    @ordered_events.push(event)

    @handlers.each do |handler|
      handler.handle(event)
    end

    event
  end

  def subscribe(handler, last_event: nil)
    @handlers.push(handler)

    if last_event
      starting_index = @published_events[last_event.id] + 1
      missing_events = @ordered_events.slice(starting_index..).to_a

      missing_events.each do |event|
        handler.handle(event)
      end
    end
  end
end

class Event
  ID_GENERATOR = (1..).each

  attr_reader :data, :id

  def initialize(data)
    @id = Event::ID_GENERATOR.next
    @data = data
  end
end

class EventHandler
  def initialize(&block)
    @handler = block
  end

  def handle(event)
    @handler.call(event)
  end
end
