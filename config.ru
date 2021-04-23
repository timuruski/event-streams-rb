require_relative "lib/app"

EventStore.new("./events.yml") do |store|
  store.dump_at_exit
  store.load
end

run App.new
