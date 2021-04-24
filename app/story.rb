class Story < Struct.new(:id, :text, :title, :url, keyword_init: true)
  alias_method :attrs, :to_h

  def assign_attrs(attrs)
    attrs.slice(*members).each do |key, value|
      self[key] = value
    end

    self
  end
end
