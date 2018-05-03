defmodule BoatNoodleWeb.RPTTRANSACTIONController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.RPTTRANSACTION

  def index(conn, _params) do
    rpt_transaction = Repo.all(from r in RPTTRANSACTION, limit: 10)
    render(conn, "index.html", rpt_transaction: rpt_transaction)
  end

  def new(conn, _params) do
    changeset = BN.change_rpttransaction(%RPTTRANSACTION{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"rpttransaction" => rpttransaction_params}) do
    case BN.create_rpttransaction(rpttransaction_params) do
      {:ok, rpttransaction} ->
        conn
        |> put_flash(:info, "Rpttransaction created successfully.")
        |> redirect(to: rpttransaction_path(conn, :show, rpttransaction))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    rpttransaction = BN.get_rpttransaction!(id)
    render(conn, "show.html", rpttransaction: rpttransaction)
  end

  def edit(conn, %{"id" => id}) do
    rpttransaction = BN.get_rpttransaction!(id)
    changeset = BN.change_rpttransaction(rpttransaction)
    render(conn, "edit.html", rpttransaction: rpttransaction, changeset: changeset)
  end

  def update(conn, %{"id" => id, "rpttransaction" => rpttransaction_params}) do
    rpttransaction = BN.get_rpttransaction!(id)

    case BN.update_rpttransaction(rpttransaction, rpttransaction_params) do
      {:ok, rpttransaction} ->
        conn
        |> put_flash(:info, "Rpttransaction updated successfully.")
        |> redirect(to: rpttransaction_path(conn, :show, rpttransaction))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", rpttransaction: rpttransaction, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    rpttransaction = BN.get_rpttransaction!(id)
    {:ok, _rpttransaction} = BN.delete_rpttransaction(rpttransaction)

    conn
    |> put_flash(:info, "Rpttransaction deleted successfully.")
    |> redirect(to: rpttransaction_path(conn, :index))
  end
end
