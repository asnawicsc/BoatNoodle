defmodule BoatNoodleWeb.BranchController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Branch

  def index(conn, _params) do
    branch = Repo.all(Branch)
    render(conn, "index.html", branch: branch)
  end

  def new(conn, _params) do
    changeset = BN.change_branch(%Branch{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"branch" => branch_params}) do
    case BN.create_branch(branch_params) do
      {:ok, branch} ->
        conn
        |> put_flash(:info, "Branch created successfully.")
        |> redirect(to: branch_path(conn, :show, branch))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    branch = BN.get_branch!(id)
    render(conn, "show.html", branch: branch)
  end

  def edit(conn, %{"id" => id}) do
    branch = BN.get_branch!(id)
    changeset = BN.change_branch(branch)
    render(conn, "edit.html", branch: branch, changeset: changeset)
  end

  def update(conn, %{"id" => id, "branch" => branch_params}) do
    branch = BN.get_branch!(id)

    case BN.update_branch(branch, branch_params) do
      {:ok, branch} ->
        conn
        |> put_flash(:info, "Branch updated successfully.")
        |> redirect(to: branch_path(conn, :show, branch))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", branch: branch, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    branch = BN.get_branch!(id)
    {:ok, _branch} = BN.delete_branch(branch)

    conn
    |> put_flash(:info, "Branch deleted successfully.")
    |> redirect(to: branch_path(conn, :index))
  end
end
