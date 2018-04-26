defmodule BoatNoodleWeb.PageController do
  use BoatNoodleWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
