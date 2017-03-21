defmodule DistanceTracker.ErrorView do
  def render("404.json", _assigns) do
    %{error: "Page not found"}
  end

  def render("422.json", _assigns) do
    %{error: "Bad request"}
  end

  def render("500.json", _assings) do
    %{error: "Internal server error"}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def render(_template, assigns) do
    render "500.json", assigns
  end
end
