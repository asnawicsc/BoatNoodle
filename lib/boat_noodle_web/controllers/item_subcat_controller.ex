defmodule BoatNoodleWeb.ItemSubcatController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.{MenuItem, ItemSubcat, ComboDetails, Branch, ItemCat}
  require IEx

  def combo_create(conn, params) do
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
    cg = ItemSubcat.changeset(%ItemSubcat{}, params)

    itemcat = params["itemcat"]

    all =
      for item <- ala_cart_ids do
        abc =
          Repo.all(
            from(
              c in ItemCat,
              where: c.itemcatid == ^item,
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
      params: params,
      all: all,
      branches: branches,
      itemcat: itemcat
    )
  end

  def combo_create_price(conn, params) do
    pr = params |> Enum.map(fn x -> x end) |> hd |> elem(1)
    item_name = pr["itemname"]
    item_desc = pr["itemdesc"]
    item_code = pr["itemcode"]
    item_cat = pr["itemcat"]

    render(
      conn,
      "combo_new_price_update.html",
      params: params,
      item_name: item_name,
      item_desc: item_desc,
      item_code: item_code,
      item_cat: item_cat
    )
  end

  def combo_finish(conn, params) do
    combos = params["com"]
    all_item = params["all"]

    for combo <- combos do
      item_category = elem(combo, 1)["item_category"]
      item_code = elem(combo, 1)["item_code"]

      price_code = elem(combo, 1)["product_code"]

      a = elem(combo, 1)["item_code"] |> String.split_at(2)
      front = elem(a, 0)
      back = elem(a, 1)
      part_code = front <> "0" <> back

      prev_subcatid =
        Repo.all(from(c in ItemSubcat, select: %{subcatid: c.subcatid}))
        |> Enum.map(fn x -> Integer.to_string(x.subcatid) end)
        |> Enum.filter(fn x -> String.length(x) == 6 end)
        |> Enum.sort()
        |> List.last()

      itemcat = Repo.get_by(ItemCat, itemcatcode: item_category)

      subcatid = String.to_integer(prev_subcatid) + 1
      itemcatid = itemcat.itemcatid |> Integer.to_string()
      itemname = elem(combo, 1)["item_name"]
      itemcode = item_code
      product_code = item_category <> part_code <> price_code
      item_desc = elem(combo, 1)["item_desc"]
      total_price = elem(combo, 1)["total_price"]

      stat =
        BoatNoodle.BN.create_item_subcat(%{
          subcatid: subcatid,
          itemcatid: itemcatid,
          itemname: itemname,
          itemcode: itemcode,
          product_code: product_code,
          price_code: price_code,
          part_code: part_code,
          itemdesc: item_desc,
          itemprice: total_price
        })

      case stat do
        {:ok, itemsubcat} ->
          true

        {:error, changeset} ->
          IEx.pry()
          true
      end

      all_combo =
        Enum.map(all_item, fn x -> x end)
        |> Enum.filter(fn x -> elem(x, 1)["price_code"] == price_code end)

      for item <- all_combo do
        itemname = elem(item, 1)["product_name"]
        item_coded = itemname |> String.split_at(3) |> elem(0)
        itemcat = Repo.get_by(ItemCat, itemcatcode: item_category)
        menu_cat_id = itemcat.itemcatid
        combo_id = subcatid
        combo_qty = elem(item, 1)["cat_limit"]
        comboid2 = combo_id |> Integer.to_string()
        subcatid2 = elem(item, 1)["subcatid"]

        sub = subcatid2 |> String.to_integer()

        if sub < 100 do
          sub =
            (1000 + sub)
            |> Integer.to_string()
            |> String.split("")
            |> Enum.reject(fn x -> x == "" end)
            |> List.delete_at(0)
            |> Enum.join()
        else
          sub = sub |> Integer.to_string()
        end

        p = (comboid2 <> sub) |> String.to_integer()

        combo_item_id = p

        combo_item_qty = elem(item, 1)["cat_limit"]

        unit_price = elem(item, 1)["cost_price"]

        top_up = elem(item, 1)["top_up"]

        stat2 =
          BoatNoodle.BN.create_combo_details(%{
            menu_cat_id: menu_cat_id,
            combo_id: combo_id,
            combo_qty: combo_qty,
            combo_item_id: combo_item_id,
            combo_item_name: itemname,
            combo_item_code: item_coded,
            combo_item_qty: combo_item_qty,
            unit_price: unit_price,
            top_up: top_up
          })

        case stat2 do
          {:ok, combo_details} ->
            true

          {:error, changeset} ->
            IEx.pry()
            true
        end
      end
    end

    conn
    |> put_flash(:info, "Combo Created")
    |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))
  end

  def combo_new(conn, _params) do
    menu_item = Repo.all(from(i in MenuItem, where: i.category_type == ^"COMBO"))

    ala_carte1 =
      Repo.all(
        from(
          s in ItemSubcat,
          left_join: i in MenuItem,
          on: i.itemcatid == s.itemcatid,
          where: i.category_type == ^"COMBO",
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
          select: %{
            itemcatcode: c.itemcatcode,
            itemcatid: c.itemcatid,
            itemcatname: c.itemcatname
          }
        )
      )

    # IEx.pry
    render(
      conn,
      "combo_new.html",
      menu_item: menu_item,
      ala_carte: ala_carte,
      ala_carte1: ala_carte1
    )
  end

  def combo_show(conn, %{"subcatid" => id}) do
    item_subcat =
      Repo.all(
        from(i in ItemSubcat, where: i.subcatid == ^id and i.brand_id == ^BN.get_brand_id(conn))
      )
      |> hd()

    # IEx.pry()

    same_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where: s.itemcode == ^item_subcat.itemcode and s.is_delete == ^0,
          order_by: [asc: s.price_code]
        )
      )

    if same_items == [] do
      same_items = [item_subcat]
    end

    ids = same_items |> Enum.map(fn x -> x.subcatid end)
    combo_items = Repo.all(from(c in ComboDetails, where: c.combo_id in ^ids))

    no_selection_combo_items =
      Repo.all(
        from(s in ItemSubcat, where: s.itemcatid == ^Integer.to_string(item_subcat.subcatid))
      )

    render(
      conn,
      "combo_show.html",
      item_subcat: item_subcat,
      same_items: same_items,
      combo_items: combo_items,
      no_selection_combo_items: no_selection_combo_items,
      brand_name: BN.get_domain(conn)
    )
  end

  def item_show(conn, %{"subcatid" => id}) do
    item_subcat = Repo.get_by(ItemSubcat, subcatid: id, brand_id: BN.get_brand_id(conn))

    same_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.itemcode == ^item_subcat.itemcode and s.is_comboitem == ^0 and s.is_delete == ^0,
          order_by: [asc: s.price_code]
        )
      )

    render(conn, "show.html", item_subcat: item_subcat, same_items: same_items)
  end

  def item_edit(conn, %{"subcatid" => id}) do
    item_subcat = Repo.get_by(ItemSubcat, subcatid: id, brand_id: BN.get_brand_id(conn))

    same_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.itemcode == ^item_subcat.itemcode and s.is_comboitem == ^0 and s.is_delete == ^0,
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

    render(
      conn,
      "edit_item.html",
      item_subcat: item_subcat,
      itemcodes: itemcodes,
      item_cat: item_cat,
      price_codes: price_codes
    )
  end

  def edit_combo(conn, %{"subcatid" => id, "price_code" => price_code}) do
    combo = Repo.get_by(ItemSubcat, %{subcatid: id, price_code: price_code})

    com =
      Repo.all(
        from(
          m in ComboDetails,
          where: m.combo_id == ^id,
          left_join: s in ItemSubcat,
          where: s.itemcode == m.combo_item_code,
          left_join: b in ItemCat,
          where: b.itemcatid == s.itemcatid,
          group_by: b.itemcatid,
          select: %{
            combo_id: m.combo_id,
            id: m.id,
            combo_item_id: m.combo_item_id,
            itemcatname: b.itemcatname,
            combo_qty: m.combo_qty,
            itemname: m.combo_item_name,
            unit_price: m.unit_price,
            top_up: m.top_up
          }
        )
      )
      |> Enum.uniq()

    render(conn, "edit_combo_new.html", com: com, combo: combo)
  end

  def edit_combo_detail(conn, params) do
    subcatid = params["subcatid"]
    item_subcat = BN.get_item_subcat!(subcatid)
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
    |> redirect(to: item_subcat_path(conn, :combo_show, subcatid))
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
