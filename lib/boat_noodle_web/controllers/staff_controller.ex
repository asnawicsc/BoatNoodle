defmodule BoatNoodleWeb.StaffController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Staff
  require IEx

  def index(conn, _params) do
    staff =
      Repo.all(
        from(
          s in Staff,
          left_join: r in BoatNoodle.BN.StaffType,
          on: s.staff_type_id == r.id,
          where: s.brand_id == ^BN.get_brand_id(conn),
          select: %{
            id: s.staff_id,
            staff_name: s.staff_name,
            staff_contact: s.staff_contact,
            staff_email: s.staff_email,
            staff_type_id: r.name
          }
        )
      )

    render(conn, "index.html", staff: staff)
  end

  def new(conn, _params) do
    changeset = Staff.changeset(%BoatNoodle.BN.Staff{}, %{}, BN.current_user(conn), "new")
    roles = BN.list_staff_type()
    roles = Enum.map(roles, fn x -> {x.name, x.id} end)
    branch_access = BN.list_branch()|>Enum.filter(fn x-> x.brand_id == BN.get_brand_id(conn) end)

    branch_access =
      Enum.map(branch_access, fn x -> {x.branchname, x.branchid} end)
      |> Enum.reject(fn x -> elem(x, 1) == 0 end)

    render(conn, "new.html", changeset: changeset, roles: roles, branches: branch_access)
  end

  def create(conn, %{"staff" => staff_params}) do
    branch_access =
      if conn.params["branch_ids"] == nil do
        ""
      else
        conn.params["branch_ids"] |> Map.keys() |> Enum.join(",")
      end

    staff =
      Repo.all(
        from(
          s in Staff,
          left_join: r in BoatNoodle.BN.StaffType,
          on: s.staff_type_id == r.id,
          where: s.brand_id == ^BN.get_brand_id(conn),
          select: %{
            id: s.staff_id,
            staff_name: s.staff_name,
            staff_contact: s.staff_contact,
            staff_email: s.staff_email,
            staff_type_id: r.name
          }
        )
      )

    staff_params = Map.put(staff_params, "branch_access", branch_access)
    staff_params = Map.put(staff_params, "staff_pin", "0000")
    staff_params = Map.put(staff_params, "brand_id", BN.get_brand_id(conn))
    staff_params = Map.put(staff_params, "branchid", "2")

    latest_staff_id =
      Repo.all(from(s in Staff))
      |> Enum.filter(fn x -> String.length(Integer.to_string(x.staff_id)) == 6 end)
      |> Enum.map(fn x -> x.staff_id end)
      |> Enum.sort()
      |> List.last()

    latest_staff_id = latest_staff_id + 1

    staff_params = Map.put(staff_params, "staff_id", latest_staff_id)


  
    changeset =
      BoatNoodle.BN.Staff.changeset(
        %BoatNoodle.BN.Staff{},
        staff_params,
        BN.current_user(conn),
        "Create"
      )

    case BoatNoodle.Repo.insert(changeset) do
      {:ok, _staff} ->
        conn =
          conn
          |> put_flash(:info, "Staff created successfully.")

        render(conn, "index.html", staff: staff)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    staff = BN.get_staff!(id)
    render(conn, "show.html", staff: staff)
  end

  def regenerate_pin(conn, %{"id" => id}) do
    staff = Repo.get_by(Staff, staff_id: id, brand_id: BN.get_brand_id(conn))

    existing_pins = Repo.all(from(s in Staff, select: s.staff_pin))
    numbers = 1000..9999
    new_pins = Enum.map(numbers, fn x -> x end)
    remaining_pins = new_pins -- existing_pins
    selected = Enum.random(remaining_pins)

    changeset =
      BoatNoodle.BN.Staff.changeset(
        staff,
        %{staff_pin: selected},
        BN.current_user(conn),
        "Update"
      )

    case Repo.update(changeset) do
      {:ok, staff} ->
        nil

      {:error, changeset} ->
        IO.inspect(changeset)
    end

    conn
    |> put_flash(:info, "Staff pin regenerated successfully.")
    |> redirect(to: staff_path(conn, :index, BN.get_domain(conn)))
  end

  def edit(conn, %{"id" => id}) do
    staff =
      Repo.all(
        from(s in Staff, where: s.staff_id == ^id and s.brand_id == ^BN.get_brand_id(conn))
      )
      |> hd()

    changeset = BoatNoodle.BN.Staff.changeset(staff, %{}, BN.current_user(conn), "edit")
    roles = BN.list_staff_type()
    roles = Enum.map(roles, fn x -> {x.name, x.id} end)

    branch_access = Repo.all(from(s in BN.Branch, where: s.brand_id == ^BN.get_brand_id(conn)))

    branch_access =
      Enum.map(branch_access, fn x -> {x.branchname, x.branchid} end)
      |> Enum.reject(fn x -> elem(x, 1) == 0 end)

    access =
      if staff.branch_access == nil do
        []
      else
        String.split(staff.branch_access, ",")
      end

    render(
      conn,
      "edit.html",
      staff: staff,
      access: access,
      changeset: changeset,
      roles: roles,
      branches: branch_access
    )
  end

  def update(conn, %{"id" => id, "staff" => staff_params}) do
    staff = Repo.get_by(Staff, staff_id: id, brand_id: BN.get_brand_id(conn))

    branch_access =
      if conn.params["branch_ids"] == nil do
        ""
      else
        conn.params["branch_ids"] |> Map.keys() |> Enum.join(",")
      end

    staff_params = Map.put(staff_params, "branch_access", branch_access)

    changeset =
      BoatNoodle.BN.Staff.changeset(staff, staff_params, BN.current_user(conn), "Update")

    case BoatNoodle.Repo.update(changeset) do
      {:ok, staff} ->
        conn
        |> put_flash(:info, "Staff updated successfully.")
        |> redirect(to: staff_path(conn, :index, BN.get_domain(conn)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", staff: staff, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    staff = BN.get_staff!(id)
    {:ok, _staff} = BN.delete_staff(staff)

    conn
    |> put_flash(:info, "Staff deleted successfully.")
    |> redirect(to: staff_path(conn, :index, BN.get_domain(conn)))
  end
end
