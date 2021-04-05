class EventBus
  def initialize
    @topics = {}
  end

  def create_topic(name)
    @topics[name] ||= Topic.new(name)
  end

  def subscribe(listener, topic:)
    with_topic(topic).subscribe(listener)
  end

  def unsubscribe(listener, topic:)
    with_topic(topic).unsubscribe(listener)
  end

  def publish_each(*events, topic:)
    events.each do |event|
      publish(event, topic: topic)
    end
  end

  def publish(event, topic:)
    with_topic(topic).publish(event)
  end

  def each(topic:, last_event: nil, &block)
    with_topic(topic).each(last_event: last_event, &block)
  end

  def topic?(name)
    @topics.key?(name)
  end

  private def with_topic(name)
    raise ArgumentError, "topic #{name} is not defined" unless topic?(name)

    @topics.fetch(name)
  end
end
