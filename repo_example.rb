require_relative "lib/ansi"
require_relative "lib/events"

event_bus = EventBus.new

class User < Struct.new(:id, :email, :name, keyword_init: true)
  alias_method :attrs, :to_h
end

user_repo = Repository.new(User, event_bus: event_bus)

alice = user_repo.create(name: "Alice", email: "alice@example.org")
other_alice = user_repo.read(alice.id)

other_alice.email = "alice@hey.com"
user_repo.update(other_alice)

puts alice.email
puts other_alice.email

puts user_repo.read(alice.id).email
