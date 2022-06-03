defmodule VoteHelper do
  def list_to_map(list, acc \\ [])

  def list_to_map([x, y | xs], acc), do: list_to_map(xs, [{x, y} | acc])
  def list_to_map(_, acc), do: Map.new(acc)
end

defmodule Yelb.Votes do
  @moduledoc """
  The Votes context.
  """

  def list_votes do
    {status, data} = Redix.command(:redix, ["HGETALL", "votes"])

    case status do
      :ok -> {status, VoteHelper.list_to_map(data)}
      _ -> {status, data}
    end
  end

  def increase_vote(name) when is_bitstring(name) do
    Redix.command(:redix, ["HINCRBY", "votes", name, 1])
  end
end
