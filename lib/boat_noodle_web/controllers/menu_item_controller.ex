defmodule BoatNoodleWeb.MenuItemController do
  use BoatNoodleWeb, :controller
  use Task
  alias BoatNoodle.BN
  alias BoatNoodle.BN.{MenuItem, MenuCatalog, ItemSubcat, ItemCat, Remark}

  require IEx

  def combos(conn, _params) do

        brand = BN.get_brand_id(conn)
    combo_menus =
      Repo.all(
        from(
          i in ItemSubcat,
          left_join: c in ItemCat,
          on: c.itemcatid == i.itemcatid,
          where: c.category_type == ^"COMBO" and i.brand_id==^brand,
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
            s.is_comboitem == ^0 and s.is_delete == ^0 and c.category_type != "COMBO" and
              c.brand_id == ^BN.get_brand_id(conn) and s.brand_id == ^BN.get_brand_id(conn),
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
          where: c.category_type != "COMBO" and c.brand_id == ^BN.get_brand_id(conn),
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
    cat = Repo.get_by(BoatNoodle.BN.ItemCat, itemcatid: cat_id, brand_id: BN.get_brand_id(conn))
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

        listings =
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
                    s.is_comboitem == ^0 and s.is_delete == ^0 and c.category_type != "COMBO" and
                      s.brand_id == ^BN.get_brand_id(conn),
                  select: s.subcatid,
                  order_by: [asc: s.subcatid]
                )
              )
              |> List.last()

            item_param = Map.put(item_param, "subcatid", a + 1)
            cg2 = BoatNoodle.BN.ItemSubcat.changeset(%BoatNoodle.BN.ItemSubcat{}, item_param)

            case Repo.insert(cg2) do
              {:ok, item_cat} ->
                item_cat

              {:error, cg2} ->
                IEx.pry()
                false
            end
          end

        if Enum.any?(listings, fn x -> x == false end) do
          conn
          |> put_flash(:error, "Errors in creating items")
          |> redirect(to: menu_item_path(conn, :new, BN.get_domain(conn)))
        else
          item_cat = listings |> hd()

          conn
          |> put_flash(:info, "Menu item created successfully.")
          |> redirect(
            to: item_subcat_path(conn, :item_show, BN.get_domain(conn), item_cat.subcatid)
          )
        end
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

  def update_printers(conn, tag_params, subcatid) do
    item_subcat = Repo.get_by(ItemSubcat, subcatid: subcatid, brand_id: BN.get_brand_id(conn))

    same_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.itemcode == ^item_subcat.itemcode and s.is_comboitem == ^0 and s.is_delete == ^0,
          order_by: [asc: s.price_code]
        )
      )

    item_codes_str =
      same_items |> Enum.map(fn x -> x.subcatid end) |> Enum.map(fn x -> Integer.to_string(x) end)
      |> Enum.sort()

    branch_names = tag_params |> Map.keys()

    for branch_name <- branch_names do
      printer_id = tag_params[branch_name]["tag_id"]
      tag = Repo.get_by(Tag, tagid: printer_id, brand_id: BN.get_brand_id(conn))
      items_ids = tag.subcat_ids |> String.split(",")
      branch = Repo.get_by(Branch, branchname: branch_name)

      menu_catalog =
        Repo.get_by(MenuCatalog, id: branch.menu_catalog, brand_id: BN.get_brand_id(conn))

      subcat_ids = menu_catalog.items |> String.split(",") |> Enum.sort()
      myers = List.myers_difference(item_codes_str, subcat_ids)
      answer = myers |> Keyword.get(:eq) |> hd()

      if Enum.any?(items_ids, fn x -> x == answer end) do
        # remove it
        # nl = List.delete(items_ids, answer) |> Enum.reject(fn x -> x == "" end)
        # keep it
        nl = items_ids
      else
        nl = List.insert_at(items_ids, 0, answer) |> Enum.reject(fn x -> x == "" end)
      end

      new_items = Enum.join(nl, ",")

      stats = Tag.changeset(tag, %{subcat_ids: new_items}) |> Repo.update()

      case stats do
        {:ok, tag} ->
          true

        {:error, stats} ->
          IO.puts("tag error")
      end

      tags =
        Repo.all(
          from(
            t in Tag,
            where:
              t.branch_id == ^branch.branchid and t.tagid != ^printer_id and
                t.brand_id == ^BN.get_brand_id(conn)
          )
        )

      for tag <- tags do
        items_ids = tag.subcat_ids |> String.split(",")
        nl = List.delete(items_ids, answer) |> Enum.reject(fn x -> x == "" end)

        new_items = Enum.join(nl, ",")

        stats = Tag.changeset(tag, %{subcat_ids: new_items}) |> Repo.update()
      end

      true
    end
  end

  def update(conn, %{"id" => subcatid, "menu_item" => menu_item_params, "tag" => tag_params}) do
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
            s.itemcode == ^item_subcat.itemcode and s.is_comboitem == ^0 and s.is_delete == ^0,
          order_by: [asc: s.price_code]
        )
      )

    Task.start_link(__MODULE__, :update_printers, [conn, tag_params, subcatid])

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
