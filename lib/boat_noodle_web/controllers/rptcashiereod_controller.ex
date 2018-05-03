defmodule BoatNoodleWeb.RPTCASHIEREODController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.RPTCASHIEREOD

  def index(conn, _params) do
    rpt_cashier_eod = Repo.all(from r in RPTCASHIEREOD, limit: 10)
    render(conn, "index.html", rpt_cashier_eod: rpt_cashier_eod)
  end

  def new(conn, _params) do
    changeset = BN.change_rptcashiereod(%RPTCASHIEREOD{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"rptcashiereod" => rptcashiereod_params}) do
    case BN.create_rptcashiereod(rptcashiereod_params) do
      {:ok, rptcashiereod} ->
        conn
        |> put_flash(:info, "Rptcashiereod created successfully.")
        |> redirect(to: rptcashiereod_path(conn, :show, rptcashiereod))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    rptcashiereod = BN.get_rptcashiereod!(id)
    render(conn, "show.html", rptcashiereod: rptcashiereod)
  end

  def edit(conn, %{"id" => id}) do
    rptcashiereod = BN.get_rptcashiereod!(id)
    changeset = BN.change_rptcashiereod(rptcashiereod)
    render(conn, "edit.html", rptcashiereod: rptcashiereod, changeset: changeset)
  end

  def update(conn, %{"id" => id, "rptcashiereod" => rptcashiereod_params}) do
    rptcashiereod = BN.get_rptcashiereod!(id)

    case BN.update_rptcashiereod(rptcashiereod, rptcashiereod_params) do
      {:ok, rptcashiereod} ->
        conn
        |> put_flash(:info, "Rptcashiereod updated successfully.")
        |> redirect(to: rptcashiereod_path(conn, :show, rptcashiereod))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", rptcashiereod: rptcashiereod, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    rptcashiereod = BN.get_rptcashiereod!(id)
    {:ok, _rptcashiereod} = BN.delete_rptcashiereod(rptcashiereod)

    conn
    |> put_flash(:info, "Rptcashiereod deleted successfully.")
    |> redirect(to: rptcashiereod_path(conn, :index))
  end
end
