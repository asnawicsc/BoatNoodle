defmodule BoatNoodleWeb.ComboMapController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.ComboMap

  def index(conn, _params) do
    combo_map = BN.list_combo_map()
    render(conn, "index.html", combo_map: combo_map)
  end

  def new(conn, _params) do
    changeset = BN.change_combo_map(%ComboMap{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"combo_map" => combo_map_params}) do
    case BN.create_combo_map(combo_map_params) do
      {:ok, combo_map} ->
        conn
        |> put_flash(:info, "Combo map created successfully.")
        |> redirect(to: combo_map_path(conn, :show, combo_map))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    combo_map = BN.get_combo_map!(id)
    render(conn, "show.html", combo_map: combo_map)
  end

  def edit(conn, %{"id" => id}) do
    combo_map = BN.get_combo_map!(id)
    changeset = BN.change_combo_map(combo_map)
    render(conn, "edit.html", combo_map: combo_map, changeset: changeset)
  end

  def update(conn, %{"id" => id, "combo_map" => combo_map_params}) do
    combo_map = BN.get_combo_map!(id)

    case BN.update_combo_map(combo_map, combo_map_params) do
      {:ok, combo_map} ->
        conn
        |> put_flash(:info, "Combo map updated successfully.")
        |> redirect(to: combo_map_path(conn, :show, combo_map))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", combo_map: combo_map, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    combo_map = BN.get_combo_map!(id)
    {:ok, _combo_map} = BN.delete_combo_map(combo_map)

    conn
    |> put_flash(:info, "Combo map deleted successfully.")
    |> redirect(to: combo_map_path(conn, :index))
  end
end
