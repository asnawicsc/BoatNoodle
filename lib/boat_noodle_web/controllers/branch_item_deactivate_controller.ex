defmodule BoatNoodleWeb.BranchItemDeactivateController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.BranchItemDeactivate

  def index(conn, _params) do
    branch_item_deactivate = BN.list_branch_item_deactivate()
    render(conn, "index.html", branch_item_deactivate: branch_item_deactivate)
  end

  def new(conn, _params) do
    changeset = BN.change_branch_item_deactivate(%BranchItemDeactivate{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"branch_item_deactivate" => branch_item_deactivate_params}) do
    case BN.create_branch_item_deactivate(branch_item_deactivate_params) do
      {:ok, branch_item_deactivate} ->
        conn
        |> put_flash(:info, "Branch item deactivate created successfully.")
        |> redirect(to: branch_item_deactivate_path(conn, :show, branch_item_deactivate))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    branch_item_deactivate = BN.get_branch_item_deactivate!(id)
    render(conn, "show.html", branch_item_deactivate: branch_item_deactivate)
  end

  def edit(conn, %{"id" => id}) do
    branch_item_deactivate = BN.get_branch_item_deactivate!(id)
    changeset = BN.change_branch_item_deactivate(branch_item_deactivate)
    render(conn, "edit.html", branch_item_deactivate: branch_item_deactivate, changeset: changeset)
  end

  def update(conn, %{"id" => id, "branch_item_deactivate" => branch_item_deactivate_params}) do
    branch_item_deactivate = BN.get_branch_item_deactivate!(id)

    case BN.update_branch_item_deactivate(branch_item_deactivate, branch_item_deactivate_params) do
      {:ok, branch_item_deactivate} ->
        conn
        |> put_flash(:info, "Branch item deactivate updated successfully.")
        |> redirect(to: branch_item_deactivate_path(conn, :show, branch_item_deactivate))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", branch_item_deactivate: branch_item_deactivate, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    branch_item_deactivate = BN.get_branch_item_deactivate!(id)
    {:ok, _branch_item_deactivate} = BN.delete_branch_item_deactivate(branch_item_deactivate)

    conn
    |> put_flash(:info, "Branch item deactivate deleted successfully.")
    |> redirect(to: branch_item_deactivate_path(conn, :index))
  end
end
