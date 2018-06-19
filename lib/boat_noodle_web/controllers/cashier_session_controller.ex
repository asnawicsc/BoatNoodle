defmodule BoatNoodleWeb.CashierSessionController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.CashierSession

  def index(conn, _params) do
    cashier_session = BN.list_cashier_session()
    render(conn, "index.html", cashier_session: cashier_session)
  end

  def new(conn, _params) do
    changeset = BN.change_cashier_session(%CashierSession{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"cashier_session" => cashier_session_params}) do
    case BN.create_cashier_session(cashier_session_params) do
      {:ok, cashier_session} ->
        conn
        |> put_flash(:info, "Cashier session created successfully.")
        |> redirect(to: cashier_session_path(conn, :show, cashier_session))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    cashier_session = BN.get_cashier_session!(id)
    render(conn, "show.html", cashier_session: cashier_session)
  end

  def edit(conn, %{"id" => id}) do
    cashier_session = BN.get_cashier_session!(id)
    changeset = BN.change_cashier_session(cashier_session)
    render(conn, "edit.html", cashier_session: cashier_session, changeset: changeset)
  end

  def update(conn, %{"id" => id, "cashier_session" => cashier_session_params}) do
    cashier_session = BN.get_cashier_session!(id)

    case BN.update_cashier_session(cashier_session, cashier_session_params) do
      {:ok, cashier_session} ->
        conn
        |> put_flash(:info, "Cashier session updated successfully.")
        |> redirect(to: cashier_session_path(conn, :show, cashier_session))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", cashier_session: cashier_session, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    cashier_session = BN.get_cashier_session!(id)
    {:ok, _cashier_session} = BN.delete_cashier_session(cashier_session)

    conn
    |> put_flash(:info, "Cashier session deleted successfully.")
    |> redirect(to: cashier_session_path(conn, :index, BN.get_domain(conn)))
  end
end
