defmodule DistanceTracker.ErrorView do
  use DistanceTracker.Web, :view

  def render("404.json", _assigns) do
    %{error: "Page not found"}
  end

  def render("422.json", _assigns) do
    %{error: "Bad request"}
  end

  def render("500.json", errors: errors) do
    %{error: "Internal server error", errors: errors}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(template, assigns) do
    render "500.json", assigns
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
