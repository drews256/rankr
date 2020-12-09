defmodule Budgco.Repo.Migrations.CreateRanking do
  use Ecto.Migration

  def change do
    create table(:rankings) do
      add :players, :jsonb, default: "[]"
      add :position, :text
      add :week, :integer
      add :league_type, :text
      add :user_id, :integer

      timestamps()
    end
  end
end
