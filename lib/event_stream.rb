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

  def deliver(event, topic)
    return unless topic_match?(topic)

    @subscriptions.each do |subscription|
      subscription.deliver(event)
    end
  end

  # TODO Implement include_topic, and expansion
  def publish(event, topic:)
    @event_bus.publish(event, topic: topic)
  end

  def each
    @event_bus.each do |event, topic|
      yield event if topic_match?(topic)
    end
  end

  def each_after(last_event)
    @event_bus.each_after(last_event) do |event, topic|
      yield event if topic_match?(topic)
    end
  end

  private def topic_match?(topic)
    @topic.nil? || topic.start_with?(@topic.chomp("*"))
  end
end
