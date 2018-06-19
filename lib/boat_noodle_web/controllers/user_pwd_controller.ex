defmodule BoatNoodleWeb.UserPwdController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.UserPwd

  def index(conn, _params) do
    user_pwd = BN.list_user_pwd()
    render(conn, "index.html", user_pwd: user_pwd)
  end

  def new(conn, _params) do
    changeset = BN.change_user_pwd(%UserPwd{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_pwd" => user_pwd_params}) do
    case BN.create_user_pwd(user_pwd_params) do
      {:ok, user_pwd} ->
        conn
        |> put_flash(:info, "User pwd created successfully.")
        |> redirect(to: user_pwd_path(conn, :show, user_pwd))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_pwd = BN.get_user_pwd!(id)
    render(conn, "show.html", user_pwd: user_pwd)
  end

  def edit(conn, %{"id" => id}) do
    user_pwd = BN.get_user_pwd!(id)
    changeset = BN.change_user_pwd(user_pwd)
    render(conn, "edit.html", user_pwd: user_pwd, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user_pwd" => user_pwd_params}) do
    user_pwd = BN.get_user_pwd!(id)

    case BN.update_user_pwd(user_pwd, user_pwd_params) do
      {:ok, user_pwd} ->
        conn
        |> put_flash(:info, "User pwd updated successfully.")
        |> redirect(to: user_pwd_path(conn, :show, user_pwd))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user_pwd: user_pwd, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_pwd = BN.get_user_pwd!(id)
    {:ok, _user_pwd} = BN.delete_user_pwd(user_pwd)

    conn
    |> put_flash(:info, "User pwd deleted successfully.")
    |> redirect(to: user_pwd_path(conn, :index, BN.get_domain(conn)))
  end
end
