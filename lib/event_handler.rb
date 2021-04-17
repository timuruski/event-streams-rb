module EventHandler
  def receive(event)
    # TODO Translate event type to a valid method name.
    handler_method = :"on_#{event.type}"

    if respond_to?(handler_method)
      self.send(handler_method, event)
    elsif respond_to?(:on_unhandled)
      self.send(:on_unhandled, event)
    end
  end
end
