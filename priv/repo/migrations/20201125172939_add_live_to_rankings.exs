defmodule Budgco.Repo.Migrations.AddLiveToRankings do
  use Ecto.Migration

  def change do
    alter table("rankings") do
      add :live, :boolean
    end
  end
end
