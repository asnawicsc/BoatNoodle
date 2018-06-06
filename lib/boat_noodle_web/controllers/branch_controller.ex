defmodule BoatNoodleWeb.BranchController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.{Branch, Organization, User}
  require IEx

  def index(conn, _params) do
    branch =
      Repo.all(
        from(
          b in Branch,
          left_join: o in Organization,
          on: b.org_id == o.organisationid,
          left_join: u in User,
          on: u.id == b.manager,
          select: %{
            branchid: b.branchid,
            branchname: b.branchname,
            branchcode: b.branchcode,
            b_address: b.b_address,
            org_id: o.organisationname,
            manager: u.username,
            num_staff: b.num_staff,
            sync_status: b.sync_status
          }
        )
      )

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

    managers =
      BN.list_user() |> Enum.map(fn x -> {x.username, x.id} end)
      |> Enum.sort_by(fn x -> elem(x, 0) end)

    organizations =
      BN.list_organization() |> Enum.map(fn x -> {x.organisationname, x.organisationid} end)
      |> Enum.sort_by(fn x -> elem(x, 0) end)

    render(
      conn,
      "edit.html",
      branch: branch,
      changeset: changeset,
      managers: managers,
      organizations: organizations
    )
  end

  def update(conn, %{"id" => id, "branch" => branch_params}) do
    branch = BN.get_branch!(id)

    case BN.update_branch(branch, branch_params) do
      {:ok, branch} ->
        conn
        |> put_flash(:info, "Branch updated successfully.")
        |> redirect(to: branch_path(conn, :index))

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
