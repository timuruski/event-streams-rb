require "securerandom"

class Event
  attr_reader :data, :id, :type

  def initialize(data = nil, type: nil, id: nil)
    @id = id || SecureRandom.uuid
    @data = data
    @type = type
  end

  def to_h
    {"id" => @id, "data" => @data.to_yaml, "type" => @type}
  end

  def to_s
    @data.to_s
  end

  def to_yaml
    to_h.to_yaml
  end
end
