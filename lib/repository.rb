class Repository
  include EventHandler

  attr_reader :stream

  def initialize(record_class, event_bus: EventBus.default)
    @max_id = 0

    @record_class = record_class
    @records = {}

    @stream = EventStream.new(event_bus, topic: record_class.name)
    @stream.subscribe(self)
  end

  def read(record_id)
    if attrs = @records[record_id]
      @record_class.new(**attrs)
    end
  end

  def create(**attrs)
    record = @record_class.new(**attrs, id: @max_id + 1)

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

    @max_id = record_id if record_id > @max_id
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
