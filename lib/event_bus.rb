class EventBus
  def initialize
    @published_events = {}
    @ordered_events = []
    @listeners = []
  end

  def subscribe(listener)
    @listeners << listener
  end

  def unsubscribe(listener)
    @listeners.delete(listener)
  end

  def publish(event, topics:)
    return event if @published_events.key?(event.id)

    @published_events[event.id] = @ordered_events.length
    @ordered_events << [event, topics]

    topics.each do |topic|
      @listeners.each do |listener|
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
