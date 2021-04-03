class Subscription
  attr_reader :handler, :stream

  def initialize(handler:, stream:)
    @delivered_events = {}
    @handler = handler
    @stream = stream
  end

  def deliver(event)
    return self if @delivered_events.key?(event.id)

    @delivered_events[event.id] = event
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
