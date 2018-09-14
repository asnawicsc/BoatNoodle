defmodule BoatNoodleWeb.PageController do
  use BoatNoodleWeb, :controller
  use Task
  import Ecto.Query
  require IEx

  def advance(conn, params) do
    users = Repo.all(from(u in User))
    brands = Repo.all(from(b in Brand))

    # html side have a radio button, indicate they can only appear at 1 brand at 1 time.
    render(conn, "advance.html", users: users, brands: brands)
  end

  def experiment4(conn, params) do
    salesids = [
      "BNGS19823",
      "BNGS19884",
      "BNGS20201",
      "BNGS20427",
      "BNGS20456",
      "BNGS20733",
      "BNGS20829",
      "BNGS19641",
      "BNGS19647",
      "BNGS19648",
      "BNGS19663",
      "BNGS19665",
      "BNGS19673",
      "BNGS19704",
      "BNGS19706",
      "BNGS19709",
      "BNGS19731",
      "BNGS19739",
      "BNGS19748",
      "BNGS19750",
      "BNGS19754",
      "BNGS19758",
      "BNGS19759",
      "BNGS19761",
      "BNGS19781",
      "BNGS19808",
      "BNGS19819",
      "BNGS19829",
      "BNGS19830",
      "BNGS19839",
      "BNGS19848",
      "BNGS19858",
      "BNGS19891",
      "BNGS19893",
      "BNGS19902",
      "BNGS19910",
      "BNGS19911",
      "BNGS19944",
      "BNGS19955",
      "BNGS19961",
      "BNGS19988",
      "BNGS19989",
      "BNGS19999",
      "BNGS20010",
      "BNGS20014",
      "BNGS20022",
      "BNGS20030",
      "BNGS20034",
      "BNGS20036",
      "BNGS20043",
      "BNGS20045",
      "BNGS20063",
      "BNGS20067",
      "BNGS20070",
      "BNGS20076",
      "BNGS20090",
      "BNGS20093",
      "BNGS20099",
      "BNGS20107",
      "BNGS20143",
      "BNGS20149",
      "BNGS20170",
      "BNGS20173",
      "BNGS20174",
      "BNGS20192",
      "BNGS20194",
      "BNGS20211",
      "BNGS20212",
      "BNGS20220",
      "BNGS20225",
      "BNGS20235",
      "BNGS20237",
      "BNGS20247",
      "BNGS20253",
      "BNGS20254",
      "BNGS20255",
      "BNGS20265",
      "BNGS20267",
      "BNGS20268",
      "BNGS20315",
      "BNGS20347",
      "BNGS20383",
      "BNGS20397",
      "BNGS20398",
      "BNGS20404",
      "BNGS20443",
      "BNGS20445",
      "BNGS20447",
      "BNGS20459",
      "BNGS20491",
      "BNGS20534",
      "BNGS20548",
      "BNGS20560",
      "BNGS20561",
      "BNGS20572",
      "BNGS20601",
      "BNGS20624",
      "BNGS20659",
      "BNGS20685",
      "BNGS20688",
      "BNGS20691",
      "BNGS20692",
      "BNGS20698",
      "BNGS20702",
      "BNGS20712",
      "BNGS20725",
      "BNGS20736",
      "BNGS20744",
      "BNGS20751",
      "BNGS20773",
      "BNGS20774",
      "BNGS20777",
      "BNGS20807",
      "BNGS20835"
    ]

    # check its combo
    s_date = Date.from_iso8601!("2018-08-01")
    e_date = Date.from_iso8601!("2018-08-31")
    brand_id = BN.get_brand_id(conn) |> Integer.to_string()
    brand_id_int = BN.get_brand_id(conn)

    datas2 =
      Repo.all(
        from(
          s in Sales,
          left_join: sm in SalesMaster,
          on: sm.salesid == s.salesid,
          where: s.brand_id == ^brand_id_int and s.salesdate >= ^s_date and s.salesdate <= ^e_date,
          select: %{
            comboid: sm.combo_id,
            salesid: s.salesid,
            itemid: sm.itemid,
            qty: sm.qty,
            orderid: sm.orderid
          }
        )
      )

    items =
      Repo.all(
        from(
          is in ItemSubcat,
          where: is.brand_id == ^brand_id_int
        )
      )

    combo_details =
      Repo.all(
        from(
          cd in ComboDetails,
          where: cd.brand_id == ^brand_id_int,
          select: %{
            itemid: cd.combo_item_id,
            menu_cat_id: cd.menu_cat_id,
            qty: cd.combo_item_qty,
            combo_id: cd.combo_id
          }
        )
      )

    qty = 1
    subcatid = 999_074

    for salesid <- salesids do
      sms =
        Repo.all(from(sm in SalesMaster, where: sm.salesid == ^salesid))
        |> Enum.filter(fn x -> String.length(Integer.to_string(x.itemid)) == 6 end)

      for sm <- sms do
        combo_qty_checker2(brand_id, sm.itemid, sm.qty, salesid, items, combo_details, datas2)
      end
    end

    conn
    |> put_flash(:info, "Query executed!")
    |> redirect(to: page_path(conn, :index2, BN.get_domain(conn)))
  end

  def experiment3(conn, params) do
    date_range = Date.range(Date.from_iso8601!("2018-08-01"), Date.from_iso8601!("2018-08-31"))
    s_date = Date.from_iso8601!("2018-08-01")
    e_date = Date.from_iso8601!("2018-08-31")

    datas =
      Repo.all(
        from(
          sm in SalesMaster,
          left_join: s in Sales,
          on: sm.salesid == s.salesid,
          left_join: is in ItemSubcat,
          on: is.subcatid == sm.itemid,
          left_join: ic in ItemCat,
          on: is.itemcatid == ic.itemcatid,
          where:
            s.brand_id == ^1 and s.salesdate >= ^s_date and s.salesdate <= ^e_date and
              is.brand_id == ^1 and ic.brand_id == ^1 and is_nil(sm.itemcode)
        )
      )
      |> Enum.filter(fn x -> String.contains?(x.itemname, "G") end)

    for sm <- datas do
      code =
        sm.itemname |> String.split("") |> Enum.reject(fn x -> x == "" end) |> Enum.take(3)
        |> Enum.join()

      cg =
        SalesMaster.changeset(sm, %{
          itemcode: code,
          remaks: "Damien: update the itemcode from the item name string."
        })

      if sm.remaks != nil do
        # IEx.pry()
      end

      Repo.update(cg)
    end

    conn
    |> put_flash(:info, "Query executed")
    |> redirect(to: page_path(conn, :index2, BN.get_domain(conn)))
  end

  def experiment2(conn, params) do
    date_range = Date.range(Date.from_iso8601!("2018-08-01"), Date.from_iso8601!("2018-08-31"))
    s_date = Date.from_iso8601!("2018-08-01")
    e_date = Date.from_iso8601!("2018-08-31")

    branches = Repo.all(from(b in Branch, where: b.brand_id == ^BN.get_brand_id(conn)))

    data =
      for branch <- branches do
        # check_combo_order(
        #   s_date,
        #   e_date,
        #   Integer.to_string(branch.branchid),
        #   BN.get_brand_id(conn)
        # )

        Task.start_link(__MODULE__, :check_combo_order, [
          s_date,
          e_date,
          Integer.to_string(branch.branchid),
          BN.get_brand_id(conn)
        ])
      end

    hd =
      Repo.all(from(h in HistoryData, where: h.name == ^"combo_item_not_tally"))
      |> Enum.reject(fn x -> x.json_map == "[]" end)
      |> Enum.map(fn x -> x.json_map end)
      |> Enum.map(fn x -> Poison.decode!(x) end)
      |> List.flatten()

    data2 =
      for item <- hd do
        item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}
      end

    render(conn, "experiment2.html", data: data2)
  end

  def check_combo_order(s_date, e_date, branch_id_string, brand_id_int) do
    history_data =
      Repo.get_by(
        HistoryData,
        start_date: s_date,
        end_date: e_date,
        branch_id: branch_id_string,
        brand_id: brand_id_int,
        name: "combo_item_not_tally"
      )

    if history_data == nil do
      datas =
        Repo.all(
          from(
            s in Sales,
            left_join: sm in SalesMaster,
            on: sm.salesid == s.salesid,
            left_join: is in ItemSubcat,
            on: is.subcatid == sm.itemid,
            left_join: ic in ItemCat,
            on: is.itemcatid == ic.itemcatid,
            where:
              s.brand_id == ^brand_id_int and s.salesdate >= ^s_date and s.salesdate <= ^e_date and
                s.branchid == ^branch_id_string and ic.category_type == ^"COMBO" and
                is.brand_id == ^brand_id_int and ic.brand_id == ^brand_id_int and s.is_void == ^0 and
                sm.is_void == ^0,
            select: %{
              salesid: s.salesid,
              salesdate: s.salesdate,
              itemname: sm.itemname,
              itemcode: sm.itemcode,
              itemid: sm.itemid,
              catid: is.itemcatid,
              category_type: ic.category_type,
              combo_id: sm.combo_id,
              qty: sm.qty
            }
          )
        )

      datas2 =
        Repo.all(
          from(
            s in Sales,
            left_join: sm in SalesMaster,
            on: sm.salesid == s.salesid,
            where:
              s.brand_id == ^brand_id_int and s.salesdate >= ^s_date and s.salesdate <= ^e_date and
                s.branchid == ^branch_id_string and s.is_void == ^0 and sm.is_void == ^0,
            select: %{
              comboid: sm.combo_id,
              salesid: s.salesid,
              itemid: sm.itemid,
              qty: sm.qty,
              order_price: sm.order_price
            }
          )
        )

      items =
        Repo.all(
          from(
            is in ItemSubcat,
            where: is.brand_id == ^brand_id_int
          )
        )

      combo_details =
        Repo.all(
          from(
            cd in ComboDetails,
            where: cd.brand_id == ^brand_id_int,
            select: %{
              unit_price: cd.unit_price,
              menu_cat_id: cd.menu_cat_id,
              qty: cd.combo_item_qty,
              combo_id: cd.combo_id
            }
          )
        )

      data =
        for data <- datas do
          unless combo_qty_checker(
                   Integer.to_string(brand_id_int),
                   data.itemid,
                   data.qty,
                   data.salesid,
                   items,
                   combo_details,
                   datas2
                 ) do
            data
          end
        end
        |> Enum.reject(fn x -> x == nil end)

      json = data |> Poison.encode!()

      {:ok, history_data} =
        HistoryData.changeset(%HistoryData{}, %{
          start_date: s_date,
          end_date: e_date,
          json_map: json,
          branch_id: branch_id_string,
          brand_id: brand_id_int,
          name: "combo_item_not_tally"
        })
        |> Repo.insert()

      data
    else
      data = Poison.decode!(history_data.json_map)

      for item <- data do
        item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}
      end
    end
  end

  def combo_qty_checker_stats(brand_id, subcatid, qty, salesid) do
    brand_id = String.to_integer(brand_id)

    is = Repo.get_by(ItemSubcat, brand_id: brand_id, subcatid: subcatid)

    # check this combo has any selection?

    items =
      Repo.all(
        from(
          is in ItemSubcat,
          where: is.itemcatid == ^Integer.to_string(is.subcatid) and is.brand_id == ^brand_id
        )
      )

    combo_details =
      Repo.all(
        from(
          cd in ComboDetails,
          where: cd.combo_id == ^Integer.to_string(is.subcatid),
          group_by: [cd.menu_cat_id],
          select: %{menu_cat_id: cd.menu_cat_id, qty: cd.combo_item_qty}
        )
      )

    total_qty_in_combo =
      if combo_details != [] do
        Enum.map(combo_details, fn x -> x.qty end) |> Enum.sum()
      else
        0
      end

    sd =
      Repo.all(from(sm in SalesMaster, where: sm.salesid == ^salesid and sm.is_void == ^0))
      |> Enum.filter(fn x -> x.combo_id == subcatid end)
      |> Enum.map(fn x -> x.qty end)
      |> Enum.sum()

    %{
      total_qty_in_combo: total_qty_in_combo,
      qty: qty,
      sd: sd,
      name: is.itemname,
      salesid: salesid
    }
  end

  def combo_qty_checker(brand_id, subcatid, qty, salesid, items, combo_details, datas) do
    brand_id = String.to_integer(brand_id)

    total_qty_in_combo =
      if combo_details != [] do
        combo_details
        |> Enum.filter(fn x -> x.combo_id == subcatid end)
        |> Enum.uniq()
        |> Enum.map(fn x -> x.qty end)
        |> Enum.sum()
      else
        0
      end

    total_price_in_combo =
      if combo_details != [] do
        combo_details
        |> Enum.filter(fn x -> x.combo_id == subcatid end)
        |> Enum.uniq()
        |> Enum.map(fn x -> x.qty * Decimal.to_float(x.unit_price) end)
        |> Enum.sum()
      else
        0
      end

    sd =
      datas
      |> Enum.filter(fn x -> x.salesid == salesid end)
      |> Enum.filter(fn x -> x.comboid == subcatid end)
      |> Enum.map(fn x -> x.qty end)
      |> Enum.sum()

    sd_price =
      datas |> Enum.filter(fn x -> x.salesid == salesid end)
      |> Enum.filter(fn x -> x.itemid == subcatid end)

    final_price =
      if sd_price != [] do
        a = sd_price |> hd()
        a.order_price |> Decimal.to_float()
      else
        0.0
      end

    if final_price == Float.round(total_price_in_combo * qty, 2) do
    else
      IEx.pry()
    end

    # final_price == Float.round(total_price_in_combo * qty, 2)
    total_qty_in_combo * qty == sd
  end

  def combo_qty_checker2(brand_id, subcatid, qty, salesid, items, combo_details, datas) do
    brand_id = String.to_integer(brand_id)

    total_qty_in_combo =
      if combo_details != [] do
        combo_details
        |> Enum.filter(fn x -> x.combo_id == subcatid end)
        |> Enum.map(fn x -> Map.delete(x, :itemid) end)
        |> Enum.uniq()
        |> Enum.map(fn x -> x.qty end)
        |> Enum.sum()
      else
        0
      end

    sd =
      datas
      |> Enum.filter(fn x -> x.salesid == salesid end)
      |> Enum.filter(fn x -> x.comboid == subcatid end)
      |> Enum.map(fn x -> x.qty end)
      |> Enum.sum()

    reference = combo_details |> Enum.filter(fn x -> x.combo_id == subcatid end)
    grouped_reference = reference |> Enum.group_by(fn x -> x.menu_cat_id end)
    ref_menu_cats = reference |> Enum.map(fn x -> x.menu_cat_id end) |> Enum.uniq()

    report2 =
      for ref_menu_cat <- ref_menu_cats do
        data = grouped_reference[ref_menu_cat] |> hd()

        {ref_menu_cat, data.qty}
      end

    IO.puts(salesid)

    incomplete_sd =
      datas
      |> Enum.filter(fn x -> x.salesid == salesid end)
      |> Enum.filter(fn x -> x.comboid == subcatid end)
      |> Enum.map(fn x -> Map.put(x, :menu_cat_id, assign_menu_cat_id(reference, x.itemid)) end)

    menu_cats = incomplete_sd |> Enum.map(fn x -> x.menu_cat_id end) |> Enum.uniq()
    grouped_sd = incomplete_sd |> Enum.group_by(fn x -> x.menu_cat_id end)

    report =
      for menu_cat <- menu_cats do
        data = grouped_sd[menu_cat] |> Enum.map(fn x -> x.qty end) |> Enum.sum()
        {menu_cat, data}
      end

    remainder = report2 -- report

    for remaind <- remainder do
      {menu_cat_id, real_qty} = remaind

      cd =
        Repo.all(
          from(
            cd in ComboDetails,
            where:
              cd.combo_id == ^subcatid and cd.brand_id == ^brand_id and
                cd.menu_cat_id == ^menu_cat_id
          )
        )
        |> hd()

      setter = datas |> Enum.filter(fn x -> x.salesid == salesid end)

      if setter != [] do
        setter = setter |> hd()

        cg =
          SalesMaster.changeset(%SalesMaster{}, %{
            salesid: salesid,
            brand_id: brand_id,
            itemname: cd.combo_item_name,
            afterdisc: 0,
            discountid: "0",
            combo_id: subcatid,
            is_void: 0,
            orderid: setter.orderid,
            itemid: cd.combo_item_id,
            qty: real_qty,
            order_price: 0,
            remaks: "damien insert"
          })

        IEx.pry()
        # Repo.insert(cg)
      else
      end
    end

    total_qty_in_combo * qty == sd
  end

  def assign_menu_cat_id(reference, itemid) do
    a =
      reference
      |> Enum.filter(fn x -> x.itemid == itemid end)
      |> Enum.map(fn x -> x.menu_cat_id end)

    if a == [] do
      IEx.pry()
    end

    a
    |> hd()
  end

  def experiment(conn, params) do
    date_range = Date.range(Date.from_iso8601!("2018-08-01"), Date.from_iso8601!("2018-08-31"))
    s_date = Date.from_iso8601!("2018-08-01")
    e_date = Date.from_iso8601!("2018-08-31")

    sm =
      for date <- date_range do
      end

    datas =
      Repo.all(
        from(
          s in Sales,
          left_join: sm in SalesMaster,
          on: sm.salesid == s.salesid,
          left_join: is in ItemSubcat,
          on: is.subcatid == sm.itemid,
          left_join: ic in ItemCat,
          on: is.itemcatid == ic.itemcatid,
          where:
            s.brand_id == ^BN.get_brand_id(conn) and s.salesdate >= ^s_date and
              s.salesdate <= ^e_date and s.branchid == ^"31" and ic.category_type == ^"COMBO" and
              is.brand_id == ^BN.get_brand_id(conn) and ic.brand_id == ^BN.get_brand_id(conn) and
              s.is_void == ^0 and sm.is_void == ^0,
          select: %{
            salesid: s.salesid,
            salesdate: s.salesdate,
            itemname: sm.itemname,
            itemcode: sm.itemcode,
            itemid: sm.itemid,
            catid: is.itemcatid,
            category_type: ic.category_type,
            combo_id: sm.combo_id,
            qty: sm.qty
          }
        )
      )

    data =
      for data <- datas do
        combo_qty_checker_stats("1", data.itemid, data.qty, data.salesid)
      end

    combos = data |> Enum.group_by(fn x -> x.name end) |> Map.keys()
    combo_data = data |> Enum.group_by(fn x -> x.name end)

    data =
      for combo <- combos do
        data = combo_data[combo]

        qty = Enum.map(data, fn x -> x.qty end) |> Enum.sum()
        %{combo: combo, qty: qty}
      end

    render(conn, "experiment.html", data: data)
  end

  def csv_content(conn, params) do
    # date_range = Date.range(Date.from_iso8601!("2018-08-01"), Date.from_iso8601!("2018-08-31"))
    image_path = Application.app_dir(:boat_noodle, "priv/static/images")
    file = File.stream!(image_path <> "/combo_item_report.csv")

    s_date = Date.from_iso8601!(conn.params["start_date"])
    e_date = Date.from_iso8601!(conn.params["end_date"])

    combo_details =
      Repo.all(
        from(
          cd in ComboDetails,
          where: cd.brand_id == ^BN.get_brand_id(conn)
        )
      )

    combo_menus =
      Repo.all(
        from(
          i in ItemSubcat,
          left_join: c in ItemCat,
          on: c.itemcatid == i.itemcatid,
          where:
            c.category_type == ^"COMBO" and i.brand_id == ^BN.get_brand_id(conn) and
              c.brand_id == ^BN.get_brand_id(conn),
          select: %{
            itemcat: c.itemcatname,
            combo_name: i.itemname,
            subcatid: i.subcatid
          }
        )
      )

    item_menus =
      Repo.all(
        from(
          i in ItemSubcat,
          left_join: c in ItemCat,
          on: c.itemcatid == i.itemcatid,
          where:
            c.category_type != ^"COMBO" and i.brand_id == ^BN.get_brand_id(conn) and
              c.brand_id == ^BN.get_brand_id(conn),
          select: %{
            itemcat: c.itemcatname,
            itemcode: i.itemcode,
            category_type: c.category_type
          }
        )
      )

    data =
      if conn.params["branch"] != "0" do
        per_branch_combo_item(
          s_date,
          e_date,
          conn.params["branch"],
          conn,
          combo_details,
          combo_menus,
          item_menus
        )
      else
        branches =
          Repo.all(
            from(
              b in Branch,
              where: b.brand_id == ^BN.get_brand_id(conn) and b.branchid in ^[2, 17, 51]
            )
          )

        # |> Enum.reject(fn x -> x.branchid == 0 end)

        # |> Enum.filter(fn x -> x.branchid == 1 end)

        for branch <- branches do
          # per_branch_combo_item(
          #   s_date,
          #   e_date,
          #   Integer.to_string(branch.branchid),
          #   conn,
          #   combo_details,
          #   combo_menus,
          #   item_menus
          # )

          Task.start_link(__MODULE__, :per_branch_combo_item, [
            s_date,
            e_date,
            Integer.to_string(branch.branchid),
            conn,
            combo_details,
            combo_menus,
            item_menus
          ])

          history_data =
            Repo.all(
              from(
                hd in HistoryData,
                where:
                  hd.start_date == ^s_date and hd.end_date == ^e_date and
                    hd.brand_id == ^BN.get_brand_id(conn) and hd.branch_id == ^branch.branchid and
                    hd.name == ^"combo_item_analysis"
              )
            )
            |> Enum.reject(fn x -> x.json_map == "[]" end)

          data = Enum.map(history_data, fn x -> Poison.decode!(x.json_map) end) |> List.flatten()

          data_last =
            for item <- data do
              item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}
              # IO.puts("changing dates...")
              # item = Map.put(item, :salesdate, Date.from_iso8601!(item.salesdate))
            end

          dates =
            data_last
            |> Enum.reject(fn x -> x == %{} end)
            |> Enum.group_by(fn x -> x.salesdate end)
            |> Map.keys()

          itemids =
            data_last
            |> Enum.reject(fn x -> x == %{} end)
            |> Enum.group_by(fn x -> x.itemid end)
            |> Map.keys()

          branches =
            data_last
            |> Enum.reject(fn x -> x == %{} end)
            |> Enum.group_by(fn x -> x.branchname end)
            |> Map.keys()

          data2 =
            for date <- dates do
              for branch <- branches do
                for itemid <- itemids do
                  bulk_data =
                    Enum.filter(data_last, fn x -> x.salesdate == date end)
                    |> Enum.filter(fn x -> x.branchname == branch end)
                    |> Enum.filter(fn x -> x.itemid == itemid end)

                  if bulk_data != [] do
                    qty = bulk_data |> Enum.map(fn x -> x.qty end) |> Enum.sum()

                    total_price =
                      bulk_data |> Enum.map(fn x -> x.unit_price * x.qty end) |> Enum.sum()

                    branchname = bulk_data |> Enum.map(fn x -> x.branchname end) |> Enum.uniq()

                    itemname = bulk_data |> Enum.map(fn x -> x.itemname end) |> Enum.uniq()

                    # x = bulk_data |> hd()

                    # if String.contains?(x.combo_name, "G13") do
                    #   # IEx.pry()
                    # end

                    itemname =
                      if itemname != [] do
                        hd(itemname)
                      else
                        "EMPTY"
                      end

                    branchname =
                      if branchname != [] do
                        hd(branchname)
                      else
                        "NO BRANCH"
                      end

                    combo_name = bulk_data |> Enum.map(fn x -> x.combo_name end) |> Enum.uniq()

                    combo_name =
                      if combo_name != [] do
                        hd(combo_name)
                      else
                        "EMPTY"
                      end

                    cat_name = bulk_data |> Enum.map(fn x -> x.cat_name end) |> Enum.uniq()

                    cat_name =
                      if cat_name != [] do
                        hd(cat_name)
                      else
                        "EMPTY"
                      end

                    type = bulk_data |> Enum.map(fn x -> x.type end) |> Enum.uniq()

                    type =
                      if type != [] do
                        hd(type)
                      else
                        "EMPTY"
                      end

                    itemcode = bulk_data |> Enum.map(fn x -> x.itemcode end) |> Enum.uniq()

                    itemcode =
                      if itemcode != [] do
                        hd(itemcode)
                      else
                        "EMPTY itemcode"
                      end

                    {
                      date,
                      branchname,
                      type,
                      cat_name,
                      combo_name,
                      itemcode,
                      itemid,
                      itemname,
                      Integer.to_string(qty),
                      :erlang.float_to_binary(total_price, decimals: 2)

                      # :erlang.float_to_binary(total_price * qty, decimals: 2)
                    }
                  end
                end
              end
              |> Enum.reject(fn x -> x == nil end)
            end

          IO.puts("printing csv")

          data_o =
            data2 |> List.flatten() |> Enum.reject(fn x -> x == nil end)
            |> Enum.map(fn x -> Tuple.to_list(x) end)

          # List.insert_at(data_o, 0, csv_header)
          csv =
            data_o
            |> CSV.encode()
            |> Enum.to_list()
            |> to_string

          b = csv |> String.split("\r\n") |> Enum.map(fn x -> x <> "\r\n" end)
          # |> Enum.into(file)
          # IEx.pry()
          # File.write!(image_path <> "/combo_item_report-#{branch.branchname}.csv", csv)
        end
      end

    d = List.flatten(data)

    csv_header =
      [
        'salesdate',
        'branchname',
        'type',
        'category',
        'combo',
        'itemcode',
        'itemid',
        'itemname',
        'qty',
        'total_price'
      ]
      |> Enum.join(",")

    value = csv_header <> "\r\n"
    e = List.insert_at(d, 0, value)
    f = e |> Enum.reject(fn x -> x == "\r\n" end)

    Enum.into(f, file)

    IO.puts("inserting to list...")

    # conn
    # |> put_resp_content_type("text/csv")
    # |> put_resp_header(
    #   "content-disposition",
    #   "attachment; filename=\"Combo Item Analysis.csv\""
    # )
    # |> send_resp(200, csv)
    conn
    |> put_flash(:info, "Combo item report generated!")
    |> redirect(to: page_path(conn, :index2, BN.get_domain(conn)))
  end

  def per_branch_combo_item(
        s_date,
        e_date,
        branchid,
        conn,
        combo_details,
        combo_menus,
        item_menus
      ) do
    q =
      from(
        s in Sales,
        left_join: sm in SalesMaster,
        on: sm.salesid == s.salesid,
        left_join: b in Branch,
        on: b.branchid == s.branchid,
        where:
          s.brand_id == ^BN.get_brand_id(conn) and s.salesdate >= ^s_date and
            s.branchid == ^branchid and b.brand_id == ^BN.get_brand_id(conn) and
            s.salesdate <= ^e_date and sm.combo_id != 0 and s.is_void == ^0 and sm.is_void == ^0,
        select: %{
          salesid: s.salesid,
          salesdate: s.salesdate,
          itemname: sm.itemname,
          itemcode: sm.itemcode,
          order_price: sm.order_price,
          qty: sm.qty,
          combo_id: sm.combo_id,
          branchname: b.branchname,
          itemid: sm.itemid
        }
      )

    history_data =
      Repo.get_by(
        HistoryData,
        start_date: s_date,
        end_date: e_date,
        branch_id: branchid,
        brand_id: BN.get_brand_id(conn),
        name: "combo_item_analysis"
      )

    if history_data == nil do
      data =
        Repo.all(q)
        |> Enum.map(fn x ->
          %{
            salesid: x.salesid,
            salesdate: x.salesdate,
            itemcode: code_combo(x.itemname),
            itemname: x.itemname,
            unit_price:
              find_combo_unit_price(
                code_combo(x.itemname),
                x.combo_id,
                Integer.to_string(BN.get_brand_id(conn)),
                combo_details,
                x.salesid
              ),
            combo_name: combo_name(combo_menus, x.combo_id, x.salesid),
            cat_name: cat_name(item_menus, code_combo(x.itemname)),
            qty: x.qty,
            branchname: x.branchname,
            type: cat_type(item_menus, code_combo(x.itemname)),
            itemid: x.itemid
          }
        end)

      # |> Enum.filter(fn x -> String.contains?(x.combo_name, "G40") end)

      json = data |> Poison.encode!()

      {:ok, history_data} =
        HistoryData.changeset(%HistoryData{}, %{
          start_date: s_date,
          end_date: e_date,
          json_map: json,
          branch_id: branchid,
          brand_id: BN.get_brand_id(conn),
          name: "combo_item_analysis"
        })
        |> Repo.insert()

      data
    else
      data = Poison.decode!(history_data.json_map)

      for item <- data do
        item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}
        item = Map.put(item, :salesdate, Date.from_iso8601!(item.salesdate))
      end
    end
  end

  def cat_type(item_menus, itemcode) do
    res = item_menus |> Enum.filter(fn x -> x.itemcode == itemcode end) |> Enum.uniq()

    if res != [] do
      hd(res).category_type
    else
      "EMPTY CATEGORY"
    end
  end

  def code_combo(name) do
    String.split(name, "") |> Enum.take(4) |> Enum.join()
  end

  def combo_name(combo_menus, combo_id, salesid) do
    res = combo_menus |> Enum.filter(fn x -> x.subcatid == combo_id end)

    if res != [] do
      hd(res).combo_name
    else
      image_path = Application.app_dir(:boat_noodle, "priv/static/images")
      # file = File.stream!(image_path <> "/zero_price_salesid.csv")
      new_path = image_path <> "/empty_combo_data-#{combo_id}.csv"

      if File.exists?(new_path) do
        data = File.read!(new_path)
        list = String.split(data, "\r\n")

        list =
          List.insert_at(list, 0, "#{salesid},#{combo_id}")
          |> Enum.map(fn x -> x <> "\r\n" end)
          |> Enum.join()

        File.write(new_path, list)
        # Enum.into(list, file)
      else
        list = []

        list =
          List.insert_at(list, 0, "#{salesid},#{combo_id}")
          |> Enum.map(fn x -> x <> "\r\n" end)
          |> Enum.join()

        File.write(new_path, list)
        # Enum.into(list, file)
      end

      "EMPTY COMBO"
    end
  end

  def cat_name(item_menus, itemcode) do
    res = item_menus |> Enum.filter(fn x -> x.itemcode == itemcode end) |> Enum.uniq()

    if res != [] do
      hd(res).itemcat
    else
      "EMPTY COMBO"
    end
  end

  def find_combo_unit_price(itemcode, comboid, brand_id, combo_details, salesid) do
    cd =
      combo_details
      |> Enum.filter(fn x -> x.brand_id == String.to_integer(brand_id) end)
      |> Enum.filter(fn x -> x.combo_item_code == itemcode end)
      |> Enum.filter(fn x -> x.combo_id == comboid end)

    if cd != [] do
      cd = hd(cd)

      Decimal.to_float(cd.unit_price) + Decimal.to_float(cd.top_up)
    else
      image_path = Application.app_dir(:boat_noodle, "priv/static/images")
      # file = File.stream!(image_path <> "/zero_price_salesid.csv")
      new_path = image_path <> "/zero_price_salesid.csv"

      if File.exists?(new_path) do
        data = File.read!(new_path)
        list = String.split(data, "\r\n")

        list =
          List.insert_at(list, 0, "#{salesid},#{itemcode},#{comboid}")
          |> Enum.map(fn x -> x <> "\r\n" end)
          |> Enum.join()

        File.write(new_path, list)
        # Enum.into(list, file)
      else
        list = []

        list =
          List.insert_at(list, 0, "#{salesid},#{itemcode},#{comboid}")
          |> Enum.map(fn x -> x <> "\r\n" end)
          |> Enum.join()

        File.write(new_path, list)
        # Enum.into(list, file)
      end

      0
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logout successfully")
    |> redirect(to: page_path(conn, :report_login))
  end

  def authenticate_login(conn, %{"username" => username, "password" => password}) do
    user = Repo.get_by(User, username: username)

    if user != nil do
      p2 = String.replace(user.password, "$2y", "$2b")

      if Comeonin.Bcrypt.checkpw(password, p2) do
        brand = Repo.get(Brand, user.brand_id)

        # if user.read_report_only == 0 do
        conn
        |> put_session(:user_id, user.id)
        |> put_session(:brand, brand.domain_name)
        |> put_session(:brand_id, brand.id)
        |> redirect(to: page_path(conn, :index2, brand.domain_name))

        # else
        #   conn
        #   |> put_session(:user_id, user.id)
        #   |> redirect(to: page_path(conn, :report_index))
        # end
      else
        conn
        |> put_flash(:error, "Wrong password!")
        |> redirect(to: page_path(conn, :report_login))
      end
    else
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: page_path(conn, :report_login))
    end
  end

  def report_login(conn, params) do
    render(conn, "login.html", layout: {BoatNoodleWeb.LayoutView, "report_layout.html"})
  end

  def report_index(conn, params) do
    branches =
      Repo.all(
        from(
          s in BoatNoodle.BN.UserBranchAccess,
          left_join: g in BoatNoodle.BN.Branch,
          on: s.branchid == g.branchid,
          where: s.userid == ^conn.private.plug_session["user_id"],
          select: %{branchid: s.branchid, branchname: g.branchname},
          order_by: g.branchname
        )
      )

    render(conn, "dashboard.html", branches: branches)
  end

  def webhook_key(conn, params) do
    bb = Repo.all(from(b in Branch, where: b.branchcode == ^params["code"]))

    if bb != [] do
      branch = hd(bb)

      api_key =
        Comeonin.Bcrypt.hashpwsalt(branch.branchname) |> String.replace("$2b", "$2y")
        |> Base.url_encode64()

      cg = Branch.changeset(branch, %{api_key: api_key})
      map = %{key: api_key} |> Poison.encode!()

      case Repo.update(cg) do
        {:ok, bb} ->
          send_resp(conn, 200, map)

        {:error, cg} ->
          send_resp(conn, 500, " not ok")
      end
    else
      send_resp(conn, 500, " not ok")
    end
  end

  def get_brands(conn, _params) do
    brands = Repo.all(Brand) |> Enum.map(fn x -> %{name: x.domain_name} end) |> Poison.encode!()
    send_resp(conn, 200, brands)
  end

  def index(conn, _params) do
    brands = Repo.all(Brand) |> hd()

    conn
    |> redirect(to: user_path(conn, :login, brands.domain_name))
  end

  def index2(conn, _params) do
    branches =
      Repo.all(
        from(
          s in BoatNoodle.BN.UserBranchAccess,
          left_join: g in BoatNoodle.BN.Branch,
          on: s.branchid == g.branchid,
          where:
            s.brand_id == ^BN.get_brand_id(conn) and g.brand_id == ^BN.get_brand_id(conn) and
              s.userid == ^conn.private.plug_session["user_id"],
          select: %{branchid: s.branchid, branchname: g.branchname},
          order_by: g.branchname
        )
      )

    render(conn, "dashboard.html", branches: branches)
  end

  def no_page_found(conn, _params) do
    conn
    |> put_flash(:error, "No page found")
    |> redirect(to: page_path(conn, :index2, BN.get_domain(conn)))
  end
end
