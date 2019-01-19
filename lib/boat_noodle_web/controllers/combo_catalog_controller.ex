defmodule BoatNoodleWeb.ComboCatalogController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.ComboCatalog

  def index(conn, _params) do
    combo_catalog = BN.list_combo_catalog()
    render(conn, "index.html", combo_catalog: combo_catalog)
  end

  def new(conn, _params) do
    changeset = BN.change_combo_catalog(%ComboCatalog{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"combo_catalog" => combo_catalog_params}) do
    case BN.create_combo_catalog(combo_catalog_params) do
      {:ok, combo_catalog} ->
        conn
        |> put_flash(:info, "Combo catalog created successfully.")
        |> redirect(to: combo_catalog_path(conn, :show, BN.get_domain(@conn), combo_catalog))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    combo_catalog = BN.get_combo_catalog!(id)
    render(conn, "show.html", combo_catalog: combo_catalog)
  end

  def edit(conn, %{"id" => id}) do
    combo_catalog = BN.get_combo_catalog!(id)
    changeset = BN.change_combo_catalog(combo_catalog)
    render(conn, "edit.html", combo_catalog: combo_catalog, changeset: changeset)
  end

  def update(conn, %{"id" => id, "combo_catalog" => combo_catalog_params}) do
    combo_catalog = BN.get_combo_catalog!(id)

    case BN.update_combo_catalog(combo_catalog, combo_catalog_params) do
      {:ok, combo_catalog} ->
        conn
        |> put_flash(:info, "Combo catalog updated successfully.")
        |> redirect(to: combo_catalog_path(conn, :show, combo_catalog))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", combo_catalog: combo_catalog, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    combo_catalog = BN.get_combo_catalog!(id)
    {:ok, _combo_catalog} = BN.delete_combo_catalog(combo_catalog)

    conn
    |> put_flash(:info, "Combo catalog deleted successfully.")
    |> redirect(to: combo_catalog_path(conn, :index, BN.get_domain(@conn)))
  end
end
