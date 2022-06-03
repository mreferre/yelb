defmodule Yelb.Pageview do
  @moduledoc """
  The Pageview context.
  """

  def increase_view() do
    Redix.command(:redix, ["INCR", "pageviews"])
  end
end
