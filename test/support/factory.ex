defmodule DistanceTracker.Factory do
  alias DistanceTracker.Tracker
  def create(Tracker) do
    %Tracker{
      uuid: UUID.uuid4(),
      distance: 1500,
      activity: "swimming",
      completed_at: DateTime.utc_now()
    }
  end
  @doc """
  Creates an instance of the given Ecto Schema module type with the supplied attributes.
  ## Examples
  tracker = insert(DistanceTracker.Tracker, activity: "sky-diving")
  """
  @spec create(module, Enum.t) :: map
  def create(schema, attributes) do
    schema
    |> create()
    |> struct(attributes)
  end
  @doc """
  Inserts a new instance of the given Ecto schema module into the Repo
  ## Examples
  tracker = insert(DistanceTracker.Tracker, activity: "sky-diving")
  """
  @spec insert(module, Enum.t) :: map
  def insert(schema, attributes \\ []) do
    DistanceTracker.Repo.insert! create(schema, attributes)
  end
end
