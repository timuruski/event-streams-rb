class EventStream
  attr_reader :event_bus, :topic

  def initialize(event_bus, topic: nil)
    @event_bus = event_bus
    @subscriptions = []
    @topic = topic

    @event_bus.subscribe(self)
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
    # TODO Make "no topic" a real concept
    all_topics = [*@topic, *topic]
    all_topics = [nil] if all_topics.empty?

    @event_bus.publish(event, topics: all_topics)

    event
  end

  def deliver(event, topic)
    return unless topic == @topic

    @subscriptions.each do |subscription|
      subscription.deliver(event)
    end
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
end
