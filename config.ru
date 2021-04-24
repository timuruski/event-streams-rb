require "json"

require "bundler/setup"
require "pry"
require "sinatra"
require "sinatra/reloader" if development?

require_relative "lib/events"
require_relative "app/users_controller"
require_relative "app/stories_controller"

# Persist event stream between runs
EventStore.new("./events.yml", event_bus: EventBus.default)

map("/users") { run UsersController }
map("/stories") { run StoriesController }
# run App.new
