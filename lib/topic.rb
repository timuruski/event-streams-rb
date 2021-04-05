class Topic
  attr_reader :name

  def initialize(name)
    @listeners = []
    @name = name
    @ordered_events = []
    @published_events = {}
  end

  def subscribe(listener)
    @listeners << listener
  end

  def unsubscribe(listener)
    @listeners.delete(listener)
  end

  def publish(event)
    # TODO What to return if event is already published?
    return if published?(event)

    @published_events[event.id] = @ordered_events.length
    @ordered_events << event

    @listeners.each do |listener|
      listener.deliver(event)
    end

    event
  end

  def published?(event)
    @published_events.key?(event.id)
  end

  def each(last_event: nil)
    starting_index = last_event ? @published_events[last_event.id] + 1 : 0
    @ordered_events.slice(starting_index..).each do |event|
      yield event, name
    end
  end
end
