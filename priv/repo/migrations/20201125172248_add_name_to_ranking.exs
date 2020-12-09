defmodule Budgco.Repo.Migrations.AddNameToRanking do
  use Ecto.Migration

  def change do
    alter table("rankings") do
      add :name, :text
    end
  end
end
