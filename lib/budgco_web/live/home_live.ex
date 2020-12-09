defmodule BudgcoWeb.HomeLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Budgco.{FantasyNerds, Accounts, Repo, Customer, Address}

  def mount(_params, %{"user_token" => token}, socket) do
    current_user = Accounts.get_user_by_session_token(token)

    assigns = %{
      current_user: current_user,
      rankings: Accounts.get_ten_live_rankings()
    }

    {:ok, assign(socket, assigns)}
  end
end
