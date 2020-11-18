defmodule Budgco.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :first_name, :string
      add :last_name, :string
      add :user_id, :integer
      add :phone_number, :string
      add :stripe_customer_id, :string

      timestamps()
    end

  end
end
