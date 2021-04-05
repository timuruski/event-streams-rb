class Repository
  include EventHandler

  ID_SEQUENCE = (1..).each

  def initialize(record_class, event_bus:)
    @record_class = record_class
    @records = {}

    stream_topic = record_class.name
    @stream = EventStream.new(event_bus, topic: stream_topic)
    @stream.subscribe(self)

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
    @records.delete(record_id)
  end
end
