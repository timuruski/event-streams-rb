require "yaml/store"

class EventStore
  def initialize(path, event_bus: nil)
    @event_bus = event_bus || EventBus.default
    @store = YAML::Store.new(path)

    # Load events before tapping to avoid recursion
    @store.transaction do
      @store.roots.each do |topic|
        @store[topic].each do |event|
          @event_bus.publish(event, topic: topic)
        end
      end
    end

    # Persist events as they are published
    @event_bus.tap_events do |topic, event|
      @store.transaction do
        @store[topic] ||= []
        @store[topic] << event
      end
    end
  end
end
