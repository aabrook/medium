defmodule DistanceTracker.Router do
  use DistanceTracker.Web, :router

  pipeline :browser do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DistanceTracker do
    pipe_through :browser # Use the default browser stack

    get "/", Controller, :index
    get "/:uuid", Controller, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", DistanceTracker do
  #   pipe_through :api
  # end
end
