defmodule BoatNoodleWeb.CashInOutController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.CashInOut

  def index(conn, _params) do
    branches = Repo.all(from s in BoatNoodle.BN.Branch,where: s.brand_id==^BN.get_brand_id(conn))
    render(conn, "index.html", branches: branches)
  end

  def new(conn, _params) do
    changeset = BN.change_cash_in_out(%CashInOut{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"cash_in_out" => cash_in_out_params}) do
    case BN.create_cash_in_out(cash_in_out_params) do
      {:ok, cash_in_out} ->
        conn
        |> put_flash(:info, "Cash in out created successfully.")
        |> redirect(to: cash_in_out_path(conn, :show, cash_in_out))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    cash_in_out = BN.get_cash_in_out!(id)
    render(conn, "show.html", cash_in_out: cash_in_out)
  end

  def edit(conn, %{"id" => id}) do
    cash_in_out = BN.get_cash_in_out!(id)
    changeset = BN.change_cash_in_out(cash_in_out)
    render(conn, "edit.html", cash_in_out: cash_in_out, changeset: changeset)
  end

  def update(conn, %{"id" => id, "cash_in_out" => cash_in_out_params}) do
    cash_in_out = BN.get_cash_in_out!(id)

    case BN.update_cash_in_out(cash_in_out, cash_in_out_params) do
      {:ok, cash_in_out} ->
        conn
        |> put_flash(:info, "Cash in out updated successfully.")
        |> redirect(to: cash_in_out_path(conn, :show, cash_in_out))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", cash_in_out: cash_in_out, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    cash_in_out = BN.get_cash_in_out!(id)
    {:ok, _cash_in_out} = BN.delete_cash_in_out(cash_in_out)

    conn
    |> put_flash(:info, "Cash in out deleted successfully.")
    |> redirect(to: cash_in_out_path(conn, :index, BN.get_domain(conn)))
  end
end
