require_relative "user"

class UsersController < Sinatra::Base
  helpers do
    def find_user(id)
      user_repo.read(id.to_i) or not_found "Not found"
    end

    def user_repo
      @user_repo ||= Repository.new(User)
    end

    def user_params
      params.slice("email", "name")
    end
  end

  get "/" do
    users = user_repo.list
    JSON.generate(users: users)
  end

  post "/" do
    user = user_repo.create(**user_params)
    JSON.generate(user.attrs)
  end

  get "/:id" do
    user = find_user(params[:id])
    JSON.generate(user.attrs)
  end

  put "/:id" do
    user = find_user(params[:id])
    user.assign_attrs(user_params)
    user_repo.update(user)

    JSON.generate(user.attrs)
  end

  delete "/:id" do
    user = find_user(params[:id])
    user_repo.delete(user)

    JSON.generate(user.attrs)
  end
end
