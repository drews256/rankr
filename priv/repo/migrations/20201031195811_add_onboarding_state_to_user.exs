defmodule Budgco.Repo.Migrations.AddOnboardingStateToUser do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :onboarding_state, :text
    end
  end
end
