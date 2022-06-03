defmodule YelbWeb.VoteControllerTest do
  use YelbWeb.ConnCase

  import Yelb.VotesFixtures

  alias Yelb.Votes.Vote

  @create_attrs %{
    name: "some name",
    value: 42
  }
  @update_attrs %{
    name: "some updated name",
    value: 43
  }
  @invalid_attrs %{name: nil, value: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all votes", %{conn: conn} do
      conn = get(conn, Routes.vote_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create vote" do
    test "renders vote when data is valid", %{conn: conn} do
      conn = post(conn, Routes.vote_path(conn, :create), vote: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.vote_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some name",
               "value" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.vote_path(conn, :create), vote: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update vote" do
    setup [:create_vote]

    test "renders vote when data is valid", %{conn: conn, vote: %Vote{id: id} = vote} do
      conn = put(conn, Routes.vote_path(conn, :update, vote), vote: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.vote_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some updated name",
               "value" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, vote: vote} do
      conn = put(conn, Routes.vote_path(conn, :update, vote), vote: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete vote" do
    setup [:create_vote]

    test "deletes chosen vote", %{conn: conn, vote: vote} do
      conn = delete(conn, Routes.vote_path(conn, :delete, vote))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.vote_path(conn, :show, vote))
      end
    end
  end

  defp create_vote(_) do
    vote = vote_fixture()
    %{vote: vote}
  end
end
