defmodule Budgco.Repo.Migrations.AddCustomerIdToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :customer_id, :integer
    end
  end
end
