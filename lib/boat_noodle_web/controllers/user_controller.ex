defmodule BoatNoodleWeb.UserController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.User

  def index(conn, _params) do
    user = BN.list_user()
    render(conn, "index.html", user: user)
  end

  def new(conn, _params) do
    changeset = BN.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case BN.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = BN.get_user!(id)
    render(conn, "show.html", user: user)
  end

   def edit_user(conn, params) do

    render(conn, "edit_user.html")
  end

  def edit(conn, %{"id" => id}) do
    user = BN.get_user!(id)
    changeset = BN.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = BN.get_user!(id)

    case BN.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = BN.get_user!(id)
    {:ok, _user} = BN.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end
