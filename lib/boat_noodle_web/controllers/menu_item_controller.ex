defmodule BoatNoodleWeb.MenuItemController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.{MenuItem, MenuCatalog, ItemSubcat, ItemCat}

  require IEx

  def index(conn, _params) do
    combo_menus =
      Repo.all(
        from(
          i in ItemSubcat,
          left_join: c in ItemCat,
          on: c.itemcatid == i.itemcatid,
          where: c.category_type == ^"COMBO",
          group_by: [i.itemcode],
          select: %{
            itemcode: i.itemcode,
            subcatid: i.subcatid,
            itemname: i.itemname,
            itemcatname: c.itemcatname
          }
        )
      )

    menu_catalog = Repo.all(from(m in MenuCatalog))

    arranged_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where: s.is_delete == ^0 and s.is_combo == ^0 and s.is_comboitem == ^0,
          select: %{
            subcatid: s.subcatid,
            item_code: s.itemcode,
            price_code: s.price_code,
            itemprice: s.itemprice
          },
          order_by: [asc: s.itemcode]
        )
      )
      |> Enum.group_by(fn x -> x.item_code end)

    itemcodes = arranged_items |> Map.keys() |> Enum.sort()

    subcats =
      Repo.all(
        from(
          s in ItemSubcat,
          left_join: c in ItemCat,
          on: c.itemcatid == s.itemcatid,
          where: s.is_combo == ^0 and s.is_comboitem == ^0 and s.is_delete == ^0,
          group_by: [s.itemname, s.itemcatid],
          select: %{
            category: c.itemcatname,
            itemcatid: s.itemcatid,
            itemname: s.itemname,
            subcatid: s.subcatid,
            itemcode: s.itemcode
          }
        )
      )

    render(
      conn,
      "index.html",
      menu_catalog: menu_catalog,
      subcats: subcats,
      itemcodes: itemcodes,
      arranged_items: arranged_items,
      combo_menus: combo_menus
    )
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
