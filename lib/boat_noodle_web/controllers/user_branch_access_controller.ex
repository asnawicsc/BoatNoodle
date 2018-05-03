defmodule BoatNoodleWeb.UserBranchAccessController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.UserBranchAccess

  def index(conn, _params) do
    user_branch_access = BN.list_user_branch_access()
    render(conn, "index.html", user_branch_access: user_branch_access)
  end

  def new(conn, _params) do
    changeset = BN.change_user_branch_access(%UserBranchAccess{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_branch_access" => user_branch_access_params}) do
    case BN.create_user_branch_access(user_branch_access_params) do
      {:ok, user_branch_access} ->
        conn
        |> put_flash(:info, "User branch access created successfully.")
        |> redirect(to: user_branch_access_path(conn, :show, user_branch_access))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_branch_access = BN.get_user_branch_access!(id)
    render(conn, "show.html", user_branch_access: user_branch_access)
  end

  def edit(conn, %{"id" => id}) do
    user_branch_access = BN.get_user_branch_access!(id)
    changeset = BN.change_user_branch_access(user_branch_access)
    render(conn, "edit.html", user_branch_access: user_branch_access, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user_branch_access" => user_branch_access_params}) do
    user_branch_access = BN.get_user_branch_access!(id)

    case BN.update_user_branch_access(user_branch_access, user_branch_access_params) do
      {:ok, user_branch_access} ->
        conn
        |> put_flash(:info, "User branch access updated successfully.")
        |> redirect(to: user_branch_access_path(conn, :show, user_branch_access))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user_branch_access: user_branch_access, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_branch_access = BN.get_user_branch_access!(id)
    {:ok, _user_branch_access} = BN.delete_user_branch_access(user_branch_access)

    conn
    |> put_flash(:info, "User branch access deleted successfully.")
    |> redirect(to: user_branch_access_path(conn, :index))
  end
end
