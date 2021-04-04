class SimpleHandler
  def initialize(&block)
    @handler = block
  end

  def receive(event)
    @handler.call(event)
  end
end
