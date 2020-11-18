defmodule Budgco.Repo.Migrations.AddSSNAndDateOfBirthToUser do
  use Ecto.Migration

  def change do
    alter table("customers") do
      add :ssn, :text
      add :date_of_birth, :date
    end
  end
end
