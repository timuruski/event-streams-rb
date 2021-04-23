# TODO Use YAML::Store instead; write events immediately?
class EventStore
  def initialize(path, event_bus: EventBus.default)
    @path = path
    @event_bus = event_bus

    yield self if block_given?
  end

  # NOTE This is naive and leans on YAML coercing to instances of Event
  def load
    YAML.load(File.read(@path)).each do |topic, events|
      events.each do |event|
        @event_bus.publish(event, topic: topic)
      end
    end

    self
  end

  def dump_at_exit
    at_exit do
      # Don't dump on a crash; might be a bad idea.
      self.dump unless $!
    end

    self
  end

  def dump
    events = {}

    @event_bus.each do |event, topic|
      events[topic] ||= []
      events[topic] << event
    end

    File.write(@path, YAML.dump(events))

    self
  end
end
