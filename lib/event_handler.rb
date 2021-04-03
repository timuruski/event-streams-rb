class EventHandler
  def initialize(&block)
    @handler = block
  end

  def handle(event)
    @handler.call(event)
  end
end
