defmodule BoatNoodleWeb.MenuItemController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.MenuItem

  def index(conn, _params) do
    menu_item = Repo.all(MenuItem)
    render(conn, "index.html", menu_item: menu_item)
  end

  def new(conn, _params) do
    changeset = BN.change_menu_item(%MenuItem{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"menu_item" => menu_item_params}) do
    case BN.create_menu_item(menu_item_params) do
      {:ok, menu_item} ->
        conn
        |> put_flash(:info, "Menu item created successfully.")
        |> redirect(to: menu_item_path(conn, :show, menu_item))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    menu_item = BN.get_menu_item!(id)
    render(conn, "show.html", menu_item: menu_item)
  end

  def edit(conn, %{"id" => id}) do
    menu_item = BN.get_menu_item!(id)
    changeset = BN.change_menu_item(menu_item)
    render(conn, "edit.html", menu_item: menu_item, changeset: changeset)
  end

  def update(conn, %{"id" => id, "menu_item" => menu_item_params}) do
    menu_item = BN.get_menu_item!(id)

    case BN.update_menu_item(menu_item, menu_item_params) do
      {:ok, menu_item} ->
        conn
        |> put_flash(:info, "Menu item updated successfully.")
        |> redirect(to: menu_item_path(conn, :show, menu_item))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", menu_item: menu_item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    menu_item = BN.get_menu_item!(id)
    {:ok, _menu_item} = BN.delete_menu_item(menu_item)

    conn
    |> put_flash(:info, "Menu item deleted successfully.")
    |> redirect(to: menu_item_path(conn, :index))
  end
end
