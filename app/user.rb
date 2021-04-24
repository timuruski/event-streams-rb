class User < Struct.new(:id, :email, :name, keyword_init: true)
  ATTRS = ["name", "email"]

  alias_method :attrs, :to_h

  def assign_attrs(attrs)
    attrs.slice(*members).each do |key, value|
      self[key] = value
    end

    self
  end
end
