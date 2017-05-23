defmodule DistanceTracker.TrackerControllerTest do
  use DistanceTracker.ConnCase, async: true

  import DistanceTracker.Router.Helpers, only: [tracker_path: 2, tracker_path: 3]

  alias DistanceTracker.{Factory, Repo, Tracker}

  def insert_tracker(params \\ []) do
    Factory.insert(Tracker, params)
  end

  test "List all trackers", %{conn: conn} do
    tracker_a = insert_tracker()
    tracker_b = insert_tracker()

    %{"data" => data} = conn
      |> get(tracker_path(conn, :index))
      |> Map.get(:resp_body)
      |> Poison.decode!

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

  test "Show a tracker", %{conn: conn} do
    tracker_a = insert_tracker()
    insert_tracker()

    %{resp_body: body, status: status} = conn
      |> get(tracker_path(conn, :show, tracker_a.uuid))

    %{"data" => data} = Poison.decode!(body)

    assert 200 == status
    assert %{
        "activity" => tracker_a.activity,
        "completed_at" => DateTime.to_iso8601(tracker_a.completed_at),
        "distance" => tracker_a.distance,
        "inserted_at" => DateTime.to_iso8601(tracker_a.inserted_at),
        "updated_at" => DateTime.to_iso8601(tracker_a.updated_at),
        "uuid" => tracker_a.uuid
      } == data
  end

  test "Tracker not found returns a 404", %{conn: conn} do
    %{resp_body: body, status: status} = conn
      |> get(tracker_path(conn, :show, UUID.uuid4()))

    %{"error" => message} = Poison.decode!(body)

    assert 404 == status
    assert "Page not found" == message
  end

  test "Create a new record through post", %{conn: conn} do
    payload = %{
      "completed_at" => "2017-03-21T14:00:00Z",
      "activity" => "climbing",
      "distance" => 150
    }

    %{resp_body: body, status: status} = conn
      |> post(tracker_path(conn, :create), Poison.encode!(payload))

    response = body
      |> Poison.decode!
      |> Map.get("data")
      |> Map.take(["completed_at", "activity", "distance"])

    assert payload == response
    assert 201 == status
  end

  test "Requires activity when creating a request", %{conn: conn} do
    payload = %{
      "completed_at" => "2017-03-21T14:00:00Z",
      "distance": 150
    }

    %{resp_body: body, status: status} = conn
      |> post(tracker_path(conn, :create), Poison.encode!(payload))

    %{"error" => _message} = Poison.decode!(body)

    assert %{"error" => "Bad request"} == Poison.decode!(body)
    assert 422 == status
  end

  test "Requires completed_at when creating a request", %{conn: conn} do
    payload = %{
      "activity": "swimming",
      "distance": 150
    }

    %{resp_body: body, status: status} = conn
      |> post(tracker_path(conn, :create), Poison.encode!(payload))

    %{"error" => _message} = Poison.decode!(body)

    assert %{"error" => "Bad request"} == Poison.decode!(body)
    assert 422 == status
  end

  test "Create saves to the database", %{conn: conn} do
    {:ok, date, _} = DateTime.from_iso8601("2017-03-21T14:00:00Z")

    payload = %{
      "completed_at" => "2017-03-21T14:00:00Z",
      "activity" => "climbing",
      "distance" => 150
    }

    %{resp_body: body} = conn
      |> post(tracker_path(conn, :create), Poison.encode!(payload))

    response = body
      |> Poison.decode!
      |> get_in(["data", "uuid"])

    record = Tracker
      |> Repo.get(response)
      |> Map.take([:completed_at, :activity, :distance])

    assert DateTime.compare(record.completed_at, date)
    assert %{
      activity: "climbing",
      distance: 150
    } == Map.drop(record, [:completed_at])
  end

  test "Updates a record", %{conn: conn} do
    tracker = Factory.insert(Tracker, %{distance: 50})

    payload = %{
      distance: 100
    }

    %{resp_body: body, status: status} = conn
      |> patch(tracker_path(conn, :update, tracker.uuid), Poison.encode!(payload))

    distance = body
      |> Poison.decode!
      |> get_in(["data", "distance"])

    assert distance == 100
    assert status == 201
    assert Repo.get(Tracker, tracker.uuid).distance == 100
  end

  test "errors with an invalid uuid", %{conn: conn} do
    payload = %{
      distance: 100
    }

    %{status: status} = conn
      |> patch(tracker_path(conn, :update, UUID.uuid4), Poison.encode!(payload))

    assert status == 422
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

  test "Delete returns a 404 if the record is not found", %{conn: conn} do
    uuid = UUID.uuid4()

    %{resp_body: body, status: status} = conn
      |> delete(tracker_path(conn, :delete, uuid))

    assert 404 == status
    assert %{"error" => "Page not found"} == Poison.decode!(body)
  end
end
