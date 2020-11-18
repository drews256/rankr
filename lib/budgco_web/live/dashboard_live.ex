defmodule BudgcoWeb.DashboardLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Budgco.{Accounts, Repo, Customer, Address}

  def mount(_params, %{"user_token" => token}, socket) do
    current_user = Accounts.get_user_by_session_token(token)

    assigns = %{
      current_user: current_user
    }

    {:ok, assign(socket, assigns)}
  end

  def handle_params(_params, _url, socket) do
    current_user = socket.assigns.current_user

    case current_user.onboarding_state do
      nil -> {:noreply, push_redirect(socket, to: "/dashboard/customer")}
      "accounts" -> {:noreply, push_redirect(socket, to: "/dashboard/account")}
      "finished" -> {:noreply, push_redirect(socket, to: "/dashboard/card")}
    end
  end
end
