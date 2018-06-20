defmodule BoatNoodleWeb.MenuItemController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.{MenuItem, MenuCatalog, ItemSubcat, ItemCat, Remark}

  require IEx

  def combos(conn, _params) do
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

    render(
      conn,
      "combo.html",
      combo_menus: combo_menus
    )
  end

  def index(conn, _params) do
    menu_catalog = Repo.all(from(m in MenuCatalog))

    subcats =
      Repo.all(
        from(
          s in ItemSubcat,
          left_join: c in ItemCat,
          on: c.itemcatid == s.itemcatid,
          where:
            s.is_comboitem == ^0 and s.is_delete == ^0 and c.category_type != "COMBO" and
              s.brand_id == ^BN.get_brand_id(conn) and c.brand_id == ^BN.get_brand_id(conn),
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

    remark =
      Repo.all(
        from(
          r in Remark,
          left_join: s in ItemCat,
          on: r.target_cat == s.itemcatid,
          where: s.brand_id == ^BN.get_brand_id(conn),
          select: %{
            remarkid: r.itemsremarkid,
            itemname: s.itemcatname,
            itemremark: r.remark,
            brand_id: r.brand_id
          }
        )
      )
      |> Enum.filter(fn x -> x.brand_id == BN.get_brand_id(conn) end)

    render(
      conn,
      "index.html",
      menu_catalog: menu_catalog,
      subcats: subcats,
      remark: remark
    )
  end

  def new(conn, _params) do
    changeset = BN.change_menu_item(%MenuItem{})

    itemcodes =
      Repo.all(
        from(
          s in ItemSubcat,
          left_join: c in ItemCat,
          on: c.itemcatid == s.itemcatid,
          where:
            s.is_combo == ^0 and s.is_comboitem == ^0 and s.is_delete == ^0 and
              c.category_type != "COMBO",
          group_by: [s.itemcode],
          select: %{code: s.itemcode, name: s.itemname}
        )
      )
      |> Enum.map(fn x ->
        %{name: x.name, code: x.code, group: hd(String.split(x.code, ""))}
      end)
      |> Enum.group_by(fn x -> x.group end)

    item_cat =
      Repo.all(
        from(
          c in ItemCat,
          where: c.category_type != "COMBO",
          select: %{
            itemcatid: c.itemcatid,
            itemcatname: c.itemcatname,
            itemcatcode: c.itemcatcode
          }
        )
      )

    render(conn, "new.html", changeset: changeset, item_cat: item_cat, itemcodes: itemcodes)
  end

  def create(conn, %{"menu_item" => item_subcat_params}) do
    cat_id = item_subcat_params["itemcatid"]
    cat = Repo.get(BoatNoodle.BN.ItemCat, cat_id)
    itemcode = item_subcat_params["itemcode"]
    first_letter = itemcode |> String.split("") |> Enum.reject(fn x -> x == "" end) |> hd()

    if Float.parse(first_letter) == :error do
      running_no = itemcode |> String.split("") |> Enum.reject(fn x -> x == "" end) |> tl()

      if Enum.count(running_no) == 2 do
        part_code =
          List.insert_at(running_no, 0, "0") |> List.insert_at(0, first_letter) |> Enum.join()

        itemname = itemcode <> " " <> item_subcat_params["itemdesc"]
        extension_params = %{"itemname" => itemname, "part_code" => part_code}
        item_param = Map.merge(item_subcat_params, extension_params)
        cg = BoatNoodle.BN.ItemSubcat.changeset(%BoatNoodle.BN.ItemSubcat{}, item_param)
        # subcat id needs to be generated manually.

        price_codes = item_subcat_params["price_code"] |> Map.keys()

        for price_code <- price_codes do
          price = item_subcat_params["price_code"][price_code] |> Decimal.new()

          item_param = Map.put(item_param, "itemprice", price)
          item_param = Map.put(item_param, "price_code", price_code)
          product_code = cat.itemcatcode <> part_code <> price_code

          item_param = Map.put(item_param, "product_code", product_code)

          a =
            Repo.all(
              from(
                s in ItemSubcat,
                left_join: c in ItemCat,
                on: c.itemcatid == s.itemcatid,
                where:
                  s.is_combo == ^0 and s.is_comboitem == ^0 and s.is_delete == ^0 and
                    c.category_type != "COMBO",
                select: s.subcatid,
                order_by: [asc: s.subcatid]
              )
            )
            |> List.last()

          item_param = Map.put(item_param, "subcatid", a + 1)
          cg2 = BoatNoodle.BN.ItemSubcat.changeset(%BoatNoodle.BN.ItemSubcat{}, item_param)

          case Repo.insert(cg2) do
            {:ok, item_cat} ->
              true

            _ ->
              IO.puts("failed item create")
              false
          end
        end

        conn
        |> put_flash(:info, "Menu item created successfully.")
        |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))
      else
        conn
        |> put_flash(:info, "code behind are not numbers")
        |> redirect(to: menu_item_path(conn, :new, BN.get_domain(conn)))
      end
    else
      conn
      |> put_flash(:info, "code first letter is not alphabet")
      |> redirect(to: menu_item_path(conn, :new, BN.get_domain(conn)))
    end

    # case BN.create_menu_item(menu_item_params) do
    #   {:ok, menu_item} ->

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "new.html", changeset: changeset)
    # end
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

  def update(conn, %{"id" => subcatid, "menu_item" => menu_item_params}) do
    # menu_item = BN.get_menu_item!(id)

    item_subcat =
      Repo.all(
        from(
          i in ItemSubcat,
          where: i.subcatid == ^subcatid and i.brand_id == ^conn.private.plug_session["brand_id"]
        )
      )
      |> hd()

    same_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.itemcode == ^item_subcat.itemcode and s.is_combo == ^0 and s.is_comboitem == ^0 and
              s.is_delete == ^0,
          order_by: [asc: s.price_code]
        )
      )

    cat =
      Repo.all(
        from(
          i in ItemCat,
          where:
            i.itemcatid == ^menu_item_params["itemcatid"] and i.brand_id == ^BN.get_brand_id(conn)
        )
      )
      |> hd()

    # cat = Repo.all(from(i in BoatNoodle.BN.ItemCat, where: ))
    itemcode = menu_item_params["itemcode"]
    first_letter = itemcode |> String.split("") |> Enum.reject(fn x -> x == "" end) |> hd()

    if Float.parse(first_letter) == :error do
      running_no = itemcode |> String.split("") |> Enum.reject(fn x -> x == "" end) |> tl()

      if Enum.count(running_no) == 2 do
        part_code =
          List.insert_at(running_no, 0, "0") |> List.insert_at(0, first_letter) |> Enum.join()

        itemname = itemcode <> " " <> menu_item_params["itemdesc"]
        extension_params = %{"itemname" => itemname, "part_code" => part_code}
        item_param = Map.merge(menu_item_params, extension_params)

        price_codes = menu_item_params["price_code"] |> Map.keys()

        for price_code <- price_codes do
          if menu_item_params["price_code"][price_code] != "" do
            price = menu_item_params["price_code"][price_code] |> Decimal.new()

            item_param = Map.put(item_param, "itemprice", price)
            item_param = Map.put(item_param, "price_code", price_code)
            product_code = cat.itemcatcode <> part_code <> price_code

            item_param = Map.put(item_param, "product_code", product_code)

            isc = same_items |> Enum.filter(fn x -> x.price_code == price_code end) |> hd()

            cg2 = BoatNoodle.BN.ItemSubcat.changeset(isc, item_param)

            case Repo.update(cg2) do
              {:ok, item_cat} ->
                true

              _ ->
                IO.puts("failed item udpate")
                false
            end
          end
        end

        conn
        |> put_flash(:info, "Menu item updated successfully.")
        |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))
      else
        conn
        |> put_flash(:info, "code behind are not numbers")
        |> redirect(to: menu_item_path(conn, :new, BN.get_domain(conn)))
      end
    else
      conn
      |> put_flash(:info, "code first letter is not alphabet")
      |> redirect(to: menu_item_path(conn, :new, BN.get_domain(conn)))
    end

    # case BN.update_menu_item(menu_item, menu_item_params) do
    #   {:ok, menu_item} ->
    conn
    |> put_flash(:info, "Menu item updated successfully.")
    |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "edit.html", menu_item: menu_item, changeset: changeset)
    # end
  end

  def delete(conn, %{"id" => id}) do
    menu_item = BN.get_menu_item!(id)
    {:ok, _menu_item} = BN.delete_menu_item(menu_item)

    conn
    |> put_flash(:info, "Menu item deleted successfully.")
    |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))
  end
end
