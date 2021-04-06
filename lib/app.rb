require "bundler/setup"
require "json"
require "sinatra"
require "pry"
require "sinatra/reloader" if development?

require_relative "events"
require_relative "user"

class App < Sinatra::Application
  helpers do
    def find_user(id)
      user_repo.read(id.to_i) or not_found "Not found"
    end

    def user_repo
      @user_repo ||= Repository.new(User)
    end
  end

  post "/users" do
    user = user_repo.create(**params.slice("name", "email"))
    JSON.generate(user.attrs)
  end

  get "/users/:id" do
    user = find_user(params[:id])
    JSON.generate(user.attrs)
  end

  put "/users/:id" do
    user = find_user(params[:id])
    user.assign_attrs(params.slice("name", "email"))
    user_repo.update(user)

    JSON.generate(user.attrs)
  end

  delete "/users/:id" do
    user = find_user(params[:id])
    user_repo.delete(user)

    JSON.generate(user.attrs)
  end
end
