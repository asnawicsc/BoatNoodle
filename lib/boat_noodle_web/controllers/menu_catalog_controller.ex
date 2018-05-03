defmodule BoatNoodleWeb.MenuCatalogController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.MenuCatalog

  def index(conn, _params) do
    menu_catalog = Repo.all(MenuCatalog)
    render(conn, "index.html", menu_catalog: menu_catalog)
  end

  def new(conn, _params) do
    changeset = BN.change_menu_catalog(%MenuCatalog{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"menu_catalog" => menu_catalog_params}) do
    case BN.create_menu_catalog(menu_catalog_params) do
      {:ok, menu_catalog} ->
        conn
        |> put_flash(:info, "Menu catalog created successfully.")
        |> redirect(to: menu_catalog_path(conn, :show, menu_catalog))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    menu_catalog = BN.get_menu_catalog!(id)
    render(conn, "show.html", menu_catalog: menu_catalog)
  end

  def edit(conn, %{"id" => id}) do
    menu_catalog = BN.get_menu_catalog!(id)
    changeset = BN.change_menu_catalog(menu_catalog)
    render(conn, "edit.html", menu_catalog: menu_catalog, changeset: changeset)
  end

  def update(conn, %{"id" => id, "menu_catalog" => menu_catalog_params}) do
    menu_catalog = BN.get_menu_catalog!(id)

    case BN.update_menu_catalog(menu_catalog, menu_catalog_params) do
      {:ok, menu_catalog} ->
        conn
        |> put_flash(:info, "Menu catalog updated successfully.")
        |> redirect(to: menu_catalog_path(conn, :show, menu_catalog))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", menu_catalog: menu_catalog, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    menu_catalog = BN.get_menu_catalog!(id)
    {:ok, _menu_catalog} = BN.delete_menu_catalog(menu_catalog)

    conn
    |> put_flash(:info, "Menu catalog deleted successfully.")
    |> redirect(to: menu_catalog_path(conn, :index))
  end
end
