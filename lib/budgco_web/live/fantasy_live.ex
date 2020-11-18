defmodule BudgcoWeb.FantasyLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Budgco.{FantasyNerds, Accounts, Repo, Customer, Address}

  def mount(_params, %{"user_token" => token}, socket) do
    current_user = Accounts.get_user_by_session_token(token)

    assigns = %{
      current_user: current_user,
      players: players()
    }

    {:ok, assign(socket, assigns)}
  end

  def handle_event("search", %{"search" => %{"for" => query}}, socket) do
    IO.inspect(query)

    assigns = %{
      players: players(query)
    }

    {:noreply, assign(socket, assigns)}
  end

  def players(search \\ nil) do
    {:ok, player_response} = FantasyNerds.players()

    if search == nil do
      player_response.body["Players"]
      |> Enum.filter(fn player ->
        player["active"] == "1"
      end)
    else
      player_response.body["Players"]
      |> Enum.filter(fn player ->
        player["active"] == "1"
      end)
      |> Enum.filter(fn player ->
        player["displayName"]
        |> String.contains?(search)
      end)
    end
  end
end
