defmodule Budgco.FantasyNerds do
  use Tesla
  plug Tesla.Middleware.Cache, ttl: :timer.seconds(3600)
  plug Tesla.Middleware.BaseUrl, "https://www.fantasyfootballnerd.com/service"
  plug Tesla.Middleware.JSON

  def players do
    get("/players/json/" <> System.get_env("FFN_API_KEY"))
  end
end
