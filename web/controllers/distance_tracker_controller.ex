defmodule DistanceTracker.Controller do
  use DistanceTracker.Web, :controller

  alias Plug.Conn

  def index(conn, _params) do
    trackings =
      DistanceTracker.DistanceTracker
      |> DistanceTracker.Repo.all
    render(conn, "index.json", trackings: trackings)
  end

  def show(conn, %{"uuid" => uuid}) do
    with tracker = %DistanceTracker.DistanceTracker{} <- DistanceTracker.Repo.get(DistanceTracker.DistanceTracker, uuid) do
      render(conn, "show.json", tracking: tracker)
    else
      nil ->
        conn
        |> put_status(404)
        |> render(DistanceTracker.ErrorView, "404.json", error: "Not found")
    end
  end

  def create(conn, params) do
    {:ok, date, _} = DateTime.from_iso8601(params["completed_at"])
    params = %{params | "completed_at" => date}
    changeset = DistanceTracker.DistanceTracker.changeset(%DistanceTracker.DistanceTracker{}, params)

    with {:ok, tracking} <- DistanceTracker.Repo.insert(changeset) do
        conn
        |> Conn.put_status(201)
        |> render("show.json", tracking: tracking)
    else
      {:error, %{errors: errors}} ->
        conn
        |> put_status(422)
        |> render(DistanceTracker.ErrorView, "422.json", %{errors: errors})
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    with tracking = %DistanceTracker.DistanceTracker{} <- Repo.get(DistanceTracker.DistanceTracker, uuid) do
      DistanceTracker.Repo.delete!(tracking)

      conn
      |> Conn.put_status(204)
      |> Conn.send_resp(:no_content, "")
    else
      nil ->
        conn
        |> put_status(404)
        |> render(DistanceTracker.ErrorView, "404.json", error: "Not found")
    end
  end
end
