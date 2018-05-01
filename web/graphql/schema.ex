defmodule DistanceTracker.Schema do
  use Absinthe.Schema
  import Ecto.Query
  alias DistanceTracker.{Tracker, Repo}

  import_types(DistanceTracker.Types)
  query do
    field :distances, list_of(:distance_tracker) do
      resolve fn _, _, _ ->
        distances = Tracker
          |> DistanceTracker.Repo.all

        {:ok, distances}
      end
    end

    field :distance, :distance_tracker do
      arg(:id, non_null(:string))
      resolve fn _, %{id: id}, _ ->
        {:ok, Repo.get(Tracker, id)}
      end
    end
  end
end
