defmodule Budgco.Repo.Migrations.AddStripeConnectAccountIdToUser do
  use Ecto.Migration

  def change do
    alter table("customers") do
      add :stripe_connect_account_id, :text
    end
  end
end
