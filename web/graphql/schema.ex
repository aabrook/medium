defmodule DistanceTracker.Schema do
  use Absinthe.Schema
  import Ecto.Query
  alias DistanceTracker.{Tracker, Repo}

  import_types(DistanceTracker.Types)

  query do
    field :distances, list_of(:distance_tracker) do
      resolve &list/3
    end

    field :distance, :distance_tracker do
      arg(:id, non_null(:string))
      resolve &show/3
    end
  end

  defp show(_, %{id: id}, _) do
    with tracker = %Tracker{} <- Repo.get(Tracker, id) do
      {:ok, tracker}
    else
      nil -> {:error, "Not Found"}
    end
  end

  defp list(_, _, _) do
    distances = Tracker
      |> DistanceTracker.Repo.all

    {:ok, distances}
  end
end
