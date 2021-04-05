class Event
  attr_reader :data, :id, :type

  def initialize(data = nil, type: nil)
    @id = SecureRandom.uuid
    @data = data
    @type = type
  end

  def to_s
    @data.to_s
  end
end
