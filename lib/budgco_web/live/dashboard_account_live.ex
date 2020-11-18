defmodule BudgcoWeb.DashboardAccountLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Budgco.{Accounts, Repo, Customer, Address}

  def mount(_params, %{"user_token" => token}, socket) do
    current_user = Accounts.get_user_by_session_token(token)
    current_user = Repo.preload(current_user, customer: :address)

    customer_changeset = Customer.changeset(current_user.customer || %Customer{}, %{})

    assigns = %{
      current_user: current_user,
      current_customer: current_user.customer,
      customer: customer_changeset,
      account: %{
        "routing_number" => "",
        "account_number" => ""
      },
      account_validation: %{},
      form_state: %{
        "routing_number" => %{},
        "account_number" => %{}
      }
    }

    {:ok, assign(socket, assigns)}
  end

  def handle_event(
        "validate",
        %{"account" => %{} = account_attrs},
        socket
      ) do
    assigns = %{
      account: %{
        "routing_number" => account_attrs["routing_number"],
        "account_number" => account_attrs["account_number"]
      }
    }

    {:noreply, assign(socket, assigns)}
  end

  def handle_event(
        "create_external_account",
        %{"account" => %{} = account_attrs},
        socket
      ) do
    external_account = %{
      account: socket.assigns.current_customer.stripe_connect_account_id,
      country: "US",
      currency: "usd",
      account_holder_type: "individual",
      routing_number: account_attrs["routing_number"],
      account_number: account_attrs["account_number"]
    }

    {:ok, external_account} = Stripe.ExternalAccount.create(external_account)
  end

  def handle_event("focused", %{"field" => field, "value" => value} = account_attrs, socket) do
    state = socket.assigns.form_state[field]

    assigns = %{
      account: Map.put(socket.assigns.account, field, value),
      form_state: Map.put(socket.assigns.form_state, field, %{focused: true})
    }

    {:noreply, assign(socket, assigns)}
  end

  def validation(errors, field, form_state) do
    case errors[field] do
      {message, _} ->
        if Access.get(form_state[Atom.to_string(field)], :focused, false), do: message, else: nil

      nil ->
        nil
    end
  end

  def valid(customer) do
    customer.valid?
  end

  def button_name(customer) do
    if valid(customer), do: "Create and Continue", else: "Invalid"
  end
end
