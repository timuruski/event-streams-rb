class Repository
  include EventHandler

  attr_reader :stream

  def initialize(record_class, event_bus: EventBus.default)
    @max_id = 0

    @records = {}
    @record_class = record_class

    @record_type = record_class.name.downcase
    define_singleton_method(:"on_created_#{@record_type}", method(:_on_created))
    define_singleton_method(:"on_updated_#{@record_type}", method(:_on_updated))
    define_singleton_method(:"on_deleted_#{@record_type}", method(:_on_deleted))

    @stream = EventStream.new(event_bus, topic: record_class.name)
    @stream.subscribe(self)
  end

  def list
    @records.values
  end

  def read(record_id)
    if attrs = @records[record_id]
      @record_class.new(**attrs)
    end
  end

  def create(attrs)
    record = @record_class.new(**attrs, id: @max_id + 1)

    create_event = Event.new(record.attrs, type: "created_#{@record_type}")
    @stream.publish(create_event)

    record
  end

  def update(record)
    update_event = Event.new(record.attrs, type: "updated_#{@record_type}")
    @stream.publish(update_event)

    record
  end

  def delete(record)
    delete_event = Event.new({id: record.id}, type: "deleted_#{@record_type}")
    @stream.publish(delete_event)

    record
  end

  def _on_created(event)
    record_id = event.data[:id]
    @records[record_id] = event.data

    @max_id = record_id if record_id > @max_id
  end

  def _on_updated(event)
    record_id = event.data[:id]
    @records[record_id] = event.data
  end

  def _on_deleted(event)
    record_id = event.data[:id]
    @records.delete(record_id)
  end
end
