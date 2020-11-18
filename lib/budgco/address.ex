defmodule Budgco.Address do
  use Ecto.Schema
  import Ecto.Changeset
  alias Budgco.Customer

  schema "addresses" do
    field :address_one, :string
    field :address_two, :string
    field :city, :string
    field :state, :string
    field :zip_code, :string
    belongs_to :customer, Customer

    timestamps()
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:address_one, :address_two, :customer_id, :city, :state, :zip_code])
    |> validate_required([:address_one, :city, :state, :zip_code])
  end
end
