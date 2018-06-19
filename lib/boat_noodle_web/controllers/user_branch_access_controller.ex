defmodule BoatNoodleWeb.UserBranchAccessController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.UserBranchAccess

  def index(conn, _params) do
    user =
      Repo.all(
        from(
          u in User,
          left_join: r in UserRole,
          on: u.roleid == r.roleid,
          select: %{
            id: u.id,
            username: u.username,
            email: u.email,
            roleid: r.role_name,
            manager_access: u.manager_access
          },
          order_by: [u.username]
        )
      )

    manager_access_users = user |> Enum.filter(fn x -> x.manager_access == 1 end)
    # branch access
    # list all the users with manager access
    uba = Repo.all(from(u in UserBranchAccess)) |> Enum.group_by(fn x -> x.userid end)

    # list each users branch ids
    # find all branches
    branches =
      Repo.all(
        from(b in Branch, select: %{name: b.branchname, id: b.branchid}, order_by: [b.branchname])
      )

    staff =
      Repo.all(
        from(
          s in Staff,
          left_join: r in BoatNoodle.BN.StaffType,
          on: s.staff_type_id == r.id,
          select: %{
            id: s.staff_id,
            staff_name: s.staff_name,
            staff_contact: s.staff_contact,
            staff_email: s.staff_email,
            staff_type_id: r.name
          }
        )
      )

    render(
      conn,
      "index.html",
      user: user,
      branches: branches,
      manager_access_users: manager_access_users,
      uba: uba,
      staff: staff
    )
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
    |> redirect(to: user_branch_access_path(conn, :index, BN.get_domain(conn)))
  end
end
