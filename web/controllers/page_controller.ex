defmodule DistanceTracker.PageController do
  use DistanceTracker.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
