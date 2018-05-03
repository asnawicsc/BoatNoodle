defmodule BoatNoodleWeb.StaffLogSessionController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.StaffLogSession

  def index(conn, _params) do
    staff_log_session = BN.list_staff_log_session()
    render(conn, "index.html", staff_log_session: staff_log_session)
  end

  def new(conn, _params) do
    changeset = BN.change_staff_log_session(%StaffLogSession{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"staff_log_session" => staff_log_session_params}) do
    case BN.create_staff_log_session(staff_log_session_params) do
      {:ok, staff_log_session} ->
        conn
        |> put_flash(:info, "Staff log session created successfully.")
        |> redirect(to: staff_log_session_path(conn, :show, staff_log_session))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    staff_log_session = BN.get_staff_log_session!(id)
    render(conn, "show.html", staff_log_session: staff_log_session)
  end

  def edit(conn, %{"id" => id}) do
    staff_log_session = BN.get_staff_log_session!(id)
    changeset = BN.change_staff_log_session(staff_log_session)
    render(conn, "edit.html", staff_log_session: staff_log_session, changeset: changeset)
  end

  def update(conn, %{"id" => id, "staff_log_session" => staff_log_session_params}) do
    staff_log_session = BN.get_staff_log_session!(id)

    case BN.update_staff_log_session(staff_log_session, staff_log_session_params) do
      {:ok, staff_log_session} ->
        conn
        |> put_flash(:info, "Staff log session updated successfully.")
        |> redirect(to: staff_log_session_path(conn, :show, staff_log_session))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", staff_log_session: staff_log_session, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    staff_log_session = BN.get_staff_log_session!(id)
    {:ok, _staff_log_session} = BN.delete_staff_log_session(staff_log_session)

    conn
    |> put_flash(:info, "Staff log session deleted successfully.")
    |> redirect(to: staff_log_session_path(conn, :index))
  end
end
