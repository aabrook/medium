defmodule DistanceTracker.Controller do
  use DistanceTracker.Web, :controller

  alias DistanceTracker
  alias Phoenix.Controller
  alias Plug.Conn

  def index(conn, _params) do
    trackings =
      DistanceTracker.DistanceTracker
      |> Repo.all
    render(conn, "index.json", trackings: trackings)
  end
end
