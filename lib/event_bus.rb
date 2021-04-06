class EventBus
  def self.default
    @default ||= new
  end

  def initialize
    @topics = {}
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

  def dump(topic:)
    with_topic(topic).to_a
  end

  private def with_topic(name)
    @topics[name] ||= Topic.new(name)
  end
end
