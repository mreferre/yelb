defmodule Yelb.VotesTest do
  use Yelb.DataCase

  alias Yelb.Votes

  describe "votes" do
    alias Yelb.Votes.Vote

    import Yelb.VotesFixtures

    @invalid_attrs %{name: nil, value: nil}

    test "list_votes/0 returns all votes" do
      vote = vote_fixture()
      assert Votes.list_votes() == [vote]
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = vote_fixture()
      assert Votes.get_vote!(vote.id) == vote
    end

    test "create_vote/1 with valid data creates a vote" do
      valid_attrs = %{name: "some name", value: 42}

      assert {:ok, %Vote{} = vote} = Votes.create_vote(valid_attrs)
      assert vote.name == "some name"
      assert vote.value == 42
    end

    test "create_vote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Votes.create_vote(@invalid_attrs)
    end

    test "update_vote/2 with valid data updates the vote" do
      vote = vote_fixture()
      update_attrs = %{name: "some updated name", value: 43}

      assert {:ok, %Vote{} = vote} = Votes.update_vote(vote, update_attrs)
      assert vote.name == "some updated name"
      assert vote.value == 43
    end

    test "update_vote/2 with invalid data returns error changeset" do
      vote = vote_fixture()
      assert {:error, %Ecto.Changeset{}} = Votes.update_vote(vote, @invalid_attrs)
      assert vote == Votes.get_vote!(vote.id)
    end

    test "delete_vote/1 deletes the vote" do
      vote = vote_fixture()
      assert {:ok, %Vote{}} = Votes.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Votes.get_vote!(vote.id) end
    end

    test "change_vote/1 returns a vote changeset" do
      vote = vote_fixture()
      assert %Ecto.Changeset{} = Votes.change_vote(vote)
    end
  end
end
