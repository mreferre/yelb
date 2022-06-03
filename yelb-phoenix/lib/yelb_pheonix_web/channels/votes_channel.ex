defmodule YelbWeb.VoteChannel do
  use Phoenix.Channel

  alias Yelb.Votes

  def join("votes", _message, socket) do
    send(self(), :after_join)

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, votes} = Votes.list_votes()
    push(socket, "votes", votes)

    {:noreply, socket}
  end
end
