defmodule DistanceTracker.Controller do
  use DistanceTracker.Web, :controller

  def index(conn, _params) do
    trackings =
      DistanceTracker.DistanceTracker
      |> DistanceTracker.Repo.all
    render(conn, "index.json", trackings: trackings)
  end
end
