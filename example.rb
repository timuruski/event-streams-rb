# NOTE None of this is thread-safe.
#
# Topic -> Stream
# Subscription -> Handler + Topic

at_exit do
  alice_greets_bob = Event.new("Alice greets Bob")
  alice_enters = Event.new("Alice enters")
  alice_leaves = Event.new("Alice leaves")
  bob_enters = Event.new("Bob enters")
  bob_leaves = Event.new("Bob leaves")

  stream = EventStream.new
  stream.publish_each(alice_enters, bob_enters)

  handler_a = EventHandler.new { |event| puts "A: #{event.data}" }
  handler_b = EventHandler.new { |event| puts "B: #{event.data}" }
  handler_c = EventHandler.new { |event| puts "C: #{event.data}" }

  stream.subscribe!(handler_a, last_event: nil)
  stream.subscribe!(handler_b, last_event: alice_enters).unsubscribe
  stream.subscribe!(handler_c)

  stream.publish_each(alice_greets_bob, bob_leaves, alice_leaves)
  stream.publish Event.new("End of scene")
end

class EventStream
  def initialize
    @subscriptions = []
    @published_events = {}
    @ordered_events = []
  end

  def subscribe(handler, last_event: nil)
    subscription = Subscription.new(stream: self, handler: handler)
    @subscriptions.push(subscription)

    subscription
  end

  def unsubscribe(subscription)
    @subscriptions.delete(subscription)
  end

  def subscribe!(handler, last_event: nil)
    subscription = subscribe(handler)

    if last_event
      subscription.play_after(last_event)
    else
      subscription.play_all
    end
  end

  def publish_each(*events)
    events.each do |event|
      publish(event)
    end
  end

  def publish(event)
    @published_events[event.id] = @ordered_events.length
    @ordered_events.push(event)

    @subscriptions.each do |subscription|
      subscription.deliver(event)
    end

    event
  end

  def each
    @ordered_events.each do |event|
      yield event
    end
  end

  def each_after(last_event)
    starting_index = @published_events[last_event.id] + 1
    missing_events = @ordered_events.slice(starting_index..)
    missing_events.each do |event|
      yield event
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

class Subscription
  attr_reader :handler, :stream

  def initialize(handler:, stream:)
    @handler = handler
    @stream = stream
  end

  def deliver(event)
    @handler.handle(event)

    self
  end

  def play_after(last_event)
    @stream.each_after(last_event) do |event|
      deliver(event)
    end

    self
  end

  def play_all
    @stream.each do |event|
      deliver(event)
    end

    self
  end

  def unsubscribe
    @stream.unsubscribe(self)
  end
end
