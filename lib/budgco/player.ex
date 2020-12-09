defmodule Budgco.Player do
  use Ecto.Schema
  import Ecto.{Changeset}

  embedded_schema do
    field :active, :string
    field :college, :string
    field :displayName, :string
    field :dob, :string
    field :fname, :string
    field :index, :integer
    field :jersey, :string
    field :lname, :string
    field :playerId, :string
    field :position, :string
    field :team, :string
    field :weight, :string
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [
      :active,
      :college,
      :displayName,
      :dob,
      :fname,
      :index,
      :jersey,
      :lname,
      :playerId,
      :position,
      :team,
      :weight
    ])
  end
end
