defmodule DistanceTracker.Tracker do
  use DistanceTracker.Web, :model

  @timestamps_opts [type: :utc_datetime, usec: true]
  @primary_key {:uuid, :binary_id, [autogenerate: true]}

  schema "distance_tracker" do
    field :distance, :integer
    field :activity, :string
    field :completed_at, :utc_datetime

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    params = remove_nil_params(params)

    struct
    |> cast(params, [:completed_at, :activity, :uuid, :distance])
    |> validate_required([:completed_at, :activity])
  end

  defp remove_nil_params(params) do
    for {k, v} <- params, v, into: %{}, do: {k, v}
  end
end

