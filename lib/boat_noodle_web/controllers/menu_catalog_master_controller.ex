defmodule BoatNoodleWeb.MenuCatalogMasterController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.MenuCatalogMaster

  def index(conn, _params) do
    menu_catalog_master = BN.list_menu_catalog_master()
    render(conn, "index.html", menu_catalog_master: menu_catalog_master)
  end

  def new(conn, _params) do
    changeset = BN.change_menu_catalog_master(%MenuCatalogMaster{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"menu_catalog_master" => menu_catalog_master_params}) do
    case BN.create_menu_catalog_master(menu_catalog_master_params) do
      {:ok, menu_catalog_master} ->
        conn
        |> put_flash(:info, "Menu catalog master created successfully.")
        |> redirect(to: menu_catalog_master_path(conn, :show, menu_catalog_master))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    menu_catalog_master = BN.get_menu_catalog_master!(id)
    render(conn, "show.html", menu_catalog_master: menu_catalog_master)
  end

  def edit(conn, %{"id" => id}) do
    menu_catalog_master = BN.get_menu_catalog_master!(id)
    changeset = BN.change_menu_catalog_master(menu_catalog_master)
    render(conn, "edit.html", menu_catalog_master: menu_catalog_master, changeset: changeset)
  end

  def update(conn, %{"id" => id, "menu_catalog_master" => menu_catalog_master_params}) do
    menu_catalog_master = BN.get_menu_catalog_master!(id)

    case BN.update_menu_catalog_master(menu_catalog_master, menu_catalog_master_params) do
      {:ok, menu_catalog_master} ->
        conn
        |> put_flash(:info, "Menu catalog master updated successfully.")
        |> redirect(to: menu_catalog_master_path(conn, :show, menu_catalog_master))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", menu_catalog_master: menu_catalog_master, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    menu_catalog_master = BN.get_menu_catalog_master!(id)
    {:ok, _menu_catalog_master} = BN.delete_menu_catalog_master(menu_catalog_master)

    conn
    |> put_flash(:info, "Menu catalog master deleted successfully.")
    |> redirect(to: menu_catalog_master_path(conn, :index, BN.get_domain(conn)))
  end
end
