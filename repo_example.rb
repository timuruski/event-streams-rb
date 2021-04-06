require_relative "lib/ansi"
require_relative "lib/events"
require 'pry'

# event_bus = EventBus.new

class User < Struct.new(:id, :email, :name, keyword_init: true)
  alias_method :attrs, :to_h
end

user_repo = Repository.new(User)

alice = user_repo.create(name: "Alice", email: "alice@example.org")
bob = user_repo.create(name: "Bob", email: "bob@example.org")
charlie = user_repo.create(name: "Charlie", email: "charlie@example.org")


other_user_repo = Repository.new(User)
other_alice = other_user_repo.read(alice.id)
darlene = other_user_repo.create(name: "Darlene", email: "darlene@example.orb")

puts alice.email
puts other_alice.email

other_alice.email = "alice@hey.com"
user_repo.update(other_alice)

puts user_repo.read(alice.id).email
