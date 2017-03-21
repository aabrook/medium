defmodule DistanceTracker.Controller do
  use DistanceTracker.Web, :controller

  def index(conn, _params) do
    trackings =
      DistanceTracker.DistanceTracker
      |> DistanceTracker.Repo.all
    render(conn, "index.json", trackings: trackings)
  end

  def show(conn, %{"uuid" => uuid}) do
    with {:ok, tracker} <- IO.inspect(DistanceTracker.Repo.get(DistanceTracker.DistanceTracker, uuid)) do
      render(conn, "500.json", "Nope!")
    else
      {:error, errors} ->
        render(conn, "500.json", %{errors: errors})
      nil ->
        render(conn, DistanceTracker.ErrorView, "404.json", %{error: "Not found"})
    end
  end

  def create(conn, params) do
  end

  def delete(conn, params) do
  end
end
