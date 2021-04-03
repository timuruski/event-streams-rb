class Event
  ID_GENERATOR = (1..).each

  attr_reader :data, :id

  def initialize(data)
    @id = Event::ID_GENERATOR.next
    @data = data
  end

  def to_s
    @data.to_s
  end
end
