defmodule BudgcoWeb.PersonalRankingsLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Budgco.{FantasyNerds, Accounts, Repo, Customer, Address}
  alias Budgco.Accounts.User

  def mount(_params, %{"user_token" => token}, socket) do
    current_user = Accounts.get_user_by_session_token(token)
    current_user = Repo.preload(current_user, :rankings)

    assigns = %{
      rankings: current_user.rankings,
      current_user: current_user
    }

    {:ok, assign(socket, assigns)}
  end

  def handle_event("make_live", %{"live" => live, "ranking-id" => id}, socket) do
    ranking = Accounts.get_ranking!(id)

    update_value_to =
      case live do
        "true" -> false
        "false" -> true
        _ -> false
      end

    {:ok, updated} =
      Accounts.update_ranking(ranking, %{
        live: update_value_to
      })

    current_user = Repo.get!(User, socket.assigns.current_user.id) |> Repo.preload(:rankings)

    assigns = %{
      rankings: current_user.rankings
    }

    {:noreply, assign(socket, assigns)}
  end
end
