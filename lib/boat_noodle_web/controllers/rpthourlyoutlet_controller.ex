defmodule BoatNoodleWeb.RPTHOURLYOUTLETController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.RPTHOURLYOUTLET

  def index(conn, _params) do
    rpt_hourly_outlet = Repo.all(from(r in RPTHOURLYOUTLET, limit: 10))
    render(conn, "index.html", rpt_hourly_outlet: rpt_hourly_outlet)
  end

  def new(conn, _params) do
    changeset = BN.change_rpthourlyoutlet(%RPTHOURLYOUTLET{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"rpthourlyoutlet" => rpthourlyoutlet_params}) do
    case BN.create_rpthourlyoutlet(rpthourlyoutlet_params) do
      {:ok, rpthourlyoutlet} ->
        conn
        |> put_flash(:info, "Rpthourlyoutlet created successfully.")
        |> redirect(to: rpthourlyoutlet_path(conn, :show, rpthourlyoutlet))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    rpthourlyoutlet = BN.get_rpthourlyoutlet!(id)
    render(conn, "show.html", rpthourlyoutlet: rpthourlyoutlet)
  end

  def edit(conn, %{"id" => id}) do
    rpthourlyoutlet = BN.get_rpthourlyoutlet!(id)
    changeset = BN.change_rpthourlyoutlet(rpthourlyoutlet)
    render(conn, "edit.html", rpthourlyoutlet: rpthourlyoutlet, changeset: changeset)
  end

  def update(conn, %{"id" => id, "rpthourlyoutlet" => rpthourlyoutlet_params}) do
    rpthourlyoutlet = BN.get_rpthourlyoutlet!(id)

    case BN.update_rpthourlyoutlet(rpthourlyoutlet, rpthourlyoutlet_params) do
      {:ok, rpthourlyoutlet} ->
        conn
        |> put_flash(:info, "Rpthourlyoutlet updated successfully.")
        |> redirect(to: rpthourlyoutlet_path(conn, :show, rpthourlyoutlet))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", rpthourlyoutlet: rpthourlyoutlet, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    rpthourlyoutlet = BN.get_rpthourlyoutlet!(id)
    {:ok, _rpthourlyoutlet} = BN.delete_rpthourlyoutlet(rpthourlyoutlet)

    conn
    |> put_flash(:info, "Rpthourlyoutlet deleted successfully.")
    |> redirect(to: rpthourlyoutlet_path(conn, :index, BN.get_domain(conn)))
  end
end
