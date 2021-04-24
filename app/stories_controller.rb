require_relative "story"

class StoriesController < Sinatra::Base
  helpers do
    def find_story(id)
      story_repo.read(id.to_i) or not_found "Not found"
    end

    def story_repo
      @story_repo ||= Repository.new(Story)
    end

    def story_params
      params.slice("text", "title", "url")
    end
  end

  get "/" do
    stories = story_repo.list
    JSON.generate(stories: stories)
  end

  post "/" do
    story = story_repo.create(**story_params)
    JSON.generate(story.attrs)
  end

  get "/:id" do
    story = find_story(params[:id])
    JSON.generate(story.attrs)
  end

  put "/:id" do
    story = find_story(params[:id])
    story.assign_attrs(story_params)
    story_repo.update(story)

    JSON.generate(story.attrs)
  end

  delete "/:id" do
    story = find_story(params[:id])
    story_repo.delete(story)

    JSON.generate(story.attrs)
  end
end
