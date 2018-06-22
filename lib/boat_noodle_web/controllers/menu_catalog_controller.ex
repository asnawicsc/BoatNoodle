defmodule BoatNoodleWeb.MenuCatalogController do
  use BoatNoodleWeb, :controller
  require IEx
  alias BoatNoodle.BN
  alias BoatNoodle.BN.MenuCatalog

  def remove_from_catalog(conn, %{
        "brand" => brand,
        "subcat_id" => subcat_id,
        "tag_id" => catalog_id
      }) do
    cata = Repo.get_by(MenuCatalog, id: catalog_id, brand_id: BN.get_brand_id(conn))
    items = cata.items |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)
    # write the menu catalog 
    # get the items from the menu catalog
    # split and join

    if Enum.any?(items, fn x -> x == subcat_id end) do
      # insert...
      items = List.delete(items, subcat_id) |> Enum.sort() |> Enum.join(",")
      MenuCatalog.changeset(cata, %{items: items}) |> Repo.update()
    end

    send_resp(conn, 200, "ok")
  end

  def insert_into_catalog(conn, %{
        "brand" => brand,
        "subcat_id" => subcat_id,
        "tag_id" => catalog_id
      }) do
    cata = Repo.get_by(MenuCatalog, id: catalog_id, brand_id: BN.get_brand_id(conn))
    items = cata.items |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)
    # write the menu catalog 
    # get the items from the menu catalog
    # split and join

    unless Enum.any?(items, fn x -> x == subcat_id end) do
      # insert...
      items = List.insert_at(items, 0, subcat_id) |> Enum.sort() |> Enum.join(",")
      MenuCatalog.changeset(cata, %{items: items}) |> Repo.update()
    end

    send_resp(conn, 200, "ok")
  end

  def list_menu_catalog(conn, %{"brand" => brand, "subcatid" => subcat_id}) do
    item_subcat = Repo.get_by(ItemSubcat, subcatid: subcat_id, brand_id: BN.get_brand_id(conn))

    catalogs_ori =
      Repo.all(from(m in MenuCatalog, select: %{id: m.id, name: m.name, items: m.items}))
      |> Enum.map(fn x -> Map.put(x, :items, String.split(x.items, ",")) end)

    catalogs =
      for catalog <- catalogs_ori do
        if Enum.any?(catalog.items, fn x -> x == subcat_id end) do
          catalog
        else
          nil
        end
      end
      |> Enum.reject(fn x -> x == nil end)
      |> Enum.map(fn x -> %{id: x.id, name: x.name} end)

    all_cata = catalogs_ori |> Enum.map(fn x -> %{id: x.id, name: x.name} end)
    not_selected = all_cata -- catalogs

    json = %{selected: catalogs, not_selected: not_selected} |> Poison.encode!()
    send_resp(conn, 200, json)
  end

  def index(conn, _params) do
    menu_catalog = Repo.all(from(m in MenuCatalog))

    arranged_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.is_delete == ^0 and s.is_comboitem == ^0 and s.brand_id == ^BN.get_brand_id(conn),
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

    render(
      conn,
      "index.html",
      menu_catalogs: menu_catalog,
      itemcodes: itemcodes,
      arranged_items: arranged_items
    )
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
    |> redirect(to: menu_catalog_path(conn, :index, BN.get_domain(conn)))
  end
end
