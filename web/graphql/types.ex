defmodule DistanceTracker.Types do
  use Absinthe.Schema.Notation

  object :distance_tracker do
    field :id, :id
    field :distance, :integer
    field :activity, :string
  end
end
