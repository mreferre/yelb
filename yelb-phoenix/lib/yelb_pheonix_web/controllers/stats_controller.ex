defmodule YelbWeb.StatsController do
  use YelbWeb, :controller

  alias Yelb.Pageview

  action_fallback(YelbWeb.FallbackController)

  def index(conn, _params) do
    {:ok, views} = Pageview.increase_view()
    {:ok, hostname} = :inet.gethostname()

    json(conn, %{hostname: List.to_string(hostname), pageviews: views})
  end
end
