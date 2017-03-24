defmodule DistanceTracker.TrackerController do
  use DistanceTracker.Web, :controller

  alias DistanceTracker.{Tracker, Repo, ErrorView}
  alias Plug.Conn

  def index(conn, _params) do
    trackers =
      Tracker
      |> DistanceTracker.Repo.all
    render(conn, "index.json", trackers: trackers)
  end

  def show(conn, %{"id" => uuid}) do
    with tracker = %Tracker{} <- Repo.get(Tracker, uuid) do
      render(conn, "show.json", tracker: tracker)
    else
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "404.json", error: "Not found")
    end
  end

  def create(conn, params) do
    {:ok, date, _} = DateTime.from_iso8601(params["completed_at"])
    params = %{params | "completed_at" => date}
    changeset = Tracker.changeset(%Tracker{}, params)

    with {:ok, tracker} <- Repo.insert(changeset) do
        conn
        |> Conn.put_status(201)
        |> render("show.json", tracker: tracker)
    else
      {:error, %{errors: errors}} ->
        conn
        |> put_status(422)
        |> render(ErrorView, "422.json", %{errors: errors})
    end
  end

  def delete(conn, %{"id" => uuid}) do
    with tracker = %Tracker{} <- Repo.get(Tracker, uuid) do
      Repo.delete!(tracker)

      conn
      |> Conn.put_status(204)
      |> Conn.send_resp(:no_content, "")
    else
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "404.json", error: "Not found")
    end
  end
end
