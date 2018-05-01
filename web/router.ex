defmodule DistanceTracker.Router do
  use DistanceTracker.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  forward("/graphql", Absinthe.Plug, schema: DistanceTracker.Schema)
  if Mix.env == :dev do
    forward "/graphiql",
    Absinthe.Plug.GraphiQL,
    schema: DistanceTracker.Schema
  end

  scope "/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :distance_tracker,
      swagger_file: "swagger.json",
      disable_validator: true
  end

  scope "/", DistanceTracker do
    pipe_through :api

    get "/", TrackerController, :index
    get "/:id", TrackerController, :show
    post "/", TrackerController, :create
    patch "/:id", TrackerController, :update
    delete "/:id", TrackerController, :delete
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Distance Tracker"
      }
    }
  end
end
