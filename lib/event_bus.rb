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
