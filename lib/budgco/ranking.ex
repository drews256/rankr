defmodule Budgco.Ranking do
  use Ecto.Schema
  import Ecto.{Changeset}
  alias Budgco.{Address, Player, Repo}

  schema "rankings" do
    field :week, :integer
    embeds_many :players, Player
    field :position, :string
    field :league_type, :string
    field :user_id, :integer
    field :name, :string
    field :live, :boolean

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :week,
      :name,
      :position,
      :user_id,
      :league_type,
      :live
    ])
    |> cast_embed(:players)
    |> validate_required([:name, :week, :players, :league_type, :user_id, :position])
  end
end
