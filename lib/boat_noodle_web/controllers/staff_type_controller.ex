defmodule BoatNoodleWeb.StaffTypeController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.StaffType

  def index(conn, _params) do
    staff_type = BN.list_staff_type()
    render(conn, "index.html", staff_type: staff_type)
  end

  def new(conn, _params) do
    changeset = BN.change_staff_type(%StaffType{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"staff_type" => staff_type_params}) do
    case BN.create_staff_type(staff_type_params) do
      {:ok, staff_type} ->
        conn
        |> put_flash(:info, "Staff type created successfully.")
        |> redirect(to: staff_type_path(conn, :show, staff_type))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    staff_type = BN.get_staff_type!(id)
    render(conn, "show.html", staff_type: staff_type)
  end

  def edit(conn, %{"id" => id}) do
    staff_type = BN.get_staff_type!(id)
    changeset = BN.change_staff_type(staff_type)
    render(conn, "edit.html", staff_type: staff_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "staff_type" => staff_type_params}) do
    staff_type = BN.get_staff_type!(id)

    case BN.update_staff_type(staff_type, staff_type_params) do
      {:ok, staff_type} ->
        conn
        |> put_flash(:info, "Staff type updated successfully.")
        |> redirect(to: staff_type_path(conn, :show, staff_type))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", staff_type: staff_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    staff_type = BN.get_staff_type!(id)
    {:ok, _staff_type} = BN.delete_staff_type(staff_type)

    conn
    |> put_flash(:info, "Staff type deleted successfully.")
    |> redirect(to: staff_type_path(conn, :index))
  end
end
