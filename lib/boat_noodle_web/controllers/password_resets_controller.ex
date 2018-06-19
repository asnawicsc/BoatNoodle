defmodule BoatNoodleWeb.PasswordResetsController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.PasswordResets

  def index(conn, _params) do
    password_resets = BN.list_password_resets()
    render(conn, "index.html", password_resets: password_resets)
  end

  def new(conn, _params) do
    changeset = BN.change_password_resets(%PasswordResets{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"password_resets" => password_resets_params}) do
    case BN.create_password_resets(password_resets_params) do
      {:ok, password_resets} ->
        conn
        |> put_flash(:info, "Password resets created successfully.")
        |> redirect(to: password_resets_path(conn, :show, password_resets))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    password_resets = BN.get_password_resets!(id)
    render(conn, "show.html", password_resets: password_resets)
  end

  def edit(conn, %{"id" => id}) do
    password_resets = BN.get_password_resets!(id)
    changeset = BN.change_password_resets(password_resets)
    render(conn, "edit.html", password_resets: password_resets, changeset: changeset)
  end

  def update(conn, %{"id" => id, "password_resets" => password_resets_params}) do
    password_resets = BN.get_password_resets!(id)

    case BN.update_password_resets(password_resets, password_resets_params) do
      {:ok, password_resets} ->
        conn
        |> put_flash(:info, "Password resets updated successfully.")
        |> redirect(to: password_resets_path(conn, :show, password_resets))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", password_resets: password_resets, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    password_resets = BN.get_password_resets!(id)
    {:ok, _password_resets} = BN.delete_password_resets(password_resets)

    conn
    |> put_flash(:info, "Password resets deleted successfully.")
    |> redirect(to: password_resets_path(conn, :index, BN.get_domain(conn)))
  end
end
