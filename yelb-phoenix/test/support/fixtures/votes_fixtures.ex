defmodule Yelb.VotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Yelb.Votes` context.
  """

  @doc """
  Generate a vote.
  """
  def vote_fixture(attrs \\ %{}) do
    {:ok, vote} =
      attrs
      |> Enum.into(%{
        name: "some name",
        value: 42
      })
      |> Yelb.Votes.create_vote()

    vote
  end
end
