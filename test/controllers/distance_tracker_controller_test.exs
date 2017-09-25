defmodule DistanceTracker.TrackerControllerTest do
  use DistanceTracker.ConnCase, async: true
  use PhoenixSwagger.SchemaTest, "priv/static/swagger.json"

  import DistanceTracker.Router.Helpers, only: [tracker_path: 2, tracker_path: 3]

  alias DistanceTracker.{Factory, Repo, Tracker}

  def insert_tracker(params \\ []) do
    Factory.insert(Tracker, params)
  end

  test "List all trackers", %{conn: conn, swagger_schema: schema} do
    tracker_a = insert_tracker()
    tracker_b = insert_tracker()

    data = conn
      |> get(tracker_path(conn, :index))
      |> validate_resp_schema(schema, "Trackers")
      |> json_response(200)

    assert [
      %{
        "activity" => tracker_a.activity,
        "completed_at" => DateTime.to_iso8601(tracker_a.completed_at),
        "distance" => tracker_a.distance,
        "inserted_at" => DateTime.to_iso8601(tracker_a.inserted_at),
        "updated_at" => DateTime.to_iso8601(tracker_a.updated_at),
        "uuid" => tracker_a.uuid
      },
      %{
        "activity" => tracker_b.activity,
        "completed_at" => DateTime.to_iso8601(tracker_b.completed_at),
        "distance" => tracker_b.distance,
        "inserted_at" => DateTime.to_iso8601(tracker_b.inserted_at),
        "updated_at" => DateTime.to_iso8601(tracker_b.updated_at),
        "uuid" => tracker_b.uuid
      }
    ] == data
  end

  test "Show a tracker", %{conn: conn, swagger_schema: schema} do
    tracker_a = insert_tracker()
    insert_tracker()

    data = conn
      |> get(tracker_path(conn, :show, tracker_a.uuid))
      |> validate_resp_schema(schema, "Tracker")
      |> json_response(200)

    assert %{
        "activity" => tracker_a.activity,
        "completed_at" => DateTime.to_iso8601(tracker_a.completed_at),
        "distance" => tracker_a.distance,
        "inserted_at" => DateTime.to_iso8601(tracker_a.inserted_at),
        "updated_at" => DateTime.to_iso8601(tracker_a.updated_at),
        "uuid" => tracker_a.uuid
      } == data
  end

  test "Tracker not found returns a 404", %{conn: conn, swagger_schema: schema} do
    %{"error" => message} = conn
      |> get(tracker_path(conn, :show, UUID.uuid4()))
      |> validate_resp_schema(schema, "Error")
      |> json_response(404)

    assert "Page not found" == message
  end

  test "Create a new record through post", %{conn: conn, swagger_schema: schema} do
    payload = %{
      "completed_at" => "2017-03-21T14:00:00Z",
      "activity" => "climbing",
      "distance" => 150
    }

    %{"uuid" => uuid} = conn
      |> post(tracker_path(conn, :create), Poison.encode!(payload))
      |> validate_resp_schema(schema, "Tracker")
      |> json_response(201)

    %{
      completed_at: completed_at,
      activity: activity,
      distance: distance
    } = Repo.get(Tracker, uuid)

    expected_date = ~N[2017-03-21 14:00:00.000000]
      |> DateTime.from_naive!("Etc/UTC")

    assert activity == "climbing"
    assert distance == 150
    assert completed_at == expected_date
  end

  test "Requires activity when creating a request", %{conn: conn, swagger_schema: schema} do
    payload = %{
      "completed_at" => "2017-03-21T14:00:00Z",
      "distance": 150
    }

    %{"error" => message} = conn
      |> post(tracker_path(conn, :create), Poison.encode!(payload))
      |> validate_resp_schema(schema, "Error")
      |> json_response(422)

    assert "Bad request" == message
  end

  test "Requires completed_at when creating a request", %{conn: conn, swagger_schema: schema} do
    payload = %{
      "activity": "swimming",
      "distance": 150
    }

    %{"error" => message} = conn
      |> post(tracker_path(conn, :create), Poison.encode!(payload))
      |> validate_resp_schema(schema, "Error")
      |> json_response(422)

    assert "Bad request" = message
  end

  test "Updates a record", %{conn: conn, swagger_schema: schema} do
    tracker = Factory.insert(Tracker, %{distance: 50})

    payload = %{
      distance: 100
    }

    %{"distance" => distance} = conn
      |> patch(tracker_path(conn, :update, tracker.uuid), Poison.encode!(payload))
      |> validate_resp_schema(schema, "Tracker")
      |> json_response(201)

    assert distance == 100
    assert Repo.get(Tracker, tracker.uuid).distance == 100
  end

  test "errors with an invalid uuid", %{conn: conn, swagger_schema: schema} do
    payload = %{
      distance: 100
    }

    %{"error" => message} = conn
      |> patch(tracker_path(conn, :update, UUID.uuid4), Poison.encode!(payload))
      |> validate_resp_schema(schema, "Error")
      |> json_response(422)

    assert "Bad request" == message
  end

  test "Deletes a record using a web request", %{conn: conn} do
    %{uuid: uuid} = insert_tracker()

    %{resp_body: body, status: status} = conn
      |> delete(tracker_path(conn, :delete, uuid))

    assert body == ""
    assert status == 204
  end

  test "Deletes a record from the database using a web request", %{conn: conn} do
    %{uuid: uuid} = insert_tracker()

    delete(conn, tracker_path(conn, :delete, uuid))

    assert nil == Repo.get(Tracker, uuid)
  end

  test "Delete returns a 404 if the record is not found", %{conn: conn, swagger_schema: schema} do
    uuid = UUID.uuid4()

    %{"error" => message} = conn
      |> delete(tracker_path(conn, :delete, uuid))
      |> validate_resp_schema(schema, "Error")
      |> json_response(404)

    assert "Page not found" == message
  end
end
