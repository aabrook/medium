defmodule DistanceTracker.TrackerController do
  use DistanceTracker.Web, :controller
  use PhoenixSwagger

  alias DistanceTracker.{Tracker, Repo, ErrorView}
  alias Plug.Conn

  def swagger_definitions do
    %{
      Tracker: swagger_schema do
        title "Tracker"
        description "An activity which has been recorded"
        properties do
          uuid :string, "The ID of the activity"
          activity :string, "The activity recorded", required: true
          distance :integer, "How far travelled", required: true
          completed_at :string, "When was the activity completed", format: "ISO-8601"
          inserted_at :string, "When was the activity initially inserted", format: "ISO-8601"
          updated_at :string, "When was the activity last updated", format: "ISO-8601"
        end
        example %{
          completed_at: "2017-03-21T14:00:00Z",
          activity: "climbing",
          distance: 150
        }
      end,
      Trackers: swagger_schema do
        title "Trackers"
        description "All activities that have been recorded"
        type :array
        items Schema.ref(:Tracker)
      end,
      Error: swagger_schema do
        title "Errors"
        description "Error responses from the API"
        properties do
          error :string, "The message of the error raised", required: true
        end
      end
    }
  end

  swagger_path :index do
    get "/"
    summary "List all recorded activities"
    description "List all recorded activities"
    response 200, "Ok", Schema.ref(:Trackers)
  end
  def index(conn, _params) do
    trackers =
      Tracker
      |> DistanceTracker.Repo.all
    render(conn, "index.json", trackers: trackers)
  end

  swagger_path :show do
    get "/{id}"
    summary "Retrieve an activity"
    description "Retrieve an activity that you have recorded"
    parameters do
      id :path, :string, "The uuid of the activity", required: true
    end
    response 200, "Ok", Schema.ref(:Tracker)
    response 404, "Not found", Schema.ref(:Error)
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

  swagger_path :create do
    post "/"
    summary "Add a new activity"
    description "Record a new activity which has been completed"
    parameters do
      tracker :body, Schema.ref(:Tracker), "Activity to record", required: true
    end
    response 201, "Ok", Schema.ref(:Tracker)
    response 422, "Unprocessable Entity", Schema.ref(:Error)
  end
  def create(conn, params) do
    date = parse_date(params["completed_at"])
    params = Map.put(params, "completed_at", date)
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

  swagger_path :update do
    patch "/{id}"
    summary "Update an existing activity"
    description "Record changes to a completed activity"
    parameters do
      id :path, :string, "The uuid of the activity", required: true
      tracker :body, Schema.ref(:Tracker), "The activity details to update"
    end
    response 201, "Ok", Schema.ref(:Tracker)
    response 422, "Unprocessable Entity", Schema.ref(:Error)
  end
  def update(conn, params = %{"id" => uuid}) do
    with tracker = %Tracker{} <- Repo.get(Tracker, uuid),
      changeset = Tracker.changeset(tracker, params),
      {:ok, updated} <- Repo.update(changeset) do
        conn
        |> Conn.put_status(201)
        |> render("show.json", tracker: updated)
    else
      nil ->
        conn
        |> put_status(422)
        |> render(ErrorView, "422.json", %{errors: ["Failed to find record"]})
      {:error, %{errors: errors}} ->
        conn
        |> put_status(422)
        |> render(ErrorView, "422.json", %{errors: errors})
    end
  end

  swagger_path :delete do
    delete "/{id}"
    summary "Delete an activity"
    description "Remove an activity from the system"
    parameters do
      id :path, :string, "The uuid of the activity", required: true
    end
    response 204, "No content"
    response 404, "Not found", Schema.ref(:Error)
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

  defp parse_date(nil), do: nil
  defp parse_date(date_as_string) do
    with {:ok, date, _} <- DateTime.from_iso8601(date_as_string) do
      date
    else
      _ -> nil
    end
  end
end
