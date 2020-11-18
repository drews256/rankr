defmodule BudgcoWeb.DashboardCustomerLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Budgco.{Accounts, Repo, Customer, Address}
  alias Budgco.Accounts.User
  alias Ecto.Changeset

  def mount(_params, %{"user_token" => token}, socket) do
    current_user = Accounts.get_user_by_session_token(token)

    current_user = Repo.preload(current_user, customer: :address)

    customer_changeset = Customer.changeset(current_user.customer || %Customer{}, %{})
    address_changeset = Address.changeset(%Address{}, %{})

    assigns = %{
      connect_info: get_connect_info(socket),
      customer_validation: %{},
      address_validation: %{},
      current_user: current_user,
      current_customer: current_user.customer,
      customer: customer_changeset,
      customer_validation: customer_changeset.errors,
      address_validation: address_changeset.errors,
      form_state: %{
        "first_name" => %{},
        "last_name" => %{},
        "phone_number" => %{},
        "email" => %{},
        "address_one" => %{},
        "address_two" => %{},
        "city" => %{},
        "state" => %{},
        "zip_code" => %{},
        "date_of_birth" => %{},
        "ssn" => %{}
      }
    }

    {:ok, assign(socket, assigns)}
  end

  def handle_event(
        "create_customer",
        %{"customer" => %{"address" => address_attrs} = customer_attrs},
        socket
      ) do
    address = %{
      city: address_attrs["city"],
      state: address_attrs["state"],
      zip_code: address_attrs["zip_code"],
      address_one: address_attrs["address_one"],
      address_two: address_attrs["address_two"]
    }

    address = Map.put(address, :id, socket.assigns.current_customer.address.id)

    new_customer = %{
      first_name: customer_attrs["first_name"],
      last_name: customer_attrs["last_name"],
      phone_number: customer_attrs["phone_number"],
      user_id: socket.assigns.current_user.id,
      date_of_birth: customer_attrs["date_of_birth"],
      ssn: customer_attrs["ssn"],
      address: address
    }

    stripe_address = %{
      city: address_attrs["city"],
      state: address_attrs["state"],
      postal_code: address_attrs["zip_code"],
      line1: address_attrs["address_one"],
      line2: address_attrs["address_two"]
    }

    stripe_customer = %{
      name: Enum.join([customer_attrs["first_name"], customer_attrs["last_name"]], " "),
      email: customer_attrs["email"],
      phone: customer_attrs["phone_number"],
      address: stripe_address
    }

    ip_address =
      socket.assigns.connect_info.peer_data.address
      |> Tuple.to_list()
      |> Enum.join(".")

    birthyear =
      customer_attrs["date_of_birth"]
      |> String.split("-")
      |> Enum.at(0)

    birthmonth =
      customer_attrs["date_of_birth"]
      |> String.split("-")
      |> Enum.at(1)

    birthday =
      customer_attrs["date_of_birth"]
      |> String.split("-")
      |> Enum.at(2)

    account_attrs = %{
      country: "US",
      type: "custom",
      business_type: "individual",
      email: customer_attrs["email"],
      business_profile: %{
        mcc: 5045,
        url: "https://www.facebook.com/Budgco-110316777544027"
      },
      individual: %{
        first_name: new_customer[:first_name],
        last_name: new_customer[:last_name],
        phone: customer_attrs["phone_number"],
        email: customer_attrs["email"],
        id_number: customer_attrs["ssn"],
        ssn_last_4: String.slice(customer_attrs["ssn"], 5..-1),
        dob: %{
          month: birthmonth,
          day: birthday,
          year: birthyear
        },
        address: %{
          city: address_attrs["city"],
          state: address_attrs["state"],
          postal_code: address_attrs["zip_code"],
          line1: address_attrs["address_one"],
          line2: address_attrs["address_two"]
        }
      },
      tos_acceptance: %{
        date: DateTime.to_unix(DateTime.utc_now()),
        ip: ip_address
      },
      requested_capabilities: ["transfers", "card_payments", "card_issuing"]
    }

    update_account_attrs = %{
      email: customer_attrs["email"],
      individual: %{
        first_name: new_customer[:first_name],
        last_name: new_customer[:last_name],
        phone: customer_attrs["phone_number"],
        email: customer_attrs["email"],
        dob: %{
          month: birthmonth,
          day: birthday,
          year: birthyear
        },
        address: %{
          city: address_attrs["city"],
          state: address_attrs["state"],
          postal_code: address_attrs["zip_code"],
          line1: address_attrs["address_one"],
          line2: address_attrs["address_two"]
        }
      }
    }

    update_account_attrs =
      if Map.get(socket.assigns.current_customer, :stripe_connect_account_id, false) do
        {:ok, stripe_account} =
          Stripe.Account.retrieve(socket.assigns.current_customer.stripe_connect_account_id)

        update_account_attrs =
          if stripe_account.individual.verification.status != "verified" do
            update_account_attrs =
              Map.put(
                update_account_attrs.individual,
                :ssn_last_4,
                String.slice(customer_attrs["ssn"], 5..-1)
              )

            update_account_attrs =
              Map.put(
                update_account_attrs.individual,
                :id_number,
                customer_attrs["ssn"]
              )

            update_account_attrs
          else
            update_account_attrs
          end

        update_account_attrs
      else
        update_account_attrs =
          Map.put(
            update_account_attrs.individual,
            :ssn_last_4,
            String.slice(customer_attrs["ssn"], 5..-1)
          )

        update_account_attrs =
          Map.put(
            update_account_attrs.individual,
            :id_number,
            customer_attrs["ssn"]
          )

        update_account_attrs
      end

    Repo.transaction(fn ->
      stripe_customer =
        if Map.get(socket.assigns.current_customer, :stripe_customer_id, false) do
          {:ok, stripe_customer} =
            Stripe.Customer.update(
              Map.fetch!(socket.assigns.current_customer, :stripe_customer_id),
              stripe_customer
            )

          stripe_customer
        else
          {:ok, stripe_customer} = Stripe.Customer.create(stripe_customer)
          stripe_customer
        end

      stripe_account =
        if Map.get(socket.assigns.current_customer, :stripe_connect_account_id, false) do
          {:ok, stripe_account} =
            Stripe.Account.update(
              Map.fetch!(socket.assigns.current_customer, :stripe_connect_account_id),
              update_account_attrs
            )

          stripe_account
        else
          {:ok, stripe_account} = Stripe.Account.create(account_attrs)
          stripe_account
        end

      all_customer_attributes =
        new_customer
        |> Map.put(:stripe_customer_id, stripe_customer.id)
        |> Map.put(:stripe_connect_account_id, stripe_account.id)

      customer_changeset =
        Customer.changeset(socket.assigns.current_customer, all_customer_attributes)

      user_changeset =
        User.update_changeset(
          socket.assigns.current_user,
          %{
            onboarding_state: "accounts"
          }
        )

      Repo.update!(user_changeset)
      Repo.insert_or_update!(customer_changeset)
    end)

    {:noreply, push_redirect(socket, to: "/dashboard/account")}
  end

  def handle_event(
        "validate",
        %{"customer" => %{"address" => address_attrs} = customer_attrs},
        socket
      ) do
    address = %{
      city: address_attrs["city"],
      state: address_attrs["state"],
      zip_code: address_attrs["zip_code"],
      address_one: address_attrs["address_one"],
      address_two: address_attrs["address_two"]
    }

    address = Map.put(address, :id, socket.assigns.current_customer.address.id)

    customer = %{
      first_name: customer_attrs["first_name"],
      last_name: customer_attrs["last_name"],
      phone_number: customer_attrs["phone_number"],
      ssn: customer_attrs["ssn"],
      date_of_birth: customer_attrs["date_of_birth"],
      user_id: socket.assigns.current_user.id,
      address: address
    }

    customer_changeset = Customer.changeset(socket.assigns.current_customer, customer)
    address_changeset = Address.changeset(%Address{}, address)

    assigns = %{
      customer_validation: customer_changeset.errors,
      address_validation: address_changeset.errors,
      customer: customer_changeset
    }

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("focused", %{"field" => field}, socket) do
    state = socket.assigns.form_state[field]

    assigns = %{
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
