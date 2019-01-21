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
              i.brand_id == ^BN.get_brand_id(conn) and i.is_activate != ^0,
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

  def sync_to_client(conn, params) do
    # this place send the broadcast
    brand = BN.get_brand_id(conn)
    branchcode = params["branchcode"]
    menu_catalog = Repo.get_by(MenuCatalog, id: params["menu_catalog_id"], brand_id: brand)
    ids = menu_catalog.items |> String.split(",")

    items =
      Repo.all(
        from(
          i in ItemSubcat,
          where: i.brand_id == ^brand and i.subcatid in ^ids,
          select: %{
            name: i.itemname,
            price: i.itemprice,
            printer_ip: "10.239.30.114",
            port_no: 9100
          }
        )
      )

    IO.inspect(items)
    topic = "restaurant:#{branchcode}"
    event = "new_menu_items"
    message = %{menu_items: items}
    BoatNoodleWeb.Endpoint.broadcast(topic, event, message)

    conn
    |> put_flash(:info, "Syncing to client")
    |> redirect(to: branch_path(conn, :index, BN.get_domain(conn)))
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
          where:
            s.itemcatid == d.itemcatid and s.brand_id == ^brand.id and d.brand_id == ^brand.id,
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

    u = conn.path_info |> List.delete_at(1)
    v = "categories"
    w = List.insert_at(u, 2, v)
    x = "view_item"
    y = List.insert_at(w, 2, x)
    z = y |> Enum.join("/")
    zz = "/"
    view_url = zz <> z

    changeset = BN.change_menu_item(%MenuItem{})

    price_list =
      Repo.all(
        from(
          s in BoatNoodle.BN.SubcatCatalog,
          left_join: r in ItemSubcat,
          on: r.subcatid == s.subcat_id,
          where:
            s.is_active == ^1 and s.is_combo == ^0 and s.brand_id == ^BN.get_brand_id(conn) and
              r.brand_id == ^BN.get_brand_id(conn),
          select: %{
            name: r.itemname,
            start_date: s.start_date,
            end_date: s.end_date,
            price: s.price
          }
        )
      )

    render(
      conn,
      "index.html",
      price_list: price_list,
      menu_catalog: menu_catalog,
      subcats: subcats,
      remark: remark,
      admin_menus: admin_menus,
      edit_url: edit_url,
      new_url: new_url,
      delete_url: delete_url,
      view_url: view_url,
      changeset: changeset,
      price_list: price_list
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

    enable_disc =
      if item_subcat_params["enable_disc"] == "on" do
        1
      else
        0
      end

    is_activate =
      if item_subcat_params["is_active"] == "on" do
        1
      else
        0
      end

    include_spend =
      if item_subcat_params["include_spend"] == "on" do
        1
      else
        0
      end

    item_subcat_params = Map.put(item_subcat_params, "enable_disc", enable_disc)
    item_subcat_params = Map.put(item_subcat_params, "is_activate", is_activate)
    item_subcat_params = Map.put(item_subcat_params, "include_spend", include_spend)
    item_subcat_params = Map.put(item_subcat_params, "brand_id", BN.get_brand_id(conn))

    part_code = item_subcat_params["part_code"]

    extension_params = %{"part_code" => part_code}
    item_param = Map.merge(item_subcat_params, extension_params)

    price_codes = item_subcat_params["price_code"] |> Map.keys()

    listings =
      for price_code <- price_codes do
        price = item_subcat_params["price_code"][price_code] |> Decimal.new()

        item_param = Map.put(item_param, "itemprice", price)
        item_param = Map.put(item_param, "price_code", price_code)

        product_code = cat.itemcatcode <> part_code <> price_code

        # item_param = Map.put(item_param, "part_code", part_code)
        item_param = Map.put(item_param, "product_code", product_code)

        a =
          Repo.all(
            from(
              s in ItemSubcat,
              left_join: c in ItemCat,
              on: c.itemcatid == s.itemcatid,
              where:
                s.is_comboitem == ^0 and c.category_type != "COMBO" and
                  s.brand_id == ^BN.get_brand_id(conn),
              select: s.subcatid,
              order_by: [asc: s.subcatid]
            )
          )
          |> Enum.map(fn x -> Integer.to_string(x) end)
          |> Enum.reject(fn x -> String.length(x) > 5 end)

        a =
          if a != [] do
            a =
              a
              |> List.last()
              |> String.to_integer()
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
      |> redirect(to: item_subcat_path(conn, :item_show, BN.get_domain(conn), item_cat.subcatid))
    end
  end

  def price_list(conn, params) do
    item_subcat = Repo.get_by(ItemSubcat, subcatid: params["id"], brand_id: BN.get_brand_id(conn))

    price_list =
      Repo.all(
        from(
          s in BoatNoodle.BN.SubcatCatalog,
          where: s.subcat_id == ^params["id"],
          group_by: [s.subcat_id, s.start_date, s.end_date, s.price],
          order_by: [asc: s.start_date]
        )
      )

    render(conn, "price_list.html", price_list: price_list, item_subcat: item_subcat)
  end

  def new_price_list(conn, params) do
    item_subcat =
      Repo.get_by(ItemSubcat, subcatid: params["subcat_id"], brand_id: BN.get_brand_id(conn))

    all_menu_catalog =
      Repo.all(
        from(
          m in BoatNoodle.BN.MenuCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: %{id: m.id, name: m.name}
        )
      )

    render(conn, "new_price_list.html", menu_catalog: all_menu_catalog, item_subcat: item_subcat)
  end

  def create_price_list(conn, params) do
    a = params["branc"]
    branchs = a |> Enum.map(fn x -> x end) |> hd |> elem(1) |> String.split(",")

    for branch <- branchs do
      prev_id =
        Repo.all(from(c in BoatNoodle.BN.SubcatCatalog, select: %{id: c.id}))
        |> Enum.sort()
        |> List.last()

      new_id =
        if prev_id == nil do
          1
        else
          prev_id.id + 1
        end

      subcat_catalog_params = %{
        id: new_id,
        subcat_id: params["subcat_id"],
        start_date: params["start_date"],
        end_date: params["end_date"],
        brand_id: BN.get_brand_id(conn),
        price: params["price"],
        catalog_id: branch
      }

      price_list_exist =
        Repo.all(
          from(
            s in BoatNoodle.BN.SubcatCatalog,
            where:
              s.subcat_id == ^params["subcat_id"] and s.catalog_id == ^branch and
                s.start_date >= ^params["start_date"] and s.start_date <= ^params["end_date"]
          )
        )

      if price_list_exist != [] do
        conn
        |> put_flash(
          :info,
          "This Date Range alrdy Exist, Please Edit Existing Item Price/ Select Another Date Range"
        )
        |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))
      else
        BN.create_subcat_catalog(subcat_catalog_params)
      end

      conn
      |> put_flash(:info, "Price List created successfully.")
      |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))
    end
  end

  def edit_price_list(conn, params) do
    subcat_catalog = BN.get_subcat_catalog!(params["id"])

    menu_catalog =
      Repo.all(
        from(
          m in BoatNoodle.BN.MenuCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: %{catalog_id: m.id, name: m.name}
        )
      )

    price_list_catalog =
      Repo.all(
        from(
          s in BoatNoodle.BN.SubcatCatalog,
          left_join: r in BoatNoodle.BN.MenuCatalog,
          on: s.catalog_id == r.id,
          where:
            s.subcat_id == ^subcat_catalog.subcat_id and s.is_combo != 1 and
              r.brand_id == ^BN.get_brand_id(conn),
          select: %{catalog_id: s.catalog_id, name: r.name}
        )
      )
      |> Enum.uniq()

    balence = menu_catalog -- price_list_catalog

    active =
      for item <- price_list_catalog do
        %{catalog_id: item.catalog_id, name: item.name, is_active: 1}
      end

    not_active =
      for item <- balence do
        %{catalog_id: item.catalog_id, name: item.name, is_active: 0}
      end

    all = active ++ not_active

    changeset = BN.change_subcat_catalog(subcat_catalog)

    render(conn, "edit_price_list.html",
      menu_catalog: menu_catalog,
      subcat_catalog: subcat_catalog,
      all: all,
      changeset: changeset
    )
  end

  def update_price_list(conn, params) do
    catalog_id = params["catalog_id"]

    price_list_exist =
      Repo.delete_all(
        from(
          s in BoatNoodle.BN.SubcatCatalog,
          where:
            s.subcat_id == ^params["subcat_id"] and s.start_date == ^params["old_start_date"] and
              s.end_date == ^params["old_end_date"] and s.brand_id == ^BN.get_brand_id(conn)
        )
      )

    for id <- catalog_id do
      cat_id = id |> elem(0)

      is_active =
        if params["is_active"] != nil do
          1
        else
          0
        end

      prev_id =
        Repo.all(from(c in BoatNoodle.BN.SubcatCatalog, select: %{id: c.id}))
        |> Enum.sort()
        |> List.last()

      new_id =
        if prev_id == nil do
          1
        else
          prev_id.id + 1
        end

      subcat_catalog_params = %{
        id: new_id,
        subcat_id: params["subcat_id"],
        start_date: params["start_date"],
        end_date: params["end_date"],
        brand_id: BN.get_brand_id(conn),
        price: params["price"],
        catalog_id: cat_id,
        is_active: is_active
      }

      BN.create_subcat_catalog(subcat_catalog_params)
    end

    # price_list_exist =
    #   Repo.get_by(
    #     BoatNoodle.BN.SubcatCatalog,
    #     %{
    #       subcat_id: params["subcat_id"],
    #       catalog_id: cat_id,
    #       start_date: params["start_date"],
    #       end_date: params["end_date"]
    #     }
    #   )

    #   if price_list_exist != nil do
    #     subcat_catalog = BN.get_subcat_catalog!(price_list_exist.id)

    #     is_active =
    #       if params["is_active"] != nil do
    #         1
    #       else
    #         0
    #       end
    # 
    #     if status == "on" do
    #       params = %{
    #         start_date: start_date,
    #         end_date: end_date,
    #         is_active: is_active,
    #         price: price
    #       }

    #       BN.update_subcat_catalog(subcat_catalog, params)
    #     else
    #       BN.delete_subcat_catalog(subcat_catalog)
    #     end
    #   else

    #   end
    # end

    conn
    |> put_flash(:info, "Price List updated successfully.")
    |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))
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

      nl =
        if Enum.any?(items_ids, fn x -> x == answer end) do
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

  def update(conn, params) do
    # menu_item = BN.get_menu_item!(id)
    subcatid = params["id"]
    menu_item_params = params["menu_item"]
    brand = params["brand"]
    a = params["a"]

    enable_disc =
      if a["enable_disc"] == "on" do
        1
      else
        0
      end

    is_activate =
      if a["is_active"] == "on" do
        1
      else
        0
      end

    include_spend =
      if a["include_spend"] == "on" do
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
            s.itemcode == ^item_subcat.itemcode and s.is_comboitem == ^0 and s.is_delete == ^0 and
              s.brand_id == ^conn.private.plug_session["brand_id"],
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

    itemcode = menu_item_params["itemcode"]

    part_code = menu_item_params["part_code"]

    extension_params = %{"part_code" => part_code}
    item_param = Map.merge(menu_item_params, extension_params)

    price_codes = menu_item_params["price_code"] |> Map.keys()

    for price_code <- price_codes do
      if menu_item_params["price_code"][price_code] != "" do
        price = menu_item_params["price_code"][price_code] |> Decimal.new()

        if menu_item_params["price_code"][price_code] != "0.00" do
          item_param = Map.put(item_param, "itemprice", price)
          item_param = Map.put(item_param, "price_code", price_code)
          product_code = cat.itemcatcode <> part_code <> price_code

          item_param = Map.put(item_param, "product_code", product_code)

          isc = same_items |> Enum.filter(fn x -> x.price_code == price_code end)

          isc =
            if isc == [] do
              # create new item subcat

              subcat_id_list =
                Repo.all(
                  from(
                    s in ItemSubcat,
                    left_join: c in ItemCat,
                    on: c.itemcatid == s.itemcatid,
                    where:
                      s.is_comboitem == ^0 and c.category_type != "COMBO" and
                        s.brand_id == ^BN.get_brand_id(conn) and
                        c.brand_id == ^BN.get_brand_id(conn),
                    select: s.subcatid,
                    order_by: [asc: s.subcatid]
                  )
                )

              if subcat_id_list != [] do
                a =
                  subcat_id_list
                  |> List.last()
              else
                a = 0
              end

              item_param = Map.put(item_param, "subcatid", a + 1)

              item_param = Map.put(item_param, "brand_id", BN.get_brand_id(conn))

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
                  IEx.pry()
                  false
              end
            else
              isc |> hd()
            end

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
    end

    conn
    |> put_flash(:info, "Menu item updated successfully.")
    |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))
  end

  def delete(conn, %{"id" => id}) do
    menu_item = BN.get_menu_item!(id)
    {:ok, _menu_item} = BN.delete_menu_item(menu_item)

    conn
    |> put_flash(:info, "Menu item deleted successfully.")
    |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))
  end
end
