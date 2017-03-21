defmodule DistanceTracker.Router do
  use DistanceTracker.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DistanceTracker do
    pipe_through :api# Use the default browser stack

    get "/", Controller, :index
    get "/:uuid", Controller, :show
    post "/", Controller, :create
    delete "/:uuid", Controller, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", DistanceTracker do
  #   pipe_through :api
  # end
end
