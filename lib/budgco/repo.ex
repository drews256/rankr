defmodule Budgco.Repo do
  use Ecto.Repo,
    otp_app: :budgco,
    adapter: Ecto.Adapters.Postgres
end
