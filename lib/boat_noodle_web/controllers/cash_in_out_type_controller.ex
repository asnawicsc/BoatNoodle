defmodule BoatNoodleWeb.CashInOutTypeController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.CashInOutType

  def index(conn, _params) do
    cash_in_out_type = BN.list_cash_in_out_type()
    render(conn, "index.html", cash_in_out_type: cash_in_out_type)
  end

  def new(conn, _params) do
    changeset = BN.change_cash_in_out_type(%CashInOutType{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"cash_in_out_type" => cash_in_out_type_params}) do
    case BN.create_cash_in_out_type(cash_in_out_type_params) do
      {:ok, cash_in_out_type} ->
        conn
        |> put_flash(:info, "Cash in out type created successfully.")
        |> redirect(to: cash_in_out_type_path(conn, :show, cash_in_out_type))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    cash_in_out_type = BN.get_cash_in_out_type!(id)
    render(conn, "show.html", cash_in_out_type: cash_in_out_type)
  end

  def edit(conn, %{"id" => id}) do
    cash_in_out_type = BN.get_cash_in_out_type!(id)
    changeset = BN.change_cash_in_out_type(cash_in_out_type)
    render(conn, "edit.html", cash_in_out_type: cash_in_out_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "cash_in_out_type" => cash_in_out_type_params}) do
    cash_in_out_type = BN.get_cash_in_out_type!(id)

    case BN.update_cash_in_out_type(cash_in_out_type, cash_in_out_type_params) do
      {:ok, cash_in_out_type} ->
        conn
        |> put_flash(:info, "Cash in out type updated successfully.")
        |> redirect(to: cash_in_out_type_path(conn, :show, cash_in_out_type))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", cash_in_out_type: cash_in_out_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    cash_in_out_type = BN.get_cash_in_out_type!(id)
    {:ok, _cash_in_out_type} = BN.delete_cash_in_out_type(cash_in_out_type)

    conn
    |> put_flash(:info, "Cash in out type deleted successfully.")
    |> redirect(to: cash_in_out_type_path(conn, :index))
  end
end
