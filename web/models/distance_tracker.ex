defmodule DistanceTracker.DistanceTracker do
  use DistanceTracker.Web, :model

  @timestamps_opts [type: :utc_datetime, usec: true]
  @primary_key {:uuid, :binary_id, [autogenerate: true]}

  schema "distance_tracker" do
    field :uuid, :uuid, primary_key: true
    field :distance, :integer
    field :activity, :string
    field :completed_at, :utc_datetime

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:completed_at, :activity, :uuid, :distance])
    |> validate_required([:completed_at, :activity])
  end

  def to_json(trackers) when is_list(trackers) do
    Enum.map(trackers, &to_json/1)
  end
  def to_json(tracker) do
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

