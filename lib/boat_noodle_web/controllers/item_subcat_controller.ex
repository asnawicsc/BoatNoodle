defmodule BoatNoodleWeb.ItemSubcatController do
  use BoatNoodleWeb, :controller
  use Task
  alias BoatNoodle.BN
  alias BoatNoodle.BN.{MenuItem, Discount, ItemSubcat, ComboDetails, Branch, ItemCat, Tag}
  require IEx

  def combo_price_list(conn, params) do
    id1 = params["subcatid"]

    subcat =
      Repo.get_by(BoatNoodle.BN.ItemSubcat, %{
        subcatid: id1,
        brand_id: BN.get_brand_id(conn)
      })

    combo =
      Repo.all(
        from(
          s in BoatNoodle.BN.ComboDetails,
          where: s.combo_id == ^id1 and s.brand_id == ^BN.get_brand_id(conn)
        )
      )
      |> Enum.sort_by(fn x -> x.menu_cat_id end)

    item_subcat =
      Repo.get_by(ItemSubcat, subcatid: params["subcatid"], brand_id: BN.get_brand_id(conn))

    price_list =
      Repo.all(
        from(
          s in BoatNoodle.BN.SubcatCatalog,
          where: s.subcat_id == ^params["subcatid"],
          group_by: [s.subcat_id, s.start_date, s.end_date, s.price],
          order_by: [asc: s.start_date]
        )
      )

    render(conn, "combo_price_list.html",
      price_list: price_list,
      item_subcat: item_subcat,
      subcat: subcat,
      combo: combo
    )
  end

  def new_combo_price_list(conn, params) do
    item_subcat =
      Repo.get_by(BoatNoodle.BN.ItemSubcat, %{
        subcatid: params["subcat_id"],
        brand_id: BN.get_brand_id(conn)
      })

    all_menu_catalog =
      Repo.all(
        from(
          m in BoatNoodle.BN.MenuCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: %{id: m.id, name: m.name}
        )
      )

    combo =
      Repo.all(
        from(
          s in BoatNoodle.BN.ComboDetails,
          where: s.combo_id == ^params["subcat_id"] and s.brand_id == ^BN.get_brand_id(conn)
        )
      )
      |> Enum.sort_by(fn x -> x.menu_cat_id end)

    render(conn, "new_combo_price_list.html",
      menu_catalog: all_menu_catalog,
      combo: combo,
      item_subcat: item_subcat
    )
  end

  def create_combo_price_list(conn, params) do
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

      is_active =
        if params["is_active"] == nil do
          0
        else
          1
        end

      subcat_catalog_params = %{
        id: new_id,
        subcat_id: params["subcat_id"],
        start_date: params["start_date"],
        end_date: params["end_date"],
        brand_id: BN.get_brand_id(conn),
        price: params["price"],
        is_active: is_active,
        is_combo: 1,
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
          "This Date Range alrdy Exist, Please Edit Existing Combo Price List/ Select Another Date Range"
        )
        |> redirect(to: menu_item_path(conn, :combos, BN.get_domain(conn)))
      else
        sub_combo = params["combo"]

        for item <- sub_combo do
          combo_id = item |> elem(0)
          cost = item |> elem(1)

          price = cost["price"]
          to_up = cost["top_up"]

          c_id =
            Repo.all(from(c in BoatNoodle.BN.ComboCatalog, select: %{id: c.id}))
            |> Enum.sort()
            |> List.last()

          c_id =
            if c_id == nil do
              1
            else
              c_id.id + 1
            end

          subcat_combo_params = %{
            id: c_id,
            subcat_id: params["subcat_id"],
            combo_item_id: combo_id,
            start_date: params["start_date"],
            end_date: params["end_date"],
            brand_id: BN.get_brand_id(conn),
            price: price,
            to_up: to_up,
            is_active: is_active,
            catalog_id: branch
          }

          BN.create_combo_catalog(subcat_combo_params)
        end

        BN.create_subcat_catalog(subcat_catalog_params)
      end
    end

    conn
    |> put_flash(:info, "Combo Price List created successfully.")
    |> redirect(to: menu_item_path(conn, :combos, BN.get_domain(conn)))
  end

  def edit_combo_price_list(conn, params) do
    item_subcat =
      Repo.all(
        from(
          s in BoatNoodle.BN.SubcatCatalog,
          where:
            s.subcat_id == ^params["subcat_id"] and s.brand_id == ^BN.get_brand_id(conn) and
              s.start_date == ^params["start_date"] and s.end_date == ^params["end_date"],
          group_by: [s.subcat_id, s.start_date, s.end_date, s.price],
          order_by: [asc: s.start_date]
        )
      )
      |> hd()

    subcat =
      Repo.get_by(BoatNoodle.BN.ItemSubcat, %{
        subcatid: params["subcat_id"],
        brand_id: BN.get_brand_id(conn)
      })

    combo =
      Repo.all(
        from(
          s in BoatNoodle.BN.ComboCatalog,
          where:
            s.subcat_id == ^params["subcat_id"] and s.start_date == ^params["start_date"] and
              s.end_date == ^params["end_date"] and s.brand_id == ^BN.get_brand_id(conn),
          group_by: [s.combo_item_id, s.start_date, s.end_date, s.price]
        )
      )

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
            s.subcat_id == ^item_subcat.subcat_id and s.is_combo == 1 and
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

    render(conn, "edit_combo_price_list.html",
      subcat: subcat,
      all: all,
      combo: combo,
      item_subcat: item_subcat
    )
  end

  def update_combo_price_list(conn, params) do
    catalog_id = params["catalog_id"]

    item_subcat =
      Repo.delete_all(
        from(
          s in BoatNoodle.BN.SubcatCatalog,
          where:
            s.subcat_id == ^params["subcat_id"] and s.start_date == ^params["old_start_date"] and
              s.end_date == ^params["old_end_date"] and s.brand_id == ^BN.get_brand_id(conn)
        )
      )

    combo_catalog =
      Repo.delete_all(
        from(
          s in BoatNoodle.BN.ComboCatalog,
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
        is_active: is_active,
        is_combo: 1,
        catalog_id: cat_id
      }

      BN.create_subcat_catalog(subcat_catalog_params)

      sub_combo = params["combo"]

      for item <- sub_combo do
        combo_id = item |> elem(0)
        cost = item |> elem(1)

        price = cost["price"]
        to_up = cost["top_up"]

        c_id =
          Repo.all(from(c in BoatNoodle.BN.ComboCatalog, select: %{id: c.id}))
          |> Enum.sort()
          |> List.last()

        c_id =
          if c_id == nil do
            1
          else
            c_id.id + 1
          end

        subcat_combo_params = %{
          id: c_id,
          subcat_id: params["subcat_id"],
          combo_item_id: combo_id,
          start_date: params["start_date"],
          end_date: params["end_date"],
          brand_id: BN.get_brand_id(conn),
          price: price,
          to_up: to_up,
          is_active: is_active,
          catalog_id: cat_id
        }

        BoatNoodle.BN.create_combo_catalog(subcat_combo_params)
      end
    end

    conn
    |> put_flash(:info, "Combo Price List updated successfully.")
    |> redirect(to: menu_item_path(conn, :combos, BN.get_domain(conn)))
  end

  def combo_date_prices(conn, params) do
    item_subcat_id = params["subcatid"]

    date_prices =
      Repo.all(
        from(
          d in DatePrice,
          where:
            d.is_delete == ^0 and d.item_subcat_id == ^item_subcat_id and
              d.brand_id == ^BN.get_brand_id(conn),
          order_by: [desc: d.start_date]
        )
      )

    render(conn, "date_prices.html", date_prices: date_prices)
  end

  def combo_new_date_prices(conn, params) do
    item_subcat_id = params["subcatid"]

    date_prices =
      Repo.all(
        from(
          d in DatePrice,
          where:
            d.is_delete == ^0 and d.item_subcat_id == ^item_subcat_id and
              d.brand_id == ^BN.get_brand_id(conn),
          select: {d.start_date, d.end_date}
        )
      )

    list_of_date_ranges = Enum.map(date_prices, fn x -> Date.range(elem(x, 0), elem(x, 1)) end)

    s_date = params["start_date"] |> Date.from_iso8601!()

    check_start_date_clash =
      list_of_date_ranges
      |> Enum.map(fn x -> Enum.any?(x, fn y -> y == s_date end) end)
      |> Enum.any?(fn x -> x == true end)

    e_date = params["end_date"] |> Date.from_iso8601!()

    check_start_end_clash =
      list_of_date_ranges
      |> Enum.map(fn x -> Enum.any?(x, fn y -> y == e_date end) end)
      |> Enum.any?(fn x -> x == true end)

    if check_start_date_clash == true and check_start_end_clash == true do
      conn
      |> put_flash(
        :info,
        "Got date clash! Please set the date again."
      )
      |> redirect(
        to: item_subcat_path(conn, :combo_date_prices, BN.get_domain(conn), params["subcatid"])
      )
    else
      cg =
        DatePrice.changeset(
          %DatePrice{},
          %{
            item_subcat_id: params["subcatid"],
            brand_id: BN.get_brand_id(conn),
            unit_price: params["unit_price"],
            start_date: params["start_date"],
            end_date: params["end_date"]
          },
          BN.current_user(conn),
          "create"
        )

      Repo.insert(cg)

      conn
      |> put_flash(
        :info,
        "Date price added!"
      )
      |> redirect(
        to: item_subcat_path(conn, :combo_date_prices, BN.get_domain(conn), params["subcatid"])
      )
    end
  end

  def combo_delete_date_price(conn, params) do
    item_subcat_id = params["subcatid"]

    dp = Repo.get(DatePrice, params["id"])

    cg =
      DatePrice.changeset(
        dp,
        %{
          is_delete: 1
        },
        BN.current_user(conn),
        "Update"
      )

    Repo.update(cg)

    conn
    |> put_flash(
      :info,
      "Date price deleted!"
    )
    |> redirect(
      to: item_subcat_path(conn, :combo_date_prices, BN.get_domain(conn), params["subcatid"])
    )
  end

  def date_prices(conn, params) do
    item_subcat_id = params["subcatid"]

    date_prices =
      Repo.all(
        from(
          d in DatePrice,
          where:
            d.is_delete == ^0 and d.item_subcat_id == ^item_subcat_id and
              d.brand_id == ^BN.get_brand_id(conn),
          order_by: [desc: d.start_date]
        )
      )

    render(conn, "date_prices.html", date_prices: date_prices)
  end

  def new_date_prices(conn, params) do
    item_subcat_id = params["subcatid"]

    date_prices =
      Repo.all(
        from(
          d in DatePrice,
          where:
            d.is_delete == ^0 and d.item_subcat_id == ^item_subcat_id and
              d.brand_id == ^BN.get_brand_id(conn),
          select: {d.start_date, d.end_date}
        )
      )

    list_of_date_ranges = Enum.map(date_prices, fn x -> Date.range(elem(x, 0), elem(x, 1)) end)

    s_date = params["start_date"] |> Date.from_iso8601!()

    check_start_date_clash =
      list_of_date_ranges
      |> Enum.map(fn x -> Enum.any?(x, fn y -> y == s_date end) end)
      |> Enum.any?(fn x -> x == true end)

    e_date = params["end_date"] |> Date.from_iso8601!()

    check_start_end_clash =
      list_of_date_ranges
      |> Enum.map(fn x -> Enum.any?(x, fn y -> y == e_date end) end)
      |> Enum.any?(fn x -> x == true end)

    if check_start_date_clash == true and check_start_end_clash == true do
      conn
      |> put_flash(
        :info,
        "Got date clash! Please set the date again."
      )
      |> redirect(
        to: item_subcat_path(conn, :date_prices, BN.get_domain(conn), params["subcatid"])
      )
    else
      cg =
        DatePrice.changeset(
          %DatePrice{},
          %{
            item_subcat_id: params["subcatid"],
            brand_id: BN.get_brand_id(conn),
            unit_price: params["unit_price"],
            start_date: params["start_date"],
            end_date: params["end_date"]
          },
          BN.current_user(conn),
          "create"
        )

      Repo.insert(cg)

      conn
      |> put_flash(
        :info,
        "Date price added!"
      )
      |> redirect(
        to: item_subcat_path(conn, :date_prices, BN.get_domain(conn), params["subcatid"])
      )
    end
  end

  def delete_date_price(conn, params) do
    item_subcat_id = params["subcatid"]

    dp = Repo.get(DatePrice, params["id"])

    cg =
      DatePrice.changeset(
        dp,
        %{
          is_delete: 1
        },
        BN.current_user(conn),
        "Update"
      )

    Repo.update(cg)

    conn
    |> put_flash(
      :info,
      "Date price deleted!"
    )
    |> redirect(to: item_subcat_path(conn, :date_prices, BN.get_domain(conn), params["subcatid"]))
  end

  def combo_create(conn, params) do
    item_code =
      Repo.all(
        from(
          i in ItemSubcat,
          where:
            i.itemcode == ^params["itemcode"] and i.brand_id == ^BN.get_brand_id(conn) and
              i.is_delete == ^0 and i.is_activate == ^1,
          select: i.itemcode
        )
      )
      |> Enum.uniq()

    if item_code != [] do
      conn
      |> put_flash(
        :info,
        "Item Code already exist, please deactivate the old combo code to continue using same item code."
      )
      |> redirect(to: item_subcat_path(conn, :combo_new, BN.get_domain(conn)))
    else
      ala_cart_ids = params["item"]["itemcode"] |> String.split(",")
      itemname = params["itemcode"] <> " " <> params["itemdesc"]
      params = Map.put(params, "itemname", itemname)

      prev_subcatid =
        Repo.all(from(c in ItemSubcat, select: %{subcatid: c.subcatid}))
        |> Enum.map(fn x -> Integer.to_string(x.subcatid) end)
        |> Enum.filter(fn x -> String.length(x) == 6 end)
        |> Enum.sort()
        |> List.last()

      subcatid = String.to_integer(prev_subcatid) + 1
      params = Map.put(params, "subcatid", subcatid)

      brand = BN.get_brand_id(conn)
      itemcat = params["itemcat"]

      all =
        for item <- ala_cart_ids do
          abc =
            Repo.all(
              from(
                c in ItemCat,
                where: c.itemcatid == ^item and c.brand_id == ^brand,
                select: %{
                  itemcatcode: c.itemcatcode,
                  itemcatid: c.itemcatid,
                  itemcatname: c.itemcatname
                }
              )
            )
            |> hd
        end

      branches =
        Repo.all(from(m in Branch, select: %{name: m.branchname, id: m.branchid}))
        |> Enum.filter(fn x -> x.id != 0 end)

      render(
        conn,
        "combo_new_price.html",
        brand: brand,
        params: params,
        all: all,
        branches: branches,
        itemcat: itemcat,
        price_code: params["price_code"]
      )
    end
  end

  def combo_create_price(conn, params) do
    pa = params["a"]

    count =
      for cat <- pa do
        count = elem(cat, 1)["all_item"] |> String.split(",") |> Enum.count()
      end

    a =
      if Enum.all?(count, fn x -> x == 1 end) do
        true
      else
        false
      end

    if a == true do
      brand = BN.get_brand_id(conn)

      menu_catalog =
        Repo.all(
          from(
            m in BoatNoodle.BN.MenuCatalog,
            where: m.brand_id == ^brand,
            select: %{id: m.id, name: m.name}
          )
        )

      pr = params["a"] |> Enum.map(fn x -> x end) |> hd |> elem(1)
      item_name = pr["itemname"]
      item_desc = pr["itemdesc"]
      item_code = pr["itemcode"]
      item_cat = pr["itemcat"]
      price_code = pr["price_code"]
      is_default_combo = params["item"]["is_default_combo"]
      is_activate = params["item"]["is_activate"]

      enable_discount = params["item"]["enable_discount"]

      included_spend = params["item"]["included_spend"]

      render(
        conn,
        "combo_new_price_unselect.html",
        params: pa,
        menu_catalog: menu_catalog,
        price_code: price_code,
        item_name: item_name,
        item_desc: item_desc,
        item_code: item_code,
        item_cat: item_cat,
        is_default_combo: is_default_combo,
        is_activate: is_activate,
        enable_discount: enable_discount,
        included_spend: included_spend
      )
    else
      pr = params["a"] |> Enum.map(fn x -> x end) |> hd |> elem(1)
      item_name = pr["itemname"]
      item_desc = pr["itemdesc"]
      item_code = pr["itemcode"]
      item_cat = pr["itemcat"]
      price_code = pr["price_code"]
      is_default_combo = params["item"]["is_default_combo"]
      is_activate = params["item"]["is_activate"]

      enable_discount = params["item"]["enable_discount"]

      included_spend = params["item"]["included_spend"]

      render(
        conn,
        "combo_new_price_update.html",
        params: pa,
        price_code: price_code,
        item_name: item_name,
        item_desc: item_desc,
        item_code: item_code,
        item_cat: item_cat,
        is_default_combo: is_default_combo,
        is_activate: is_activate,
        enable_discount: enable_discount,
        included_spend: included_spend
      )
    end
  end

  def combo_branch(conn, params) do
    com = params["com"]
    items = params["item"]

    is_default_combo = params["is_default_combo"]
    is_activate = params["is_activate"]
    enable_discount = params["enable_discount"]
    included_spend = params["included_spend"]

    brand = BN.get_brand_id(conn)

    menu_catalog =
      Repo.all(
        from(
          m in BoatNoodle.BN.MenuCatalog,
          where: m.brand_id == ^brand,
          select: %{id: m.id, name: m.name}
        )
      )

    item_data = params["item"]

    render(
      conn,
      "combo_branch.html",
      items: items,
      com: com,
      menu_catalog: menu_catalog,
      is_default_combo: is_default_combo,
      is_activate: is_activate,
      enable_discount: enable_discount,
      included_spend: included_spend,
      item_data: item_data
    )
  end

  def combo_unselect(conn, params) do
    all_item = params["item"]

    com = params["com"]

    is_default_combo = params["is_default_combo"]
    is_activate = params["is_activate"]
    enable_discount = params["enable_discount"]
    included_spend = params["included_spend"]

    is_default_combo =
      if is_default_combo == "on" do
        1
      else
        0
      end

    is_activate =
      if is_activate == "on" do
        1
      else
        0
      end

    enable_discount =
      if enable_discount == "on" do
        1
      else
        0
      end

    included_spend =
      if included_spend == "on" do
        1
      else
        0
      end

    prev_subcatid =
      Repo.all(from(c in ItemSubcat, select: %{subcatid: c.subcatid}))
      |> Enum.map(fn x -> Integer.to_string(x.subcatid) end)
      |> Enum.filter(fn x -> String.length(x) == 6 end)
      |> Enum.sort()
      |> List.last()

    subcatid = String.to_integer(prev_subcatid) + 1

    a = params["branc"]
    branchs = a |> Enum.map(fn x -> x end) |> hd |> elem(1) |> String.split(",")

    item_category = com["item_category"]
    itemcat = Repo.get_by(ItemCat, itemcatcode: item_category, brand_id: BN.get_brand_id(conn))
    itemcatid = itemcat.itemcatid |> Integer.to_string()
    itemname = com["item_name"]
    itemcode = com["item_code"]

    price_code = com["product_code"]

    a = itemcode |> String.split_at(2)
    front = elem(a, 0)
    back = elem(a, 1)
    part_code = front <> "0" <> back

    product_code = item_category <> part_code <> price_code
    item_desc = com["item_desc"]
    total_price = com["total_price"]
    brand_id = itemcat.brand_id

    stat = %{
      subcatid: subcatid,
      itemcatid: itemcatid,
      itemname: itemname,
      itemcode: itemcode,
      product_code: product_code,
      price_code: price_code,
      part_code: part_code,
      itemdesc: item_desc,
      itemprice: total_price,
      brand_id: brand_id,
      is_default_combo: is_default_combo,
      is_activate: is_activate,
      enable_disc: enable_discount,
      include_spend: included_spend
    }

    cg2 =
      BoatNoodle.BN.ItemSubcat.changeset(
        %BoatNoodle.BN.ItemSubcat{},
        stat,
        BN.current_user(conn),
        "Create"
      )

    case Repo.insert(cg2) do
      {:ok, itemsubcat} ->
        true

      {:error, changeset} ->
        true
    end

    for branch <- branchs do
      id = branch |> String.to_integer()
      item = Repo.get_by(MenuCatalog, id: id, brand_id: BN.get_brand_id(conn))
      com_items = item.items

      comb =
        if com_items == "" do
          []
        else
          com_items |> String.split(",") |> Enum.uniq()
        end

      comb_id = subcatid |> Integer.to_string()
      all_items = List.insert_at(comb, 0, subcatid)
      new_items = all_items |> Enum.join(",")

      params = %{items: new_items}

      update_menu_catalog =
        BoatNoodle.BN.MenuCatalog.changeset(item, params, BN.current_user(conn), "Update")

      case Repo.update(update_menu_catalog) do
        {:ok, menu_catalog} ->
          true

        _ ->
          IO.puts("failed menu catalog update")
          false
      end
    end

    for item <- all_item do
      itemname = elem(item, 1)["product_name"]
      item_coded = itemname |> String.split_at(3) |> elem(0)
      s = elem(item, 1)["subcatid"] |> String.to_integer()
      item_subcat = Repo.get_by(ItemSubcat, subcatid: s, brand_id: BN.get_brand_id(conn))
      menu_cat_id = item_subcat.itemcatid
      combo_id = subcatid
      combo_qty = elem(item, 1)["cat_limit"]
      comboid2 = combo_id |> Integer.to_string()
      subcatid2 = elem(item, 1)["subcatid"]
      brand_id = itemcat.brand_id

      sub = subcatid2 |> String.to_integer()

      sub =
        if sub < 100 do
          (1000 + sub)
          |> Integer.to_string()
          |> String.split("")
          |> Enum.reject(fn x -> x == "" end)
          |> List.delete_at(0)
          |> Enum.join()
        else
          sub |> Integer.to_string()
        end

      p = (comboid2 <> sub) |> String.to_integer()

      combo_item_id = p

      combo_item_qty = elem(item, 1)["cat_limit"]

      unit_price = 0

      top_up = 0

      printers =
        Repo.all(
          from(
            s in Tag,
            where: s.brand_id == ^BN.get_brand_id(conn),
            select: %{tagid: s.tagid, subcat_ids: s.subcat_ids, combo_item_ids: s.combo_item_ids}
          )
        )
        |> Enum.reject(fn x -> x.subcat_ids == nil end)

      for printer <- printers do
        subcatids = printer.subcat_ids
        all = subcatids |> String.split(",") |> Enum.uniq()

        if Enum.any?(all, fn x -> x == subcatid2 end) do
          combo_id = combo_item_id |> Integer.to_string()
          comboitemids = printer.combo_item_ids
          comb = comboitemids |> String.split(",") |> Enum.uniq()
          all_items = List.insert_at(comb, 0, combo_id)
          new_items = all_items |> Enum.join(",")

          tag = Repo.get_by(Tag, tagid: printer.tagid, brand_id: BN.get_brand_id(conn))

          tag_params = %{combo_item_ids: new_items}

          update_tag =
            BoatNoodle.BN.Tag.changeset(tag, tag_params, BN.current_user(conn), "Update Printer")

          case Repo.update(update_tag) do
            {:ok, tag} ->
              true

            _ ->
              IO.puts("failed tag update")
              false
          end
        end
      end

      stat2 = %{
        menu_cat_id: menu_cat_id,
        combo_id: combo_id,
        combo_qty: combo_qty,
        combo_item_id: combo_item_id,
        combo_item_name: itemname,
        combo_item_code: item_coded,
        combo_item_qty: combo_item_qty,
        unit_price: unit_price,
        top_up: top_up,
        brand_id: brand_id
      }

      create_combo_details =
        BoatNoodle.BN.ComboDetails.changeset(
          %BoatNoodle.BN.ComboDetails{},
          stat2,
          BN.current_user(conn),
          "Create Combo Details"
        )

      case Repo.insert(create_combo_details) do
        {:ok, combo_details} ->
          combo_details =
            Repo.get_by(
              ComboDetails,
              combo_item_id: combo_details.combo_item_id,
              brand_id: BN.get_brand_id(conn)
            )

          a = params["branc"]
          branchs = a |> Enum.map(fn x -> x end) |> hd |> elem(1) |> String.split(",")

          for branch <- branchs do
            id = branch |> String.to_integer()
            catalog = Repo.get_by(MenuCatalog, id: id, brand_id: BN.get_brand_id(conn))

            combo_items = catalog.combo_items

            comb =
              if combo_items == "" do
                []
              else
                combo_items |> String.split(",") |> Enum.uniq()
              end

            combo_id = combo_details.id |> Integer.to_string()

            all_combo_items = List.insert_at(comb, 0, combo_id)

            new = all_combo_items |> Enum.join(",")

            catalog_params = %{combo_items: new}

            update_menu_catalog =
              BoatNoodle.BN.MenuCatalog.changeset(
                catalog,
                catalog_params,
                BN.current_user(conn),
                "Update Menu Catalog"
              )

            case Repo.update(update_menu_catalog) do
              {:ok, tag} ->
                true

              _ ->
                IO.puts("failed menu catalog update")
                false
            end
          end
      end
    end

    conn
    |> put_flash(:info, "Combo Created")
    |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))
  end

  def combo_finish(conn, params) do
    combo = params["item"]
    all_item = params["all"]

    is_default_combo =
      if params["is_default_combo"] == "on" do
        1
      else
        0
      end

    is_activate =
      if params["is_activate"] == "on" do
        1
      else
        0
      end

    enable_discount =
      if params["included_spend"] == "on" do
        1
      else
        0
      end

    included_spend =
      if params["included_spend"] == "on" do
        1
      else
        0
      end

    item_category = combo["itemcat"]
    item_code = combo["itemcode"]

    price_code = combo["price_code"]

    a = combo["itemcode"] |> String.split_at(2)
    front = elem(a, 0)
    back = elem(a, 1)
    part_code = front <> "0" <> back

    prev_subcatid =
      Repo.all(from(c in ItemSubcat, select: %{subcatid: c.subcatid}))
      |> Enum.map(fn x -> Integer.to_string(x.subcatid) end)
      |> Enum.sort()
      |> List.last()

    itemcat = Repo.get_by(ItemCat, itemcatcode: item_category, brand_id: BN.get_brand_id(conn))

    subcatid = String.to_integer(prev_subcatid) + 1
    itemcatid = itemcat.itemcatid |> Integer.to_string()
    itemname = combo["itemname"]
    itemcode = item_code
    product_code = item_category <> part_code <> price_code
    item_desc = combo["itemdesc"]
    total_price = combo["total_price"]
    brand_id = itemcat.brand_id

    stat = %{
      subcatid: subcatid,
      itemcatid: itemcatid,
      itemname: itemname,
      itemcode: itemcode,
      product_code: product_code,
      price_code: price_code,
      part_code: part_code,
      itemdesc: item_desc,
      itemprice: total_price,
      brand_id: brand_id,
      is_combo: 1,
      is_default_combo: is_default_combo,
      is_activate: is_activate,
      enable_disc: enable_discount,
      include_spend: included_spend
    }

    cg2 =
      BoatNoodle.BN.ItemSubcat.changeset(
        %BoatNoodle.BN.ItemSubcat{},
        stat,
        BN.current_user(conn),
        "Create Combo"
      )

    case Repo.insert(cg2) do
      {:ok, itemsubcat} ->
        true

      {:error, changeset} ->
        true
    end

    # a = params["branc"]
    # branchs = a |> Enum.map(fn x -> x end) |> hd |> elem(1) |> String.split(",")

    # for branch <- branchs do
    #   id = branch |> String.to_integer()

    #   item = Repo.get_by(MenuCatalog, id: id, brand_id: BN.get_brand_id(conn))
    #   com_items = item.items
    #   comb = com_items |> String.split(",") |> Enum.uniq()
    #   comb_id = subcatid |> Integer.to_string()
    #   all_items = List.insert_at(comb, 0, subcatid)
    #   new_items = all_items |> Enum.join(",")

    #   params = %{items: new_items}

    #   update_menu_catalog =
    #     BoatNoodle.BN.MenuCatalog.changeset(item, params, BN.current_user(conn), "Update")

    #   case Repo.update(update_menu_catalog) do
    #     {:ok, menu_catalog} ->
    #       true

    #     _ ->
    #       IO.puts("failed menu catalog update")
    #       false
    #   end
    # end

    for item <- all_item do
      itemname = elem(item, 1)["product_name"]
      item_coded = itemname |> String.split_at(3) |> elem(0)
      s = elem(item, 1)["subcatid"] |> String.to_integer()

      itemcat = Repo.get_by(ItemSubcat, subcatid: s, brand_id: BN.get_brand_id(conn))

      itemcat2 =
        Repo.get_by(
          ItemCat,
          itemcatname: elem(item, 1)["item_cat"],
          brand_id: BN.get_brand_id(conn)
        )

      menu_cat_id = itemcat2.itemcatid
      combo_id = subcatid
      combo_qty = elem(item, 1)["cat_limit"]
      comboid2 = combo_id |> Integer.to_string()
      subcatid2 = elem(item, 1)["subcatid"]
      brand_id = itemcat.brand_id

      sub = subcatid2 |> String.to_integer()

      sub =
        if sub < 100 do
          (1000 + sub)
          |> Integer.to_string()
          |> String.split("")
          |> Enum.reject(fn x -> x == "" end)
          |> List.delete_at(0)
          |> Enum.join()
        else
          sub |> Integer.to_string()
        end

      p = (comboid2 <> sub) |> String.to_integer()

      combo_item_id = p

      combo_item_qty = elem(item, 1)["cat_limit"]

      unit_price = elem(item, 1)["cost_price"]

      top_up = elem(item, 1)["top_up"]

      printers =
        Repo.all(
          from(
            s in Tag,
            where: s.brand_id == ^BN.get_brand_id(conn),
            select: %{tagid: s.tagid, subcat_ids: s.subcat_ids, combo_item_ids: s.combo_item_ids}
          )
        )

      for printer <- printers do
        subcatids = printer.subcat_ids

        if subcatids != nil do
          all = subcatids |> String.split(",") |> Enum.uniq()

          if Enum.any?(all, fn x -> x == subcatid2 end) do
            combo_id = combo_item_id |> Integer.to_string()
            comboitemids = printer.combo_item_ids
            comb = comboitemids |> String.split(",") |> Enum.uniq()
            all_items = List.insert_at(comb, 0, combo_id)
            new_items = all_items |> Enum.join(",")

            tag = Repo.get_by(Tag, tagid: printer.tagid, brand_id: BN.get_brand_id(conn))

            tag_params = %{combo_item_ids: new_items}

            update_tag =
              BoatNoodle.BN.Tag.changeset(
                tag,
                tag_params,
                BN.current_user(conn),
                "Update Printer"
              )

            case Repo.update(update_tag) do
              {:ok, tag} ->
                true

              _ ->
                IO.puts("failed tag update")
                false
            end
          end
        end
      end

      stat2 = %{
        menu_cat_id: menu_cat_id,
        combo_id: combo_id,
        combo_qty: combo_qty,
        combo_item_id: combo_item_id,
        combo_item_name: itemname,
        combo_item_code: item_coded,
        combo_item_qty: combo_item_qty,
        unit_price: unit_price,
        top_up: top_up,
        brand_id: brand_id
      }

      create_combo_details =
        BoatNoodle.BN.ComboDetails.changeset(
          %BoatNoodle.BN.ComboDetails{},
          stat2,
          BN.current_user(conn),
          "Create Combo Details"
        )

      case Repo.insert(create_combo_details) do
        {:ok, combo_details} ->
          combo_d =
            Repo.get_by(ComboDetails,
              combo_item_id: combo_item_id,
              combo_id: combo_id,
              combo_item_code: item_coded,
              brand_id: BN.get_brand_id(conn),
              menu_cat_id: menu_cat_id
            )

          # a = params["branc"]
          # branchs = a |> Enum.map(fn x -> x end) |> hd |> elem(1) |> String.split(",")

          # for branch <- branchs do
          #   id = branch |> String.to_integer()
          #   catalog = Repo.get_by(MenuCatalog, id: id, brand_id: BN.get_brand_id(conn))

          #   combo_items = catalog.combo_items
          #   comb = combo_items |> String.split(",") |> Enum.uniq()

          #   combo_id = combo_d.id |> Integer.to_string()

          #   all_combo_items = List.insert_at(comb, 0, combo_id)

          #   new = all_combo_items |> Enum.join(",")

          #   catalog_params = %{combo_items: new}

          #   update_menu_catalog =
          #     BoatNoodle.BN.MenuCatalog.changeset(
          #       catalog,
          #       catalog_params,
          #       BN.current_user(conn),
          #       "Update Menu Catalog"
          #     )

          #   case Repo.update(update_menu_catalog) do
          #     {:ok, tag} ->
          #       true

          #     _ ->
          #       IO.puts("failed menu catalog update")
          #       false
          #   end
          # end
      end
    end

    conn
    |> put_flash(:info, "Combo Created")
    |> redirect(to: menu_item_path(conn, :combos, BN.get_domain(conn)))
  end

  def combo_new(conn, _params) do
    brand = BN.get_brand_id(conn)

    menu_item =
      Repo.all(
        from(
          i in ItemCat,
          where: i.category_type == ^"COMBO" and i.brand_id == ^BN.get_brand_id(conn)
        )
      )

    ala_carte1 =
      Repo.all(
        from(
          s in ItemSubcat,
          left_join: i in ItemCat,
          on: i.itemcatid == s.itemcatid,
          where:
            s.brand_id == ^BN.get_brand_id(conn) and i.category_type == ^"COMBO" and
              i.brand_id == ^BN.get_brand_id(conn),
          group_by: [s.itemcode],
          select: %{
            itemcatcode: i.itemcatcode,
            itemcatid: i.itemcatid,
            itemcatname: i.itemcatname
          },
          order_by: [asc: i.itemcatcode]
        )
      )
      |> Enum.uniq()

    ala_carte =
      Repo.all(
        from(
          c in ItemCat,
          where: c.category_type != "COMBO" and c.itemcatcode != "empty" and c.brand_id == ^brand,
          select: %{
            itemcatcode: c.itemcatcode,
            itemcatid: c.itemcatid,
            itemcatname: c.itemcatname
          }
        )
      )

    price_code =
      Repo.all(
        from(
          c in ItemSubcat,
          where: c.brand_id == ^BN.get_brand_id(conn),
          select: %{
            price_code: c.price_code
          }
        )
      )
      |> Enum.uniq()

    render(
      conn,
      "combo_new.html",
      price_code: price_code,
      menu_item: menu_item,
      ala_carte: ala_carte,
      ala_carte1: menu_item
    )
  end

  def add_item(conn, %{"subcatid" => id}) do
    id = String.to_integer(id)
    item_subcat = Repo.get_by(ItemSubcat, subcatid: id, brand_id: BN.get_brand_id(conn))

    user = BoatNoodle.Repo.get_by(BoatNoodle.BN.User, id: conn.private.plug_session["user_id"])

    ala_carte1 =
      Repo.all(
        from(
          c in ItemCat,
          where: c.brand_id == ^BN.get_brand_id(conn) and c.visable == ^1,
          select: %{
            itemcatcode: c.itemcatcode,
            itemcatdesc: c.itemcatdesc,
            itemcatid: c.itemcatid,
            itemcatname: c.itemcatname
          }
        )
      )

    item_subcats =
      Repo.all(
        from(
          s in ItemSubcat,
          where: s.price_code == ^item_subcat.price_code and s.brand_id == ^BN.get_brand_id(conn),
          order_by: [s.itemcode]
        )
      )

    render(
      conn,
      "add_combo_item.html",
      item_subcat: item_subcat,
      ala_carte1: ala_carte1,
      item_subcats: item_subcats
    )
  end

  defp get_item_cat_name(cat_name, brand_id) do
    if cat_name != nil do
      item_cat = Repo.get_by(ItemCat, itemcatname: cat_name, brand_id: brand_id)

      cat =
        if item_cat != nil do
          item_cat.itemcatid
        else
          0
        end

      cat
    else
      0
    end
  end

  defp get_item_subcat(brand_id) do
    item_subcat =
      BN.list_item_subcat()
      |> Enum.filter(fn x -> x.brand_id == brand_id end)
      |> Enum.filter(fn x -> x.subcatid < 10000 end)

    subcat =
      if item_subcat != [] do
        Enum.map(item_subcat, fn x -> x.subcatid end) |> List.last()
      else
        1
      end
  end

  def upload_menu_item(conn, params) do
    file = params["menu_item"]["file"]

    {:ok, binary} = File.read(file.path)

    data = binary |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
    headers = hd(data) |> Enum.map(fn x -> String.trim(x, " ") end)
    contents = tl(data) |> Enum.reject(fn x -> x == [""] end)

    g =
      for content <- contents do
        item_cat = content |> Enum.at(3)

        subcatid = get_item_subcat(BN.get_brand_id(conn)) + 1

        itemcatid = get_item_cat_name(item_cat, BN.get_brand_id(conn))
        itemcatid = itemcatid |> Integer.to_string()

        itemname = content |> Enum.at(2)

        itemcode = content |> Enum.at(1)

        a =
          if itemcode == "" do
            "UK"
          else
            itemcode
          end

        product_code = ""

        price_code = content |> Enum.at(10)

        price_code =
          if price_code == "" do
            "A"
          end

        part_code = content |> Enum.at(9)

        itemdesc = content |> Enum.at(4)

        itemprice = content |> Enum.at(5)

        brand_id = BN.get_brand_id(conn)

        is_activate = 1

        params = %{
          is_activate: is_activate,
          subcatid: subcatid,
          itemcatid: itemcatid,
          itemname: itemname,
          itemcode: a,
          product_code: product_code,
          price_code: price_code,
          part_code: part_code,
          itemdesc: itemdesc,
          itemprice: itemprice,
          brand_id: brand_id
        }

        cg2 =
          BoatNoodle.BN.ItemSubcat.changeset(
            %BoatNoodle.BN.ItemSubcat{},
            params,
            BN.current_user(conn),
            "Upload ItemSubcat"
          )

        if cg2.valid? == false do
        end

        case Repo.insert(cg2) do
          {:ok, itemsubcat} ->
            true

          {:error, changeset} ->
            true
        end
      end

    conn
    |> put_flash(:info, "Menu Item Successfully Upload")
    |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))
  end

  def post_add_item(conn, params) do
    user = BoatNoodle.Repo.get_by(BoatNoodle.BN.User, id: conn.private.plug_session["user_id"])
    subcatid = params["subcatid"]
    itemcatid = params["itemcat"]
    combo_qty = params["combo_qty"]

    old_combo_items =
      Repo.all(
        from(
          c in ComboDetails,
          where:
            c.combo_id == ^subcatid and c.menu_cat_id == ^itemcatid and
              c.brand_id == ^BN.get_brand_id(conn) and c.is_delete == ^0
        )
      )

    ids = params[itemcatid] |> Map.keys()

    combo_items =
      for id <- ids do
        combo_detail_param = params[itemcatid][id]
        subcat = Repo.get_by(ItemSubcat, brand_id: BN.get_brand_id(conn), subcatid: id)

        id_int =
          if String.length(id) == 3 do
            id
          else
            (String.to_integer(id) + 1000)
            |> Integer.to_string()
            |> String.split("")
            |> Enum.reject(fn x -> x == "" end)
            |> List.delete_at(0)
            |> Enum.join("")
          end

        # IEx.pry()

        if combo_detail_param["unit_price"] != "" do
          {:ok, combo_item} =
            ComboDetails.changeset(
              %ComboDetails{},
              %{
                menu_cat_id: itemcatid,
                combo_id: subcatid,
                combo_qty: combo_qty,
                combo_item_id: String.to_integer(subcatid <> id_int),
                combo_item_name: subcat.itemname,
                combo_item_code: subcat.itemcode,
                combo_item_qty: combo_qty,
                update_qty: 0,
                unit_price: Decimal.new(combo_detail_param["unit_price"]),
                topup_price: Decimal.new(combo_detail_param["topup_price"]),
                brand_id: BN.get_brand_id(conn)
              },
              user.id,
              "new"
            )
            |> Repo.insert()

          combo_item
        else
          nil
        end
      end
      |> Enum.reject(fn x -> x == nil end)

    branches = Repo.all(from(b in Branch, where: b.brand_id == ^BN.get_brand_id(conn)))

    affected_branches =
      for branch <- branches do
        id = branch.menu_catalog
        item = Repo.get_by(MenuCatalog, id: id, brand_id: BN.get_brand_id(conn))
        com_items = item.items
        comb = com_items |> String.split(",")

        if Enum.any?(comb, fn x -> x == subcatid end) do
          menu_cat_combo_items = item.combo_items |> String.split(",")
          list = Enum.map(combo_items, fn x -> x.id end)
          old_list = Enum.map(old_combo_items, fn x -> x.id end)

          new_list =
            (menu_cat_combo_items ++ (list -- old_list))
            |> Enum.join(",")
            |> String.trim_trailing(",")

          params = %{combo_items: new_list}

          update_menu_catalog =
            BoatNoodle.BN.MenuCatalog.changeset(item, params, BN.current_user(conn), "Update")

          case Repo.update(update_menu_catalog) do
            {:ok, menu_catalog} ->
              true

            _ ->
              IO.puts("failed menu catalog update")
              false
          end

          branch.branchid
        else
          nil
        end
      end
      |> Enum.reject(fn x -> x == nil end)

    Task.start_link(__MODULE__, :add_combo_item_to_printers, [
      affected_branches,
      combo_items,
      conn,
      old_combo_items
    ])

    for item <- old_combo_items do
      ComboDetails.changeset(item, %{is_delete: 1}, user.id, "delete") |> Repo.update()
    end

    conn
    |> put_flash(:info, "Combo item added!")
    |> redirect(to: item_subcat_path(conn, :combo_show, BN.get_domain(conn), subcatid))
  end

  def add_combo_item_to_printers(affected_branches, combo_items, conn, old_combo_items) do
    printers =
      Repo.all(
        from(
          s in Tag,
          where: s.brand_id == ^BN.get_brand_id(conn) and s.branch_id in ^affected_branches,
          select: %{tagid: s.tagid, subcat_ids: s.subcat_ids, combo_item_ids: s.combo_item_ids}
        )
      )
      |> Enum.reject(fn x -> x.subcat_ids == nil end)

    for branch_id <- affected_branches do
      for combo_item <- combo_items do
        subcat_id =
          (String.split(Integer.to_string(combo_item.combo_item_id), "") --
             String.split(Integer.to_string(combo_item.combo_id), ""))
          |> Enum.join("")

        sb = Repo.get_by(ItemSubcat, brand_id: BN.get_brand_id(conn), subcatid: subcat_id)

        if sb.tagdesc != nil and sb.printer != nil do
          printer =
            Repo.get_by(
              Tag,
              branch_id: BN.get_brand_id(conn),
              tagdesc: sb.tagdesc,
              printer: sb.printer
            )

          if printer != nil do
            list = printer.combo_item_ids |> String.split(",") |> Enum.uniq()

            new_list =
              List.insert_at(list, 0, combo_item.combo_item_id)
              |> Enum.join(",")
              |> Enum.sort()
              |> String.trim_trailing(",")

            update_tag =
              BoatNoodle.BN.Tag.changeset(
                printer,
                %{combo_item_ids: new_list},
                BN.current_user(conn),
                "Update Printer"
              )

            case Repo.update(update_tag) do
              {:ok, tag} ->
                true

              _ ->
                IO.puts("failed tag update")
                false
            end
          end
        end
      end
    end

    for printer <- printers do
      combo_item_ids = printer.combo_item_ids
      all = combo_item_ids |> Enum.uniq() |> String.split(",")
      old_current_list = Enum.map(old_combo_items, fn x -> x.combo_item_id end)
      new_list = all -- old_current_list

      new_items = new_list |> Enum.join(",") |> String.trim_trailing(",")

      tag = Repo.get_by(Tag, tagid: printer.tagid, brand_id: BN.get_brand_id(conn))

      tag_params = %{combo_item_ids: new_items}

      update_tag =
        BoatNoodle.BN.Tag.changeset(tag, tag_params, BN.current_user(conn), "Update Printer")

      case Repo.update(update_tag) do
        {:ok, tag} ->
          true

        _ ->
          IO.puts("failed tag update")
          false
      end
    end
  end

  def combo_show(conn, %{"subcatid" => id}) do
    id = String.to_integer(id)
    item_subcat = Repo.get_by(ItemSubcat, subcatid: id, brand_id: BN.get_brand_id(conn))

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

    same_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.itemcode == ^item_subcat.itemcode and s.is_delete == ^0 and
              s.brand_id == ^BN.get_brand_id(conn),
          order_by: [asc: s.price_code]
        )
      )

    same_items =
      if same_items == [] do
        [item_subcat]
      else
        Repo.all(
          from(
            s in ItemSubcat,
            where:
              s.itemcode == ^item_subcat.itemcode and s.is_delete == ^0 and
                s.brand_id == ^BN.get_brand_id(conn),
            order_by: [asc: s.price_code]
          )
        )
      end

    ids = same_items |> Enum.map(fn x -> x.subcatid end)

    combo_items =
      Repo.all(
        from(
          c in ComboDetails,
          left_join: i in ItemCat,
          on: i.itemcatid == c.menu_cat_id,
          left_join: b in Brand,
          on: c.brand_id == b.id,
          where: c.combo_id in ^ids and i.brand_id == ^BN.get_brand_id(conn) and c.is_delete == 0,
          select: %{
            combo_item_name: c.combo_item_name,
            combo_category: i.itemcatname,
            combo_qty: c.combo_qty,
            combo_item_qty: c.combo_item_qty,
            unit_price: c.unit_price,
            top_up: c.top_up,
            combo_item_code: c.combo_item_code,
            combo_item_id: c.combo_item_id,
            combo_id: c.combo_id,
            is_delete: c.is_delete
          }
        )
      )

    no_selection_combo_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.brand_id == ^BN.get_brand_id(conn) and
              s.itemcatid == ^Integer.to_string(item_subcat.subcatid)
        )
      )

    render(
      conn,
      "combo_show.html",
      item_subcat: item_subcat,
      same_items: same_items,
      combo_items: combo_items,
      no_selection_combo_items: no_selection_combo_items,
      brand_name: BN.get_domain(conn),
      admin_menus: admin_menus,
      url: url
    )
  end

  def item_show(conn, %{"subcatid" => id}) do
    item_subcat = Repo.get_by(ItemSubcat, subcatid: id, brand_id: BN.get_brand_id(conn))

    same_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.itemcode == ^item_subcat.itemcode and s.is_comboitem == ^0 and s.is_delete == ^0 and
              s.brand_id == ^BN.get_brand_id(conn),
          order_by: [asc: s.price_code]
        )
      )

    render(conn, "show.html", item_subcat: item_subcat, same_items: same_items)
  end

  @doc """
  currently they want to add the printers according to branch and printers
  1 printer can only 1 item price code...

  show all the branch, choose 1 printer to be assigned...

  because 1 item can only exist in 1 printer

  """
  def item_edit(conn, %{"subcatid" => id}) do
    item_subcat = Repo.get_by(ItemSubcat, subcatid: id, brand_id: BN.get_brand_id(conn))

    changes =
      Repo.all(
        from(
          m in ModalLog,
          left_join: u in User,
          on: u.id == m.user_id,
          where: m.name == ^"item_subcat",
          select: %{
            description: m.description,
            user_id: u.username,
            inserted_at: m.inserted_at,
            action: m.action
          },
          order_by: [desc: m.inserted_at, desc: m.id]
        )
      )
      |> Enum.map(fn x -> {Poison.decode!(x.description), x.user_id, x.inserted_at, x.action} end)
      |> Enum.filter(fn x -> elem(x, 0)["subcatid"] == String.to_integer(id) end)

    same_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.itemcode == ^item_subcat.itemcode and s.brand_id == ^BN.get_brand_id(conn) and
              s.is_comboitem == ^0 and s.is_delete == ^0,
          order_by: [asc: s.price_code]
        )
      )

    price_codes = same_items |> Enum.map(fn x -> %{code: x.price_code, price: x.itemprice} end)

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

    itemcodes =
      itemcodes
      |> Enum.reject(fn x -> x.code == "" end)
      |> Enum.map(fn x ->
        %{
          name: x.name,
          code: x.code,
          group: hd(Enum.reject(String.split(x.code, ""), fn x -> x == "" end))
        }
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

    # show all the branch's printers, and group them...

    printers =
      Repo.all(
        from(
          t in Tag,
          left_join: b in Branch,
          on: b.branchid == t.branch_id,
          where:
            t.branch_id != ^0 and t.brand_id == ^BN.get_brand_id(conn) and
              b.brand_id == ^BN.get_brand_id(conn),
          select: %{
            tag_id: t.tagid,
            branch_id: b.branchid,
            branch: b.branchname,
            name: t.tagname,
            subcat_ids: t.subcat_ids
          }
        )
      )
      |> Enum.group_by(fn x -> x.branch end)

    branch_names = printers |> Map.keys()

    # the printer has subcat ids
    # because this item has multiple codes
    # need to check with each of the tag subcat_ids 
    render(
      conn,
      "edit_item.html",
      item_subcat: item_subcat,
      itemcodes: itemcodes,
      item_cat: item_cat,
      price_codes: price_codes,
      printers: printers,
      changes: changes
    )
  end

  def edit_combo(conn, %{"subcatid" => id, "price_code" => price_code}) do
    combo =
      Repo.get_by(ItemSubcat, %{
        subcatid: id,
        brand_id: BN.get_brand_id(conn),
        price_code: price_code
      })

    catalog = Repo.get_by(MenuCatalog, id: id, brand_id: BN.get_brand_id(conn))

    com =
      Repo.all(
        from(
          m in ComboDetails,
          where: m.combo_id == ^id,
          select: %{
            combo_id: m.combo_id,
            id: m.id,
            combo_item_id: m.combo_item_id,
            combo_qty: m.combo_qty,
            itemname: m.combo_item_name,
            unit_price: m.unit_price,
            top_up: m.top_up
          }
        )
      )

    branchs =
      Repo.all(
        from(
          m in MenuCatalog,
          select: %{
            id: m.id,
            name: m.name,
            items: m.items,
            combo_items: m.combo_items
          }
        )
      )

    branch_selected =
      for branch <- branchs do
        gp = branch.items |> Enum.uniq() |> String.split(",") |> Enum.reject(fn x -> x == "" end)

        if Enum.any?(gp, fn x -> x == id end) do
          branch_selected = branch.id
        end
      end
      |> Enum.filter(fn x -> x != nil end)

    render(
      conn,
      "edit_combo_new.html",
      branch_selected: branch_selected,
      id: id,
      branchs: branchs,
      com: com,
      combo: combo
    )
  end

  def edit_combo_detail(conn, params) do
    subcatid = params["subcatid"]

    item_subcat = Repo.get_by(ItemSubcat, %{subcatid: subcatid, brand_id: BN.get_brand_id(conn)})

    item_price = params["itemprice"]

    price_code = params["price_code"]

    BN.update_item_subcat(item_subcat, %{itemprice: item_price})

    all = params["Item"]

    for item <- all do
      combo =
        Repo.get_by!(ComboDetails, %{
          id: elem(item, 1)["id"],
          combo_item_name: elem(item, 0),
          combo_item_id: elem(item, 1)["combo_item_id"]
        })

      unit_price = elem(item, 1)["unit_price"]
      top_up = elem(item, 1)["top_up"]

      BN.update_combo_details(combo, %{unit_price: unit_price, top_up: top_up})
    end

    conn
    |> put_flash(:info, "Combo Updated")
    |> redirect(to: item_subcat_path(conn, :combo_show, BN.get_brand_id(conn), subcatid))
  end

  def show_voucher(conn, _params) do
    changeset =
      BoatNoodle.BN.ItemSubcat.changeset(
        %BoatNoodle.BN.ItemSubcat{},
        %{},
        BN.current_user(conn),
        "New"
      )

    discount =
      Repo.all(
        from(
          s in Discount,
          where: s.brand_id == ^BN.get_brand_id(conn) and s.is_delete == 0 and s.is_visable == 1,
          select: %{discountid: s.discountid, discname: s.discname}
        )
      )

    render(conn, "show_voucher.html", discount: discount, changeset: changeset)
  end

  def index(conn, _params) do
    item_subcat = BN.list_item_subcat()
    render(conn, "index.html", item_subcat: item_subcat)
  end

  def new(conn, _params) do
    changeset = BN.change_item_subcat(%ItemSubcat{})
    # render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item_subcat" => item_subcat_params}) do
    case BN.create_item_subcat(item_subcat_params) do
      {:ok, item_subcat} ->
        conn
        |> put_flash(:info, "Item subcat created successfully.")
        |> redirect(to: item_subcat_path(conn, :show, item_subcat))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item_subcat = BN.get_item_subcat!(id)
    render(conn, "show.html", item_subcat: item_subcat)
  end

  def edit(conn, %{"id" => id}) do
    item_subcat = BN.get_item_subcat!(id)
    changeset = BN.change_item_subcat(item_subcat)
    render(conn, "edit.html", item_subcat: item_subcat, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item_subcat" => item_subcat_params}) do
    item_subcat = BN.get_item_subcat!(id)

    case BN.update_item_subcat(item_subcat, item_subcat_params) do
      {:ok, item_subcat} ->
        conn
        |> put_flash(:info, "Item subcat updated successfully.")
        |> redirect(to: item_subcat_path(conn, :show, item_subcat))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", item_subcat: item_subcat, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item_subcat = BN.get_item_subcat!(id)
    {:ok, _item_subcat} = BN.delete_item_subcat(item_subcat)

    conn
    |> put_flash(:info, "Item subcat deleted successfully.")
    |> redirect(to: item_subcat_path(conn, :index, BN.get_domain(conn)))
  end
end
