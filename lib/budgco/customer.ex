defmodule Budgco.Customer do
  use Ecto.Schema
  import Ecto.{Changeset}
  alias Budgco.{Address, Repo}

  schema "customers" do
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :stripe_customer_id, :string
    field :stripe_connect_account_id, :string
    field :user_id, :integer
    field :ssn, :string
    field :date_of_birth, :date
    has_one :address, Address

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :first_name,
      :last_name,
      :user_id,
      :phone_number,
      :stripe_customer_id,
      :ssn,
      :date_of_birth,
      :stripe_connect_account_id
    ])
    |> cast_assoc(:address)
    |> validate_required([:first_name, :last_name, :user_id, :phone_number])
  end

  def get_customer_by_id(id) do
    Repo.get_by(Customer, id: id)
  end
end
