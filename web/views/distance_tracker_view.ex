defmodule DistanceTracker.View do
  use DistanceTracker.Web, :view

  def render("index.json", %{trackers: trackers}) do
    %{data: render_many(trackers, DistanceTracker.View, "tracker.json", as: :tracker)}
  end

  def render("show.json", %{tracker: tracker}) do
    %{data: render_one(tracker, DistanceTracker.View, "tracker.json", as: :tracker)}
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

