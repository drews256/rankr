defmodule Budgco.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :address_one, :string
      add :address_two, :string
      add :customer_id, :integer
      add :city, :string
      add :state, :string
      add :zip_code, :string

      timestamps()
    end

  end
end
