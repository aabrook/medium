defmodule DistanceTracker.DistanceTrackerView do
  use Tracker.Web, :view

  render("index.json", %{trackings: trackings}) do
    Enum.map(trackings, &to_json/1)
  end

  render("show.json", %{tracking: tracking}) do
    to_json(tracking)
  end

  defp to_json(tracker) do
    %{
      uuid: tracker.uuid,
      activity: tracker.activity,
      completed_at: tracker.completed_at,
      distance: tracker.distance,
      inserted_at: tracker.inserted_at,
      updated_at: tracker.updated_at
    }
  end
end

