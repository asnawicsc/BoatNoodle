defmodule BoatNoodleWeb.UserController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.User
  require(IEx)

  def index(conn, _params) do
    user = Repo.all(User)
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

  def login(conn, params) do
    render(conn, "login.html", layout: {BoatNoodleWeb.LayoutView, "login.html"})
  end

  def authenticate_login(conn, %{"username" => username, "password" => password}) do
    # IEx.pry()

    user = Repo.get_by(User, username: username)

    if user != nil do
      conn
      |> put_session(:user_id, user.id)
      |> put_flash(:info, "Login.")
      |> redirect(to: user_path(conn, :index))
    else
      conn
      |> put_flash(:info, "User not found.")
      |> redirect(to: user_path(conn, :login))
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "User not found.")
    |> redirect(to: user_path(conn, :login))
  end
end
