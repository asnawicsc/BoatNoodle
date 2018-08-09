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

    if Enum.any?(items, fn x -> x == subcat_id end) do
      items = List.delete(items, subcat_id) |> Enum.sort() |> Enum.join(",")

      MenuCatalog.changeset(cata, %{items: items}, BN.current_user(conn), "Insert")
      |> Repo.update()
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

    if String.length(subcat_id) == 6 do
      details =
        Repo.all(from(c in ComboDetails, where: c.combo_id == ^subcat_id, select: c.id))
        |> Enum.map(fn x -> Integer.to_string(x) end)

      item_details = Repo.all(from(i in ItemSubcat, where: i.itemcatid == ^subcat_id))
    else
      unless Enum.any?(items, fn x -> x == subcat_id end) do
        items = List.insert_at(items, 0, subcat_id) |> Enum.sort() |> Enum.join(",")

        MenuCatalog.changeset(cata, %{items: items}, BN.current_user(conn), "Insert")
        |> Repo.update()
      end
    end

    send_resp(conn, 200, "ok")

    # figure out if this is a combo.. normally wth 6 digits..
    # if its a combo, then check in the combo details if there's any combo id matches the current subcat id
    # if yes, then the combo details id are to be inserted in the menu catalog's combo items column
    # if no, then the combo is non selection to be inserted in the items column
  end

  def list_menu_catalog(conn, %{"brand" => brand, "subcatid" => subcat_id}) do
    item_subcat = Repo.get_by(ItemSubcat, subcatid: subcat_id, brand_id: BN.get_brand_id(conn))

    catalogs_ori =
      Repo.all(
        from(
          m in MenuCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: %{id: m.id, name: m.name, items: m.items}
        )
      )
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

  def list_menu_catalog_combo(conn, %{"brand" => brand, "subcatid" => subcat_id}) do
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

  def remove_from_catalog_combo(conn, %{
        "brand" => brand,
        "subcat_id" => subcat_id,
        "tag_id" => catalog_id
      }) do
    cata = Repo.get_by(MenuCatalog, id: catalog_id, brand_id: BN.get_brand_id(conn))
    items = cata.items |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

    combo_items =
      cata.combo_items |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

    details =
      Repo.all(from(c in ComboDetails, where: c.combo_id == ^subcat_id, select: c.id))
      |> Enum.map(fn x -> Integer.to_string(x) end)

    if details != [] do
      for item <- details do
        list = List.delete(combo_items, item) |> Enum.sort() |> Enum.join(",")

        MenuCatalog.changeset(cata, %{combo_items: list}, BN.current_user(conn), "Insert")
        |> Repo.update()
      end

      list2 = List.delete(items, subcat_id) |> Enum.sort() |> Enum.join(",")

      MenuCatalog.changeset(cata, %{items: list2}, BN.current_user(conn), "Insert")
      |> Repo.update()
    else
      items = List.delete(items, subcat_id) |> Enum.sort() |> Enum.join(",")

      MenuCatalog.changeset(cata, %{items: items}, BN.current_user(conn), "Insert")
      |> Repo.update()
    end

    send_resp(conn, 200, "ok")
  end

  def insert_into_catalog_combo(conn, %{
        "brand" => brand,
        "subcat_id" => subcat_id,
        "tag_id" => catalog_id
      }) do
    cata = Repo.get_by(MenuCatalog, id: catalog_id, brand_id: BN.get_brand_id(conn))
    items = cata.items |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

    combo_items =
      cata.combo_items |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

    if String.length(subcat_id) == 6 do
      details =
        Repo.all(from(c in ComboDetails, where: c.combo_id == ^subcat_id, select: c.id))
        |> Enum.map(fn x -> Integer.to_string(x) end)

      if details != [] do
        for item <- details do
          list = List.insert_at(combo_items, 0, item) |> Enum.sort() |> Enum.join(",")

          MenuCatalog.changeset(cata, %{combo_items: list}, BN.current_user(conn), "Insert")
          |> Repo.update()
        end

        list2 = List.insert_at(items, 0, subcat_id) |> Enum.sort() |> Enum.join(",")

        MenuCatalog.changeset(cata, %{items: list2}, BN.current_user(conn), "Insert")
        |> Repo.update()
      else
        items = List.insert_at(items, 0, subcat_id) |> Enum.sort() |> Enum.join(",")

        MenuCatalog.changeset(cata, %{items: items}, BN.current_user(conn), "Insert")
        |> Repo.update()
      end
    else
      unless Enum.any?(items, fn x -> x == subcat_id end) do
        items = List.insert_at(items, 0, subcat_id) |> Enum.sort() |> Enum.join(",")

        MenuCatalog.changeset(cata, %{items: items}, BN.current_user(conn), "Insert")
        |> Repo.update()
      end
    end

    send_resp(conn, 200, "ok")

    # figure out if this is a combo.. normally wth 6 digits..
    # if its a combo, then check in the combo details if there's any combo id matches the current subcat id
    # if yes, then the combo details id are to be inserted in the menu catalog's combo items column
    # if no, then the combo is non selection to be inserted in the items column
  end

  def index(conn, _params) do
    menu_catalog = Repo.all(from(m in MenuCatalog, where: m.brand_id == ^BN.get_brand_id(conn)))

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

    user = BoatNoodle.Repo.get_by(BoatNoodle.BN.User, id: conn.private.plug_session["user_id"])

    admin_menus =
      BoatNoodle.Repo.all(
        from(
          b in BoatNoodle.BN.UnauthorizeMenu,
          left_join: g in BoatNoodle.BN.User,
          on: b.role_id == g.roleid,
          left_join: c in BoatNoodle.BN.UserRole,
          on: g.roleid == c.roleid,
          where: g.id == ^user.id and b.active == 1
        )
      )
      |> Enum.map(fn x -> x.url end)

    a = conn.path_info |> List.delete_at(2)
    b = "edit"
    c = List.insert_at(a, 2, b)
    d = c |> Enum.join("/")
    e = "/"
    url = e <> d

    render(
      conn,
      "index.html",
      menu_catalogs: menu_catalog,
      itemcodes: itemcodes,
      arranged_items: arranged_items,
      url: url,
      admin_menus: admin_menus
    )
  end

  def new(conn, _params) do
    changeset =
      MenuCatalog.changeset(%BoatNoodle.BN.MenuCatalog{}, %{}, BN.current_user(conn), "new")

    cata =
      Repo.all(
        from(
          c in MenuCatalog,
          where: c.brand_id == ^BN.get_brand_id(conn),
          select: {c.name, c.id}
        )
      )

    render(conn, "new.html", changeset: changeset, cata: cata)
  end

  def create(conn, %{"menu_catalog" => menu_catalog_params}) do
    menu_catalog_params = Map.put(menu_catalog_params, "brand_id", BN.get_brand_id(conn))

    if menu_catalog_params["id"] != "" do
      dup_men =
        Repo.get_by(MenuCatalog, id: menu_catalog_params["id"], brand_id: BN.get_brand_id(conn))

      add_params = %{
        "categories" => dup_men.categories,
        "items" => dup_men.items,
        "combo_items" => dup_men.combo_items
      }

      menu_catalog_params = Map.merge(menu_catalog_params, add_params)
    end

    menu_catalog_params = Map.delete(menu_catalog_params, "id")

    changeset =
      BoatNoodle.BN.MenuCatalog.changeset(
        %BoatNoodle.BN.MenuCatalog{},
        menu_catalog_params,
        BN.current_user(conn),
        "Create"
      )

    case BoatNoodle.Repo.insert(changeset) do
      {:ok, menu_catalog} ->
        conn
        |> put_flash(:info, "Menu catalog created successfully.")
        |> redirect(to: menu_catalog_path(conn, :index, BN.get_domain(conn)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    menu_catalog = Repo.get_by(MenuCatalog, id: id, brand_id: BN.get_brand_id(conn))
    render(conn, "show.html", menu_catalog: menu_catalog)
  end

  def edit(conn, %{"id" => id}) do
    menu_catalog = Repo.get_by(MenuCatalog, id: id, brand_id: BN.get_brand_id(conn))
    changeset = BN.change_menu_catalog(menu_catalog)
    render(conn, "edit.html", menu_catalog: menu_catalog, changeset: changeset)
  end

  def update(conn, %{"id" => id, "menu_catalog" => menu_catalog_params}) do
    menu_catalog = Repo.get_by(MenuCatalog, id: id, brand_id: BN.get_brand_id(conn))

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
    user = BoatNoodle.Repo.get_by(BoatNoodle.BN.User, id: conn.private.plug_session["user_id"])

    admin_menus =
      BoatNoodle.Repo.all(
        from(
          b in BoatNoodle.BN.UnauthorizeMenu,
          left_join: g in BoatNoodle.BN.User,
          on: b.role_id == g.roleid,
          left_join: c in BoatNoodle.BN.UserRole,
          on: g.roleid == c.roleid,
          where: g.id == ^user.id and b.active == 1
        )
      )
      |> Enum.map(fn x -> x.url end)

    path = conn.path_info |> List.delete_at(2)
    a = "delete"
    b = List.insert_at(path, 2, a) |> Enum.join("/")
    url = "/" <> b

    if Enum.any?(admin_menus, fn x -> x == url end) do
      conn
      |> put_flash(:info, "Unauthorize Access.")
      |> redirect(to: menu_catalog_path(conn, :index, BN.get_domain(conn)))
    else
      menu_catalog = Repo.get_by(MenuCatalog, id: id, brand_id: BN.get_brand_id(conn))

      changeset =
        BoatNoodle.BN.MenuCatalog.changeset(menu_catalog, %{}, BN.current_user(conn), "delete")

      {:ok, _menu_catalog} = BoatNoodle.Repo.delete(changeset)

      conn
      |> put_flash(:info, "Menu catalog deleted successfully.")
      |> redirect(to: menu_catalog_path(conn, :index, BN.get_domain(conn)))
    end
  end
end
