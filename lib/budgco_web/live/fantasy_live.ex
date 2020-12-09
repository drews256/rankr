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
      players: ordered_players(players()),
      unchosen_players: ordered_players(players()),
      chosen_players: [],
      chosen_ids: [],
      position: "QB",
      week: 1,
      name: "",
      league_type: "standard",
      unchosen_ids: Enum.map(players(), fn player -> player["playerId"] end),
      filtered_ids: []
    }

    {:ok, assign(socket, assigns)}
  end

  def handle_event("save", %{} = info, socket) do
    {:ok, ranking} =
      Accounts.save_ranking(%{
        players: socket.assigns.chosen_players,
        position: socket.assigns.position,
        week: socket.assigns.week,
        league_type: socket.assigns.league_type,
        name: socket.assigns.name,
        user_id: socket.assigns.current_user.id
      })

    {:noreply, push_redirect(socket, to: "/rankings")}
  end

  def handle_event(
        "select_position",
        %{"position_options" => %{"position" => position}},
        socket
      ) do
    assigns = %{position: position}
    {:noreply, assign(socket, assigns)}
  end

  def handle_event("select_week", %{"week_options" => %{"week" => week}} = info, socket) do
    assigns = %{week: week}
    {:noreply, assign(socket, assigns)}
  end

  def handle_event(
        "league_type",
        %{"league_type" => %{"league_type" => league_type}} = info,
        socket
      ) do
    assigns = %{league_type: league_type}
    {:noreply, assign(socket, assigns)}
  end

  def handle_event("search", %{"search" => %{"for" => query}}, socket) do
    assigns = %{
      unchosen_players: players(query)
    }

    {:noreply, assign(socket, assigns)}
  end

  def ordered_players(players) do
    players
    |> Enum.with_index()
    |> Enum.map(fn {player, index} ->
      Map.put(player, "index", index)
    end)
  end

  def swap_id(to_add, chosen, unchosen, id) do
    case to_add do
      "chosen_players" -> {[id | chosen], List.delete(unchosen, id)}
      "unchosen_players" -> {List.delete(chosen, id), [id | unchosen]}
      _ -> {chosen, unchosen}
    end
  end

  def handle_event("add", %{} = info, socket) do
    {chosen_ids, unchosen_ids} =
      if info["type"] == "add" do
        case info["toId"] do
          "chosen_players" ->
            swap_id(
              "chosen_players",
              socket.assigns.chosen_ids,
              socket.assigns.unchosen_ids,
              info["playerId"]
            )

          "players" ->
            swap_id(
              "unchosen_players",
              socket.assigns.chosen_ids,
              socket.assigns.unchosen_ids,
              info["playerId"]
            )

          _ ->
            {socket.assigns.chosen_ids, socket.assigns.unchosen_ids}
        end
      else
        {socket.assigns.chosen_ids, socket.assigns.unchosen_ids}
      end

    chosen_players =
      Enum.map(players_by_player_id(socket.assigns.players, chosen_ids), fn player ->
        updated_player =
          Enum.find(info["playerOrder"], fn chosen_player ->
            chosen_player["id"] == player["playerId"]
          end)

        Map.replace!(
          player,
          "index",
          updated_player["index"]
        )
      end)

    sorted_chosen_players =
      chosen_players
      |> Enum.sort_by(fn player -> player["index"] end)

    sorted_unchosen_players =
      socket.assigns.players
      |> players_by_player_id(unchosen_ids)
      |> Enum.sort_by(fn player -> player["index"] end)

    assigns = %{
      chosen_players: sorted_chosen_players,
      unchosen_players: sorted_unchosen_players,
      chosen_ids: chosen_ids,
      unchosen_ids: unchosen_ids
    }

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("name", %{"ranking_name" => %{"for" => name}} = info, socket) do
    assigns = %{
      name: name
    }

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("sort", %{} = info, socket) do
    chosen_players =
      Enum.map(socket.assigns.chosen_players, fn player ->
        updated_player =
          Enum.find(info["playerOrder"], fn chosen_player ->
            chosen_player["id"] == player["playerId"]
          end)

        Map.replace!(
          player,
          "index",
          updated_player["index"]
        )
      end)

    sorted_chosen_players =
      chosen_players
      |> Enum.sort_by(fn player -> player["index"] end)

    assigns = %{chosen_players: sorted_chosen_players}

    {:noreply, assign(socket, assigns)}
  end

  def get_player_by_id(players, id) do
    players
    |> Enum.find(fn player ->
      player["playerId"] == id
    end)
  end

  def filtered_players_by_player_id(players, ids \\ []) do
    players
    |> Enum.filter(fn player ->
      !Enum.member?(ids, player["playerId"])
    end)
  end

  def players_by_player_id(players, ids \\ []) do
    players
    |> Enum.filter(fn player ->
      Enum.member?(ids, player["playerId"])
    end)
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
