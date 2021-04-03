# NOTE None of this is thread-safe.
#
# Topic -> Stream
# Subscription -> Handler + Topic

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

class Event
  ID_GENERATOR = (1..).each

  attr_reader :data, :id

  def initialize(data)
    @id = Event::ID_GENERATOR.next
    @data = data
  end

  def to_s
    @data.to_s
  end
end

class EventBus
  def initialize
    @published_events = {}
    @ordered_events = []
    @topics = {}
  end

  def subscribe(listener, topic: nil)
    @topics[topic] ||= []
    @topics[topic] << listener
  end

  def unsubscribe(listener)
    @topics.values.each do |listeners|
      listeners.delete(listener)
    end
  end

  def publish(event, topics:)
    return event if @published_events.key?(event.id)

    @published_events[event.id] = @ordered_events.length
    @ordered_events << [event, topics]

    # TODO Make "no-topic" a real concept
    topics = [nil] if topics.empty?

    topics.each do |topic|
      @topics[topic].each do |listener|
        listener.deliver(event, topic)
      end
    end

    event
  end

  def each
    @ordered_events.each do |event, topics|
      topics.each do |topic|
        yield event, topic
      end
    end
  end

  def each_after(last_event)
    starting_index = @published_events[last_event.id] + 1
    missing_events = @ordered_events.slice(starting_index..)
    missing_events.each do |event, topics|
      topics.each do |topic|
        yield event, topic
      end
    end
  end
end

class EventStream
  attr_reader :event_bus, :topic

  def initialize(event_bus, topic: nil)
    @event_bus = event_bus
    @subscriptions = []
    @topic = topic

    @event_bus.subscribe(self, topic: @topic)
  end

  def subscribe!(handler, last_event: nil)
    subscription = subscribe(handler)

    if last_event
      subscription.play_after(last_event)
    else
      subscription.play_all
    end
  end

  def subscribe(handler, last_event: nil)
    subscription = Subscription.new(handler: handler, stream: self)
    @subscriptions.push(subscription)

    subscription
  end

  def unsubscribe(subscription)
    @subscriptions.delete(subscription)
  end

  def publish_each(*events, topic: nil)
    events.each do |event|
      publish(event, topic: topic)
    end
  end

  def publish(event, topic: nil)
    all_topics = [*@topic, *topic]
    @event_bus.publish(event, topics: all_topics)

    event
  end

  def each
    @event_bus.each do |event, topic|
      yield event if @topic.nil? || topic == @topic
    end
  end

  def each_after(last_event)
    @event_bus.each_after(last_event) do |event, topic|
      yield event if @topic.nil? || topic == @topic
    end
  end

  def deliver(event, topic)
    return unless topic == @topic

    @subscriptions.each do |subscription|
      subscription.deliver(event)
    end
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

class EventHandler
  def initialize(&block)
    @handler = block
  end

  def handle(event)
    @handler.call(event)
  end
end

