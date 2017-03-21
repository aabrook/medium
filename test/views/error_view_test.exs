defmodule DistanceTracker.ErrorViewTest do
  use DistanceTracker.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render_to_string(DistanceTracker.ErrorView, "404.json", []) ==
      Poison.encode!(%{error: "Page not found"})
  end

  test "render 500.html" do
    assert render_to_string(DistanceTracker.ErrorView, "500.json", []) ==
      Poison.encode!(%{error: "Internal server error"})
  end

  test "render any other" do
    assert render_to_string(DistanceTracker.ErrorView, "505.json", []) ==
      Poison.encode!(%{error: "Internal server error"})
  end
end
