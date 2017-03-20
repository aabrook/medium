defmodule DistanceTracker.Controller do
  use DistanceTracker.Web, :controller

  alias DistanceTracker
  alias Phoenix.Controller
  alias Plug.Conn

  def index(conn, _params) do

    render(conn, "index.json")
  end
end
