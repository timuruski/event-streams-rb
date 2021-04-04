class Event
  ID_GENERATOR = (1..).each

  attr_reader :data, :id, :type

  def initialize(data = nil, type: nil)
    @id = Event::ID_GENERATOR.next
    @data = data
    @type = type
  end

  def to_s
    @data.to_s
  end
end
