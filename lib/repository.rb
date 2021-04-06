class Repository
  include EventHandler

  attr_reader :stream

  def initialize(record_class, event_bus: EventBus.default)
    @record_class = record_class
    @records = {}

    @stream = EventStream.new(event_bus, topic: record_class.name)
    @stream.subscribe(self)

    # TODO Read this on create
    max_id = @records.keys.max.to_i + 1
    @id_sequence = (max_id...).each
  end

  def read(record_id)
    if attrs = @records[record_id]
      @record_class.new(**attrs)
    end
  end

  def create(**attrs)
    record = @record_class.new(**attrs, id: @id_sequence.next)

    create_event = Event.new(record.attrs, type: "create")
    @stream.publish(create_event)

    record
  end

  def update(record)
    update_event = Event.new(record.attrs, type: "update")
    @stream.publish(update_event)

    record
  end

  def delete(record)
    delete_event = Event.new({id: record.id}, type: "delete")
    @stream.publish(delete_event)

    record
  end

  def on_create(event)
    record_id = event.data[:id]
    @records[record_id] = event.data
  end

  def on_update(event)
    record_id = event.data[:id]
    @records[record_id] = event.data
  end

  def on_delete(event)
    record_id = event.data[:id]
    @records[record_id] = nil
  end
end
