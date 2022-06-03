defmodule YelbWeb.VoteView do
  use YelbWeb, :view
  alias YelbWeb.VoteView

  def render("index.json", %{votes: votes}) do
    %{data: render_many(votes, VoteView, "vote.json")}
  end
end
