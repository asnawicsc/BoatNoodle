defmodule BoatNoodleWeb.PageController do
  use BoatNoodleWeb, :controller
  import Ecto.Query
  require IEx

  def index(conn, _params) do
     branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn,"index.html",branches: branches)
  end

  def no_page_found(conn, _params) do
    conn
    |> put_flash(:error, "No page found")
    |> redirect(to: page_path(conn, :index))
  end
end
