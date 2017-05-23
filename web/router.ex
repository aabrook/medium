defmodule DistanceTracker.Router do
  use DistanceTracker.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DistanceTracker do
    pipe_through :api

    get "/", TrackerController, :index
    get "/:id", TrackerController, :show
    post "/", TrackerController, :create
    patch "/:id", TrackerController, :update
    delete "/:id", TrackerController, :delete
  end
end
