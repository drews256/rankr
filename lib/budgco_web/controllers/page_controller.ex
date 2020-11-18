defmodule BudgcoWeb.PageController do
  use BudgcoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
