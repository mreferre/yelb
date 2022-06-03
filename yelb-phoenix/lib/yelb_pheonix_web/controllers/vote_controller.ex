defmodule YelbWeb.VoteController do
  use YelbWeb, :controller

  alias Yelb.Votes

  action_fallback YelbWeb.FallbackController

  def index(conn, _params) do
    {:ok, votes} = Votes.list_votes()

    json(conn, votes)
  end

  def vote(conn, %{"name" => name} = _params)
      when name in ["ihop", "chipotle", "outback", "bucadibeppo"] do
    {:ok, data} = Votes.increase_vote(name)

    {:ok, votes} = Votes.list_votes()
    YelbWeb.Endpoint.broadcast("votes", "votes", votes)

    text(conn, data)
  end

  def vote(conn, _params) do
    conn
    |> put_status(400)
    |> text("Not permitted")
  end
end
