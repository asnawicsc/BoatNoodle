defmodule BoatNoodleWeb.ModalLogController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.ModalLog

  def index(conn, _params) do
    modal_logs = BN.list_modal_logs()
    render(conn, "index.html", modal_logs: modal_logs)
  end

  def new(conn, _params) do
    changeset = BN.change_modal_log(%ModalLog{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"modal_log" => modal_log_params}) do
    case BN.create_modal_log(modal_log_params) do
      {:ok, modal_log} ->
        conn
        |> put_flash(:info, "Modal log created successfully.")
        |> redirect(to: modal_log_path(conn, :show,BN.get_domain(@conn), modal_log))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    modal_log = BN.get_modal_log!(id)
    render(conn, "show.html", modal_log: modal_log)
  end

  def edit(conn, %{"id" => id}) do
    modal_log = BN.get_modal_log!(id)
    changeset = BN.change_modal_log(modal_log)
    render(conn, "edit.html", modal_log: modal_log, changeset: changeset)
  end

  def update(conn, %{"id" => id, "modal_log" => modal_log_params}) do
    modal_log = BN.get_modal_log!(id)

    case BN.update_modal_log(modal_log, modal_log_params) do
      {:ok, modal_log} ->
        conn
        |> put_flash(:info, "Modal log updated successfully.")
        |> redirect(to: modal_log_path(conn, :show,BN.get_domain(@conn), modal_log))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", modal_log: modal_log, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    modal_log = BN.get_modal_log!(id)
    {:ok, _modal_log} = BN.delete_modal_log(modal_log)

    conn
    |> put_flash(:info, "Modal log deleted successfully.")
    |> redirect(to: modal_log_path(conn, :index,BN.get_domain(@conn)))
  end
end
