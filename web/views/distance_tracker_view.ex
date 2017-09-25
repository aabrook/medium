defmodule DistanceTracker.TrackerView do
  use DistanceTracker.Web, :view

  def render("index.json", %{trackers: trackers}) do
    render_many(trackers, DistanceTracker.TrackerView, "tracker.json")
  end

  def render("show.json", %{tracker: tracker}) do
    render_one(tracker, DistanceTracker.TrackerView, "tracker.json")
  end

  def render("tracker.json", %{tracker: tracker}) do
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

