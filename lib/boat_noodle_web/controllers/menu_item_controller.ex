defmodule BoatNoodleWeb.MenuItemController do
  use BoatNoodleWeb, :controller
  use Task
  alias BoatNoodle.BN
  alias BoatNoodle.BN.{MenuItem, MenuCatalog, ItemSubcat, ItemCat, Remark, Brand}

  require IEx

  def combos(conn, _params) do
    brand = BN.get_brand_id(conn)

    combo_menus =
      Repo.all(
        from(
          i in ItemSubcat,
          left_join: c in ItemCat,
          on: c.itemcatid == i.itemcatid,
          where:
            c.category_type == ^"COMBO" and c.brand_id == ^BN.get_brand_id(conn) and
              i.brand_id == ^BN.get_brand_id(conn),
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

  def export(conn, _params) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"Menu Item List.csv\"")
    |> send_resp(200, csv_content(conn, _params))
  end

  defp csv_content(conn, _params) do
    brand = Repo.get_by(Brand, domain_name: _params["brand"])

    all =
      Repo.all(
        from(
          s in ItemSubcat,
          left_join: d in ItemCat,
          where: s.itemcatid == d.itemcatid and s.brand_id == ^brand.id,
          select: %{
            subcatid: s.subcatid,
            itemcode: s.itemcode,
            itemname: s.itemname,
            itemcatname: d.itemcatname,
            itemdesc: s.itemdesc,
            itemprice: s.itemprice,
            is_categorize: s.is_categorize,
            is_activate: s.is_activate,
            part_code: s.part_code,
            price_code: s.price_code
          }
        )
      )

    csv_content = [
      'id',
      'Item Code',
      'Item Name',
      'Item Category',
      'Item Descriptions',
      'Item Price',
      'is_categorize',
      'is_activated',
      'Part Code',
      'Price Code',
      'Branch'
    ]

    data =
      for item <- all do
        [
          item.subcatid,
          item.itemcode,
          item.itemname,
          item.itemcatname,
          item.itemdesc,
          item.itemprice,
          item.is_categorize,
          item.is_activate,
          item.part_code,
          item.price_code,
          'ALL'
        ]
      end

    csv_content =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end

  def index(conn, _params) do
    menu_catalog = Repo.all(from(m in MenuCatalog, where: m.brand_id == ^BN.get_brand_id(conn)))

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

    a = conn.path_info |> List.delete_at(1)
    b = "categories"
    c = List.insert_at(a, 2, b)
    d = "edit"
    e = List.insert_at(c, 2, d)
    f = e |> Enum.join("/")
    e = "/"
    edit_url = e <> f

    g = conn.path_info |> List.delete_at(1)
    h = "categories"
    i = List.insert_at(g, 2, h)
    j = "new"
    k = List.insert_at(i, 2, j)
    l = k |> Enum.join("/")
    m = "/"
    new_url = m <> l

    n = conn.path_info |> List.delete_at(1)
    o = "categories"
    p = List.insert_at(n, 2, o)
    q = "delete"
    r = List.insert_at(p, 2, q)
    s = r |> Enum.join("/")
    t = "/"
    delete_url = t <> s

    render(
      conn,
      "index.html",
      menu_catalog: menu_catalog,
      subcats: subcats,
      remark: remark,
      admin_menus: admin_menus,
      edit_url: edit_url,
      new_url: new_url,
      delete_url: delete_url
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

  def create(conn, %{"menu_item" => item_subcat_params, "a" => a}) do
    cat_id = item_subcat_params["itemcatid"]
    cat = Repo.get_by(BoatNoodle.BN.ItemCat, itemcatid: cat_id, brand_id: BN.get_brand_id(conn))
    itemcode = item_subcat_params["itemcode"]


  

     enable_disc = if a["enable_disc"] == "on" do
      1

    else
      0
    end



     is_activate = if a["is_active"] == "on" do
      1

    else
       0
    end



     include_spend =  if a["include_spend"] == "on" do
     1

    else
      0
    end

    item_subcat_params = Map.put(item_subcat_params, "enable_disc", enable_disc)
    item_subcat_params = Map.put(item_subcat_params, "is_activate", is_activate)
    item_subcat_params = Map.put(item_subcat_params, "include_spend", include_spend)
    item_subcat_params = Map.put(item_subcat_params, "brand_id", BN.get_brand_id(conn))

    first_letter = itemcode |> String.split("") |> Enum.reject(fn x -> x == "" end) |> hd()

    if Float.parse(first_letter) == :error do
      running_no = itemcode |> String.split("") |> Enum.reject(fn x -> x == "" end) |> tl()

      if Enum.count(running_no) == 2 do
        part_code =
          List.insert_at(running_no, 0, "0") |> List.insert_at(0, first_letter) |> Enum.join()

        itemname = itemcode <> " " <> item_subcat_params["itemdesc"]
        extension_params = %{"itemname" => itemname, "part_code" => part_code}
        item_param = Map.merge(item_subcat_params, extension_params)

        cg =
          BoatNoodle.BN.ItemSubcat.changeset(
            %BoatNoodle.BN.ItemSubcat{},
            item_param,
            BN.current_user(conn),
            "Create"
          )

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

            if a != [] do
              a =
                a
                |> List.last()
            else
              a = 0
            end

            item_param = Map.put(item_param, "subcatid", a + 1)

            cg2 =
              BoatNoodle.BN.ItemSubcat.changeset(
                %BoatNoodle.BN.ItemSubcat{},
                item_param,
                BN.current_user(conn),
                "Create"
              )

            case Repo.insert(cg2) do
              {:ok, item_cat} ->
                item_cat

              {:error, cg2} ->
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
      same_items
      |> Enum.map(fn x -> x.subcatid end)
      |> Enum.map(fn x -> Integer.to_string(x) end)
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

      nl = if Enum.any?(items_ids, fn x -> x == answer end) do
        # remove it
        # nl = List.delete(items_ids, answer) |> Enum.reject(fn x -> x == "" end)
        # keep it
        items_ids
      else
        List.insert_at(items_ids, 0, answer) |> Enum.reject(fn x -> x == "" end)
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

  def update(conn, %{
        "id" => subcatid,
        "menu_item" => menu_item_params,
        "brand" => brand,
        "a" => a
      }) do
    # menu_item = BN.get_menu_item!(id)

     enable_disc = if a["enable_disc"] == "on" do
     1
    else
     0
    end



      is_activate = if a["is_active"] == "on" do
     1


    else
     0
    end



      include_spend = if a["include_spend"] == "on" do
      1

    else
     0
    end

    menu_item_params = Map.put(menu_item_params, "enable_disc", enable_disc)
    menu_item_params = Map.put(menu_item_params, "is_activate", is_activate)
    menu_item_params = Map.put(menu_item_params, "include_spend", include_spend)

    item_start_hour = menu_item_params["item_start_hour"]
    item_end_hour = menu_item_params["item_end_hour"]

    menu_item_params = Map.put(menu_item_params, "item_start_hour", item_start_hour)
    menu_item_params = Map.put(menu_item_params, "item_end_hour", item_end_hour)

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

            file_param = conn.params["image"]

            if file_param != nil do
              {:ok, bin} = File.read(file_param.path)

              item_param = Map.put(item_param, "itemimage", Base.encode64(bin))
            end

            cg2 =
              BoatNoodle.BN.ItemSubcat.changeset(isc, item_param, BN.current_user(conn), "Update")

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
