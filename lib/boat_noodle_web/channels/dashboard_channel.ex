defmodule BoatNoodleWeb.DashboardChannel do
  use BoatNoodleWeb, :channel
  import Number.Currency
  require IEx
  use Task

  def join("dashboard_channel:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def dashboard_show(d_nett_sales, d_taxes, d_order, d_pax, d_transaction, socket) do
    broadcast(socket, "dashboard_1", %{
      nett_sales: d_nett_sales,
      taxes: d_taxes,
      order: d_order,
      pax: d_pax,
      transaction: d_transaction
    })
  end

  def handle_in("dashboard", payload, socket) do
    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]
    [y, m, d] = payload["s_date"] |> String.split("-")
    {:ok, start_d} = Date.new(String.to_integer(y), String.to_integer(m), String.to_integer(d))

    [y1, m1, d1] = payload["e_date"] |> String.split("-")
    {:ok, end_d} = Date.new(String.to_integer(y1), String.to_integer(m1), String.to_integer(d1))
    brand = Repo.get_by(Brand, id: brand_id)

    {d_nett_sales, d_taxes, d_order, d_pax, d_transaction, table_branch_daily_sales_sumary,
     grp_daily, top_10_selling, top_10_selling_revenue,
     top_10_selling_category} =
      if branchid != "0" do
        history_data =
          Repo.get_by(
            HistoryData,
            start_date: start_d,
            end_date: end_d,
            branch_id: branchid,
            brand_id: brand_id,
            name: "summary"
          )

        a =
          if history_data == nil do
            b =
              Repo.all(
                from(
                  sp in BoatNoodle.BN.SalesPayment,
                  left_join: s in BoatNoodle.BN.Sales,
                  on: sp.salesid == s.salesid,
                  left_join: b in BoatNoodle.BN.Branch,
                  on: b.branchid == s.branchid,
                  where:
                    s.is_void == 0 and s.branchid == ^payload["branch_id"] and
                      s.salesdate >= ^start_d and s.salesdate <= ^end_d and
                      s.brand_id == ^payload["brand_id"] and b.brand_id == ^brand_id and
                      sp.brand_id == ^brand_id,
                  group_by: [s.salesdate, b.branchname],
                  select: %{
                    salesdate: s.salesdate,
                    pax: sum(s.pax),
                    branchname: b.branchname,
                    grand_total: sum(sp.grand_total),
                    service_charge: sum(sp.service_charge),
                    gst: sum(sp.gst_charge),
                    after_disc: sum(sp.after_disc),
                    transaction: count(s.salesid),
                    sub_total: sum(sp.sub_total),
                    rounding: sum(sp.rounding)
                  }
                )
              )

            unless start_d == end_d and end_d == Date.utc_today() do
              {:ok, history_data} =
                HistoryData.changeset(%HistoryData{}, %{
                  start_date: start_d,
                  end_date: end_d,
                  json_map: Poison.encode!(b),
                  branch_id: branchid,
                  brand_id: brand_id,
                  name: "summary"
                })
                |> Repo.insert()
            end

            b
          else
            if end_d == Date.utc_today() do
              b =
                Repo.all(
                  from(
                    sp in BoatNoodle.BN.SalesPayment,
                    left_join: s in BoatNoodle.BN.Sales,
                    on: sp.salesid == s.salesid,
                    left_join: b in BoatNoodle.BN.Branch,
                    on: b.branchid == s.branchid,
                    where:
                      s.is_void == 0 and s.branchid == ^payload["branch_id"] and
                        s.salesdate >= ^start_d and s.salesdate <= ^end_d and
                        s.brand_id == ^payload["brand_id"] and b.brand_id == ^brand_id and
                        sp.brand_id == ^brand_id,
                    group_by: [s.salesdate, b.branchname],
                    select: %{
                      salesdate: s.salesdate,
                      pax: sum(s.pax),
                      branchname: b.branchname,
                      grand_total: sum(sp.grand_total),
                      service_charge: sum(sp.service_charge),
                      gst: sum(sp.gst_charge),
                      after_disc: sum(sp.after_disc),
                      transaction: count(s.salesid),
                      sub_total: sum(sp.sub_total),
                      rounding: sum(sp.rounding)
                    }
                  )
                )

              {:ok, history_data} =
                HistoryData.changeset(history_data, %{
                  start_date: start_d,
                  end_date: end_d,
                  json_map: Poison.encode!(b),
                  branch_id: branchid,
                  brand_id: brand_id,
                  name: "summary"
                })
                |> Repo.update()

              b
            else
              data = Poison.decode!(history_data.json_map)

              for item <- data do
                item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}
                item = Map.put(item, :salesdate, Date.from_iso8601!(item.salesdate))
                item = Map.put(item, :after_disc, Decimal.new(item.after_disc))
                item = Map.put(item, :grand_total, Decimal.new(item.grand_total))
                item = Map.put(item, :gst, Decimal.new(item.gst))
                item = Map.put(item, :service_charge, Decimal.new(item.service_charge))
                item = Map.put(item, :sub_total, Decimal.new(item.sub_total))
                item = Map.put(item, :rounding, Decimal.new(item.rounding))
                item = Map.put(item, :pax, Decimal.new(item.pax))
              end
            end
          end

        grp = a |> Enum.group_by(fn x -> x.salesdate end)

        year = a |> Enum.group_by(fn x -> x.salesdate.year end) |> Map.keys()

        grp_daily =
          for item <- year do
            sales = Enum.filter(a, fn x -> x.salesdate.year == item end)

            # months = sales |> Enum.group_by(fn x -> x.salesdate.month end) |> Map.keys()

            months = 1..12

            for month <- months do
              sales = Enum.filter(a, fn x -> x.salesdate.month == month end)

              days = sales |> Enum.group_by(fn x -> x.salesdate end) |> Map.keys()

              for day <- days do
                data = Enum.filter(a, fn x -> x.salesdate == day end)

                total_grand_total =
                  Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

                total_after_disc =
                  Enum.map(data, fn x -> Decimal.to_float(x.after_disc) end) |> Enum.sum()

                total_sub_total =
                  Enum.map(data, fn x -> Decimal.to_float(x.sub_total) end) |> Enum.sum()

                total_sales =
                  Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end)
                  |> Enum.sum()
                  |> Float.round(2)

                total_rounding =
                  Enum.map(data, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()

                total_taxes =
                  Enum.map(data, fn x -> Decimal.to_float(x.gst) end)
                  |> Enum.sum()
                  |> Float.round(2)

                total_service_charge =
                  Enum.map(data, fn x -> Decimal.to_float(x.service_charge) end)
                  |> Enum.sum()
                  |> Float.round(2)

                total_discount =
                  (total_grand_total -
                     (total_sub_total + total_taxes + total_service_charge + total_rounding))
                  |> Float.round(2)

                total_transaction = Enum.map(data, fn x -> x.transaction end) |> Enum.sum()

                %{
                  date: day,
                  total_sales: total_sales - total_taxes - total_rounding,
                  total_taxes: total_taxes,
                  total_discount: total_discount,
                  total_service_charge: total_service_charge,
                  total_transaction: total_transaction
                }
              end
            end
          end
          |> List.flatten()

        group_data = a |> Enum.group_by(fn x -> x.branchname end) |> Map.keys()

        table_branch_daily_sales_sumary =
          for data <- group_data do
            data_all = a |> Enum.group_by(fn x -> x.branchname end)

            abc =
              for item <- data_all do
                name = item |> elem(0)
                item = item |> elem(1)

                if name == data do
                  grand_total =
                    Enum.map(item, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

                  after_disc =
                    Enum.map(item, fn x -> Decimal.to_float(x.after_disc) end) |> Enum.sum()

                  sub_total =
                    Enum.map(item, fn x -> Decimal.to_float(x.sub_total) end) |> Enum.sum()

                  service_charge =
                    Enum.map(item, fn x -> Decimal.to_float(x.service_charge) end) |> Enum.sum()

                  gst = Enum.map(item, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum()

                  rounding =
                    Enum.map(item, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()

                  nett_sale = grand_total - gst - rounding

                  branchname = Enum.map(item, fn x -> x.branchname end) |> Enum.uniq() |> hd

                  gross_sales =
                    Enum.map(item, fn x -> Decimal.to_float(x.sub_total) end)
                    |> Enum.sum()
                    |> Float.round(2)
                    |> Number.Delimit.number_to_delimited()

                  service_charges =
                    Enum.map(item, fn x -> Decimal.to_float(x.service_charge) end)
                    |> Enum.sum()
                    |> Float.round(2)
                    |> Number.Delimit.number_to_delimited()

                  taxes =
                    Enum.map(item, fn x -> Decimal.to_float(x.gst) end)
                    |> Enum.sum()
                    |> Float.round(2)
                    |> Number.Delimit.number_to_delimited()

                  discounts =
                    (grand_total - (sub_total + gst + service_charge + rounding))
                    |> Number.Delimit.number_to_delimited()

                  nett_sales =
                    (grand_total - gst - rounding)
                    |> Number.Delimit.number_to_delimited()

                  roundings =
                    Enum.map(item, fn x -> Decimal.to_float(x.rounding) end)
                    |> Enum.sum()
                    |> Float.round(2)
                    |> Number.Delimit.number_to_delimited()

                  total_sales =
                    grand_total |> Float.round(2) |> Number.Delimit.number_to_delimited()

                  pax = Enum.map(item, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()

                  transaction =
                    Enum.map(item, fn x -> x.transaction end)
                    |> Enum.sum()
                    |> Number.Delimit.number_to_delimited()

                  %{
                    branchname: branchname,
                    gross_sales: gross_sales,
                    service_charge: service_charges,
                    gst: taxes,
                    discount: discounts,
                    nett_sales: nett_sales,
                    roundings: roundings,
                    total_sales: total_sales,
                    pax: pax,
                    transaction: transaction
                  }
                end
              end
          end
          |> List.flatten()
          |> Enum.reject(fn x -> x == nil end)

        grand_total = Enum.map(a, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()
        after_disc = Enum.map(a, fn x -> Decimal.to_float(x.after_disc) end) |> Enum.sum()
        sub_total = Enum.map(a, fn x -> Decimal.to_float(x.sub_total) end) |> Enum.sum()
        service_charge = Enum.map(a, fn x -> Decimal.to_float(x.service_charge) end) |> Enum.sum()
        gst = Enum.map(a, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum()
        rounding = Enum.map(a, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()
        pax = Enum.map(a, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()
        transaction = Enum.map(a, fn x -> x.transaction end) |> Enum.sum()
        discount = grand_total - (sub_total + gst + service_charge + rounding)

        d_nett_sales = (grand_total - gst - rounding) |> Number.Delimit.number_to_delimited()

        d_taxes =
          Enum.map(a, fn x -> Decimal.to_float(x.gst) end)
          |> Enum.sum()
          |> Number.Delimit.number_to_delimited()

        d_pax =
          Enum.map(a, fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()
          |> Kernel.trunc()
          |> Number.Delimit.number_to_delimited()
          |> String.reverse()
          |> String.split_at(3)
          |> elem(1)
          |> String.reverse()

        d_transaction =
          Enum.map(a, fn x -> x.transaction end)
          |> Enum.sum()
          |> Kernel.trunc()
          |> Number.Delimit.number_to_delimited()
          |> String.reverse()
          |> String.split_at(3)
          |> elem(1)
          |> String.reverse()

        brand_id_int = String.to_integer(brand_id)

        order_query =
          Repo.all(
            from(
              s in Sales,
              left_join: sm in SalesMaster,
              on: sm.salesid == s.salesid,
              left_join: b in BoatNoodle.BN.Branch,
              on: b.branchid == s.branchid,
              where:
                s.is_void == 0 and s.branchid == ^payload["branch_id"] and
                  s.brand_id == ^brand_id_int and sm.brand_id == ^brand_id_int and
                  b.brand_id == ^brand_id_int and s.salesdate >= ^payload["s_date"] and
                  s.salesdate <= ^payload["e_date"],
              select: %{sales_details: sum(sm.qty)}
            )
          )

        d_order =
          order_query
          |> Enum.map(fn x -> Decimal.to_float(x.sales_details) end)
          |> Enum.sum()
          |> Kernel.trunc()
          |> Number.Delimit.number_to_delimited()
          |> String.reverse()
          |> String.split_at(3)
          |> elem(1)
          |> String.reverse()

        Task.start_link(__MODULE__, :dashboard_show, [
          d_nett_sales,
          d_taxes,
          d_order,
          d_pax,
          d_transaction,
          socket
        ])

        top_10_items_qty_history_data =
          Repo.get_by(
            HistoryData,
            start_date: start_d,
            end_date: end_d,
            branch_id: branchid,
            brand_id: brand_id,
            name: "top_10_items_qty"
          )

        top_10_items_qty =
          if top_10_items_qty_history_data == nil do
            b =
              Repo.all(
                from(
                  sm in BoatNoodle.BN.SalesMaster,
                  left_join: s in BoatNoodle.BN.Sales,
                  on: sm.salesid == s.salesid,
                  left_join: i in BoatNoodle.BN.ItemSubcat,
                  on: sm.itemid == i.subcatid,
                  left_join: b in BoatNoodle.BN.Brand,
                  on: b.id == ^brand.id,
                  where:
                    s.is_void == 0 and b.id == i.brand_id and s.branchid == ^payload["branch_id"] and
                      s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                      s.brand_id == ^payload["brand_id"],
                  group_by: [i.itemname],
                  select: %{
                    itemname: i.itemname,
                    qty: sum(sm.qty)
                  },
                  order_by: [desc: sum(sm.qty)],
                  limit: 10
                )
              )

            {:ok, top_10_items_qty_history_data} =
              HistoryData.changeset(%HistoryData{}, %{
                start_date: start_d,
                end_date: end_d,
                json_map: Poison.encode!(b),
                branch_id: branchid,
                brand_id: brand_id,
                name: "top_10_items_qty"
              })
              |> Repo.insert()

            b
          else
            data = Poison.decode!(top_10_items_qty_history_data.json_map)

            for item <- data do
              item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}

              item = Map.put(item, :qty, Decimal.new(item.qty))
              item
            end
          end

        top_10_items_value_history_data =
          Repo.get_by(
            HistoryData,
            start_date: start_d,
            end_date: end_d,
            branch_id: branchid,
            brand_id: brand_id,
            name: "top_10_items_value"
          )

        top_10_items_value =
          if top_10_items_value_history_data == nil do
            b =
              Repo.all(
                from(
                  sm in BoatNoodle.BN.SalesMaster,
                  left_join: s in BoatNoodle.BN.Sales,
                  on: sm.salesid == s.salesid,
                  left_join: i in BoatNoodle.BN.ItemSubcat,
                  on: sm.itemid == i.subcatid,
                  left_join: b in BoatNoodle.BN.Brand,
                  on: b.id == ^brand.id,
                  where:
                    s.is_void == 0 and b.id == i.brand_id and s.branchid == ^payload["branch_id"] and
                      s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                      s.brand_id == ^payload["brand_id"],
                  group_by: [i.itemname],
                  select: %{
                    itemname: i.itemname,
                    value: i.itemprice,
                    qty: sum(sm.qty)
                  }
                )
              )

            {:ok, top_10_items_value_history_data} =
              HistoryData.changeset(%HistoryData{}, %{
                start_date: start_d,
                end_date: end_d,
                json_map: Poison.encode!(b),
                branch_id: branchid,
                brand_id: brand_id,
                name: "top_10_items_value"
              })
              |> Repo.insert()

            b
          else
            data = Poison.decode!(top_10_items_value_history_data.json_map)

            for item <- data do
              item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}

              item = Map.put(item, :qty, Decimal.new(item.qty))
              item = Map.put(item, :value, Decimal.new(item.value))
              item
            end
          end

        top_10_selling =
          for item <- top_10_items_qty do
            %{name: item.itemname, y: Decimal.to_float(item.qty)}
          end

        top_10_selling_revenue =
          for item <- top_10_items_value do
            total = (Decimal.to_float(item.value) * Decimal.to_float(item.qty)) |> Float.round(2)
            %{y: total, name: item.itemname}
          end
          |> Enum.sort_by(fn x -> x.y end)
          |> Enum.reverse()
          |> Enum.take(10)

        all_history_data =
          Repo.get_by(
            HistoryData,
            start_date: start_d,
            end_date: end_d,
            branch_id: branchid,
            brand_id: brand_id,
            name: "all_history_data"
          )

        all =
          if all_history_data == nil do
            b =
              Repo.all(
                from(
                  sm in BoatNoodle.BN.SalesMaster,
                  left_join: s in BoatNoodle.BN.Sales,
                  on: sm.salesid == s.salesid,
                  left_join: i in BoatNoodle.BN.ItemSubcat,
                  on: sm.itemid == i.subcatid,
                  left_join: c in BoatNoodle.BN.ItemCat,
                  on: i.itemcatid == c.itemcatid,
                  left_join: b in BoatNoodle.BN.Brand,
                  on: b.id == ^brand.id,
                  where:
                    s.is_void == 0 and c.category_type != "COMBO" and c.itemcatcode != "empty" and
                      b.id == c.brand_id and s.branchid == ^payload["branch_id"] and
                      s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                      s.brand_id == ^payload["brand_id"],
                  group_by: [c.itemcatname, s.salesdate],
                  select: %{
                    name: c.itemcatname,
                    y: sum(sm.afterdisc)
                  }
                )
              )

            {:ok, all_history_data} =
              HistoryData.changeset(%HistoryData{}, %{
                start_date: start_d,
                end_date: end_d,
                json_map: Poison.encode!(b),
                branch_id: branchid,
                brand_id: brand_id,
                name: "all_history_data"
              })
              |> Repo.insert()

            b
          else
            data = Poison.decode!(all_history_data.json_map)

            for item <- data do
              item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}
              item = Map.put(item, :y, Decimal.new(item.y))
              item
            end
          end

        combo_detail_history_data =
          Repo.get_by(
            HistoryData,
            start_date: start_d,
            end_date: end_d,
            branch_id: branchid,
            brand_id: brand_id,
            name: "combo_detail"
          )

        combo_detail =
          if combo_detail_history_data == nil do
            b =
              Repo.all(
                from(
                  sm in BoatNoodle.BN.SalesMaster,
                  left_join: s in BoatNoodle.BN.Sales,
                  on: sm.salesid == s.salesid,
                  left_join: i in BoatNoodle.BN.ComboDetails,
                  on: sm.itemid == i.combo_item_id,
                  left_join: c in BoatNoodle.BN.ItemCat,
                  on: i.menu_cat_id == c.itemcatid,
                  left_join: b in BoatNoodle.BN.Brand,
                  on: b.id == ^brand.id,
                  where:
                    s.is_void == 0 and b.id == c.brand_id and s.branchid == ^payload["branch_id"] and
                      s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                      s.brand_id == ^payload["brand_id"],
                  group_by: [c.itemcatname, s.salesdate],
                  select: %{
                    name: c.itemcatname,
                    y: sum(i.unit_price)
                  }
                )
              )

            {:ok, all_history_data} =
              HistoryData.changeset(%HistoryData{}, %{
                start_date: start_d,
                end_date: end_d,
                json_map: Poison.encode!(b),
                branch_id: branchid,
                brand_id: brand_id,
                name: "combo_detail"
              })
              |> Repo.insert()

            b
          else
            data = Poison.decode!(combo_detail_history_data.json_map)

            for item <- data do
              item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}
              item = Map.put(item, :y, Decimal.new(item.y))
              item
            end
          end

        new_one = all ++ combo_detail

        new_one = new_one |> Enum.group_by(fn x -> x.name end)

        top_10_selling_category =
          for item <- new_one do
            y =
              item
              |> elem(1)
              |> Enum.map(fn x -> Decimal.to_float(x.y) end)
              |> Enum.sum()
              |> Float.round(2)

            name = item |> elem(0)

            %{name: name, y: y}
          end

        {d_nett_sales, d_taxes, d_order, d_pax, d_transaction, table_branch_daily_sales_sumary,
         grp_daily, top_10_selling, top_10_selling_revenue, top_10_selling_category}
      else
        history_data =
          Repo.get_by(
            HistoryData,
            start_date: start_d,
            end_date: end_d,
            branch_id: branchid,
            brand_id: brand_id,
            name: "summary"
          )

        a =
          if history_data == nil do
            b =
              Repo.all(
                from(
                  sp in BoatNoodle.BN.SalesPayment,
                  left_join: s in BoatNoodle.BN.Sales,
                  on: sp.salesid == s.salesid,
                  left_join: b in BoatNoodle.BN.Branch,
                  on: b.branchid == s.branchid,
                  where:
                    s.is_void == 0 and s.salesdate >= ^payload["s_date"] and
                      s.salesdate <= ^payload["e_date"] and sp.brand_id == ^brand_id and
                      b.brand_id == ^brand_id,
                  group_by: [s.salesdate, b.branchname],
                  select: %{
                    salesdate: s.salesdate,
                    pax: sum(s.pax),
                    branchname: b.branchname,
                    grand_total: sum(sp.grand_total),
                    service_charge: sum(sp.service_charge),
                    gst: sum(sp.gst_charge),
                    after_disc: sum(sp.after_disc),
                    transaction: count(s.salesid),
                    sub_total: sum(sp.sub_total),
                    rounding: sum(sp.rounding)
                  }
                )
              )

            unless start_d == end_d and end_d == Date.utc_today() do
              {:ok, history_data} =
                HistoryData.changeset(%HistoryData{}, %{
                  start_date: start_d,
                  end_date: end_d,
                  json_map: Poison.encode!(b),
                  branch_id: branchid,
                  brand_id: brand_id,
                  name: "summary"
                })
                |> Repo.insert()
            end

            b
          else
            data = Poison.decode!(history_data.json_map)

            for item <- data do
              item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}
              item = Map.put(item, :salesdate, Date.from_iso8601!(item.salesdate))
              item = Map.put(item, :after_disc, Decimal.new(item.after_disc))
              item = Map.put(item, :grand_total, Decimal.new(item.grand_total))
              item = Map.put(item, :gst, Decimal.new(item.gst))
              item = Map.put(item, :service_charge, Decimal.new(item.service_charge))
              item = Map.put(item, :sub_total, Decimal.new(item.sub_total))
              item = Map.put(item, :rounding, Decimal.new(item.rounding))
              item = Map.put(item, :pax, Decimal.new(item.pax))
            end
          end

        grp = a |> Enum.group_by(fn x -> x.salesdate end)

        year = a |> Enum.group_by(fn x -> x.salesdate.year end) |> Map.keys()

        grp_daily =
          for item <- year do
            sales = Enum.filter(a, fn x -> x.salesdate.year == item end)

            # months = sales |> Enum.group_by(fn x -> x.salesdate.month end) |> Map.keys()

            months = 1..12

            for month <- months do
              sales = Enum.filter(a, fn x -> x.salesdate.month == month end)

              days = sales |> Enum.group_by(fn x -> x.salesdate end) |> Map.keys()

              for day <- days do
                data = Enum.filter(a, fn x -> x.salesdate == day end)

                total_after_disc =
                  Enum.map(data, fn x -> Decimal.to_float(x.after_disc) end) |> Enum.sum()

                total_sub_total =
                  Enum.map(data, fn x -> Decimal.to_float(x.sub_total) end) |> Enum.sum()

                total_rounding =
                  Enum.map(data, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()

                total_sales =
                  Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end)
                  |> Enum.sum()
                  |> Float.round(2)

                total_taxes =
                  Enum.map(data, fn x -> Decimal.to_float(x.gst) end)
                  |> Enum.sum()
                  |> Float.round(2)

                total_discount = (total_after_disc - total_sub_total) |> Float.round(2)

                total_service_charge =
                  Enum.map(data, fn x -> Decimal.to_float(x.service_charge) end)
                  |> Enum.sum()
                  |> Float.round(2)

                total_transaction = Enum.map(data, fn x -> x.transaction end) |> Enum.sum()

                %{
                  date: day,
                  total_sales: total_sales - total_taxes - total_rounding,
                  total_taxes: total_taxes,
                  total_discount: total_discount,
                  total_service_charge: total_service_charge,
                  total_transaction: total_transaction
                }
              end
            end
          end
          |> List.flatten()

        group_data = a |> Enum.group_by(fn x -> x.branchname end) |> Map.keys()

        table_branch_daily_sales_sumary =
          for data <- group_data do
            data_all = a |> Enum.group_by(fn x -> x.branchname end)

            abc =
              for item <- data_all do
                name = item |> elem(0)
                item = item |> elem(1)

                if name == data do
                  grand_total =
                    Enum.map(item, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

                  after_disc =
                    Enum.map(item, fn x -> Decimal.to_float(x.after_disc) end) |> Enum.sum()

                  sub_total =
                    Enum.map(item, fn x -> Decimal.to_float(x.sub_total) end) |> Enum.sum()

                  service_charge =
                    Enum.map(item, fn x -> Decimal.to_float(x.service_charge) end) |> Enum.sum()

                  gst = Enum.map(item, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum()

                  rounding =
                    Enum.map(item, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()

                  discount = after_disc - sub_total
                  nett_sale = sub_total + service_charge + discount

                  branchname = Enum.map(item, fn x -> x.branchname end) |> Enum.uniq() |> hd

                  gross_sales =
                    Enum.map(item, fn x -> Decimal.to_float(x.sub_total) end)
                    |> Enum.sum()
                    |> Float.round(2)
                    |> Number.Delimit.number_to_delimited()

                  service_charges =
                    Enum.map(item, fn x -> Decimal.to_float(x.service_charge) end)
                    |> Enum.sum()
                    |> Float.round(2)
                    |> Number.Delimit.number_to_delimited()

                  taxes =
                    Enum.map(item, fn x -> Decimal.to_float(x.gst) end)
                    |> Enum.sum()
                    |> Float.round(2)
                    |> Number.Delimit.number_to_delimited()

                  discounts =
                    (grand_total - (sub_total + gst + service_charge + rounding))
                    |> Number.Delimit.number_to_delimited()

                  nett_sales =
                    (grand_total - gst - rounding)
                    |> Number.Delimit.number_to_delimited()

                  roundings =
                    Enum.map(item, fn x -> Decimal.to_float(x.rounding) end)
                    |> Enum.sum()
                    |> Float.round(2)
                    |> Number.Delimit.number_to_delimited()

                  # (sub_total + service_charge + discount + rounding + gst) 
                  total_sales =
                    grand_total
                    |> Float.round(2)
                    |> Number.Delimit.number_to_delimited()

                  pax = Enum.map(item, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()

                  transaction =
                    Enum.map(item, fn x -> x.transaction end)
                    |> Enum.sum()
                    |> Number.Delimit.number_to_delimited()

                  %{
                    branchname: branchname,
                    gross_sales: gross_sales,
                    service_charge: service_charges,
                    gst: taxes,
                    discount: discounts,
                    nett_sales: nett_sales,
                    roundings: roundings,
                    total_sales: total_sales,
                    pax: pax,
                    transaction: transaction
                  }
                end
              end
          end
          |> List.flatten()
          |> Enum.reject(fn x -> x == nil end)

        grand_total = Enum.map(a, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()
        after_disc = Enum.map(a, fn x -> Decimal.to_float(x.after_disc) end) |> Enum.sum()
        sub_total = Enum.map(a, fn x -> Decimal.to_float(x.sub_total) end) |> Enum.sum()
        service_charge = Enum.map(a, fn x -> Decimal.to_float(x.service_charge) end) |> Enum.sum()
        gst = Enum.map(a, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum()
        rounding = Enum.map(a, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()
        pax = Enum.map(a, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()
        transaction = Enum.map(a, fn x -> x.transaction end) |> Enum.sum()
        discount = grand_total - (sub_total + gst + service_charge + rounding)

        d_nett_sales = (grand_total - gst - rounding) |> Number.Delimit.number_to_delimited()

        d_taxes =
          Enum.map(a, fn x -> Decimal.to_float(x.gst) end)
          |> Enum.sum()
          |> Number.Delimit.number_to_delimited()

        d_pax =
          Enum.map(a, fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()
          |> Kernel.trunc()
          |> Number.Delimit.number_to_delimited()
          |> String.reverse()
          |> String.split_at(3)
          |> elem(1)
          |> String.reverse()

        d_transaction =
          Enum.map(a, fn x -> x.transaction end)
          |> Enum.sum()
          |> Kernel.trunc()
          |> Number.Delimit.number_to_delimited()
          |> String.reverse()
          |> String.split_at(3)
          |> elem(1)
          |> String.reverse()

        brand_id_int = String.to_integer(brand_id)

        order_query =
          Repo.all(
            from(
              s in Sales,
              left_join: sm in SalesMaster,
              on: sm.salesid == s.salesid,
              where:
                s.is_void == 0 and s.brand_id == ^brand_id_int and sm.brand_id == ^brand_id_int and
                  s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
              select: %{sales_details: sum(sm.qty)}
            )
          )

        d_order =
          order_query
          |> Enum.map(fn x -> Decimal.to_float(x.sales_details) end)
          |> Enum.sum()
          |> Kernel.trunc()
          |> Number.Delimit.number_to_delimited()
          |> String.reverse()
          |> String.split_at(3)
          |> elem(1)
          |> String.reverse()

        Task.start_link(__MODULE__, :dashboard_show, [
          d_nett_sales,
          d_taxes,
          d_order,
          d_pax,
          d_transaction,
          socket
        ])

        top_10_items_qty_history_data =
          Repo.get_by(
            HistoryData,
            start_date: start_d,
            end_date: end_d,
            branch_id: branchid,
            brand_id: brand_id,
            name: "top_10_items_qty"
          )

        top_10_items_qty =
          if top_10_items_qty_history_data == nil do
            b =
              Repo.all(
                from(
                  sm in BoatNoodle.BN.SalesMaster,
                  left_join: s in BoatNoodle.BN.Sales,
                  on: sm.salesid == s.salesid,
                  left_join: i in BoatNoodle.BN.ItemSubcat,
                  on: sm.itemid == i.subcatid,
                  left_join: b in BoatNoodle.BN.Brand,
                  on: b.id == ^brand.id,
                  where:
                    s.is_void == 0 and b.id == i.brand_id and s.salesdate >= ^payload["s_date"] and
                      s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
                  group_by: [i.subcatid, i.itemname],
                  select: %{
                    id: i.subcatid,
                    itemname: i.itemname,
                    qty: sum(sm.qty)
                  },
                  order_by: [desc: sum(sm.qty)],
                  limit: 10
                )
              )

            unless start_d == end_d and end_d == Date.utc_today() do
              {:ok, top_10_items_qty_history_data} =
                HistoryData.changeset(%HistoryData{}, %{
                  start_date: start_d,
                  end_date: end_d,
                  json_map: Poison.encode!(b),
                  branch_id: branchid,
                  brand_id: brand_id,
                  name: "top_10_items_qty"
                })
                |> Repo.insert()
            end

            b
          else
            data = Poison.decode!(top_10_items_qty_history_data.json_map)

            for item <- data do
              item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}

              item = Map.put(item, :qty, Decimal.new(item.qty))
              item
            end
          end

        top_10_items_value_history_data =
          Repo.get_by(
            HistoryData,
            start_date: start_d,
            end_date: end_d,
            branch_id: branchid,
            brand_id: brand_id,
            name: "top_10_items_value"
          )

        top_10_items_value =
          if top_10_items_value_history_data == nil do
            b =
              Repo.all(
                from(
                  sm in BoatNoodle.BN.SalesMaster,
                  left_join: s in BoatNoodle.BN.Sales,
                  on: sm.salesid == s.salesid,
                  left_join: i in BoatNoodle.BN.ItemSubcat,
                  on: sm.itemid == i.subcatid,
                  left_join: b in BoatNoodle.BN.Brand,
                  on: b.id == ^brand.id,
                  where:
                    s.is_void == 0 and b.id == i.brand_id and s.salesdate >= ^payload["s_date"] and
                      s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
                  group_by: [i.subcatid, i.itemname],
                  select: %{
                    itemname: i.itemname,
                    value: i.itemprice,
                    qty: sum(sm.qty)
                  }
                )
              )

            unless start_d == end_d and end_d == Date.utc_today() do
              {:ok, top_10_items_value_history_data} =
                HistoryData.changeset(%HistoryData{}, %{
                  start_date: start_d,
                  end_date: end_d,
                  json_map: Poison.encode!(b),
                  branch_id: branchid,
                  brand_id: brand_id,
                  name: "top_10_items_value"
                })
                |> Repo.insert()
            end

            b
          else
            data = Poison.decode!(top_10_items_value_history_data.json_map)

            for item <- data do
              item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}

              item = Map.put(item, :qty, Decimal.new(item.qty))
              item = Map.put(item, :value, Decimal.new(item.value))
              item
            end
          end

        top_10_selling =
          for item <- top_10_items_qty do
            %{name: item.itemname, y: Decimal.to_float(item.qty)}
          end

        top_10_selling_revenue =
          for item <- top_10_items_value do
            total = Decimal.to_float(item.value) * Decimal.to_float(item.qty)
            %{y: total, name: item.itemname}
          end
          |> Enum.sort_by(fn x -> x.y end)
          |> Enum.reverse()
          |> Enum.take(10)

        all_history_data =
          Repo.get_by(
            HistoryData,
            start_date: start_d,
            end_date: end_d,
            branch_id: branchid,
            brand_id: brand_id,
            name: "all_history_data"
          )

        all =
          if all_history_data == nil do
            b =
              Repo.all(
                from(
                  sm in BoatNoodle.BN.SalesMaster,
                  left_join: s in BoatNoodle.BN.Sales,
                  on: sm.salesid == s.salesid,
                  left_join: i in BoatNoodle.BN.ItemSubcat,
                  on: sm.itemid == i.subcatid,
                  left_join: c in BoatNoodle.BN.ItemCat,
                  on: i.itemcatid == c.itemcatid,
                  left_join: b in BoatNoodle.BN.Brand,
                  on: b.id == ^brand.id,
                  where:
                    s.is_void == 0 and c.category_type != "COMBO" and c.itemcatcode != "empty" and
                      b.id == c.brand_id and s.salesdate >= ^payload["s_date"] and
                      s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
                  group_by: [c.itemcatname, s.salesdate],
                  select: %{
                    name: c.itemcatname,
                    y: sum(sm.afterdisc)
                  }
                )
              )

            unless start_d == end_d and end_d == Date.utc_today() do
              {:ok, all_history_data} =
                HistoryData.changeset(%HistoryData{}, %{
                  start_date: start_d,
                  end_date: end_d,
                  json_map: Poison.encode!(b),
                  branch_id: branchid,
                  brand_id: brand_id,
                  name: "all_history_data"
                })
                |> Repo.insert()
            end

            b
          else
            data = Poison.decode!(all_history_data.json_map)

            for item <- data do
              item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}
              item = Map.put(item, :y, Decimal.new(item.y))
              item
            end
          end

        combo_detail_history_data =
          Repo.get_by(
            HistoryData,
            start_date: start_d,
            end_date: end_d,
            branch_id: branchid,
            brand_id: brand_id,
            name: "combo_detail"
          )

        combo_detail =
          if combo_detail_history_data == nil do
            b =
              Repo.all(
                from(
                  sm in BoatNoodle.BN.SalesMaster,
                  left_join: s in BoatNoodle.BN.Sales,
                  on: sm.salesid == s.salesid,
                  left_join: i in BoatNoodle.BN.ComboDetails,
                  on: sm.itemid == i.combo_item_id,
                  left_join: c in BoatNoodle.BN.ItemCat,
                  on: i.menu_cat_id == c.itemcatid,
                  left_join: b in BoatNoodle.BN.Brand,
                  on: b.id == ^brand.id,
                  where:
                    s.is_void == 0 and b.id == c.brand_id and s.salesdate >= ^payload["s_date"] and
                      s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
                  group_by: [c.itemcatname, s.salesdate],
                  select: %{
                    name: c.itemcatname,
                    y: sum(i.unit_price)
                  }
                )
              )

            unless start_d == end_d and end_d == Date.utc_today() do
              {:ok, all_history_data} =
                HistoryData.changeset(%HistoryData{}, %{
                  start_date: start_d,
                  end_date: end_d,
                  json_map: Poison.encode!(b),
                  branch_id: branchid,
                  brand_id: brand_id,
                  name: "combo_detail"
                })
                |> Repo.insert()
            end

            b
          else
            data = Poison.decode!(combo_detail_history_data.json_map)

            for item <- data do
              item = for {key, val} <- item, into: %{}, do: {String.to_atom(key), val}
              item = Map.put(item, :y, Decimal.new(item.y))
              item
            end
          end

        new_one = all ++ combo_detail

        new_one = new_one |> Enum.group_by(fn x -> x.name end)

        top_10_selling_category =
          for item <- new_one do
            y =
              item
              |> elem(1)
              |> Enum.map(fn x -> Decimal.to_float(x.y) end)
              |> Enum.sum()
              |> Float.round(2)

            name = item |> elem(0)

            %{name: name, y: y}
          end

        {d_nett_sales, d_taxes, d_order, d_pax, d_transaction, table_branch_daily_sales_sumary,
         grp_daily, top_10_selling, top_10_selling_revenue, top_10_selling_category}
      end

    broadcast(socket, "dashboard", %{
      nett_sales: d_nett_sales,
      taxes: d_taxes,
      order: d_order,
      pax: d_pax,
      transaction: d_transaction,
      table_branch_daily_sales_sumary: Poison.encode!(table_branch_daily_sales_sumary),
      branch_daily_sales_sumary: Poison.encode!(grp_daily),
      top_10_selling: Poison.encode!(top_10_selling),
      top_10_selling_revenue: Poison.encode!(top_10_selling_revenue),
      top_10_selling_category: Poison.encode!(top_10_selling_category)
    })

    {:noreply, socket}
  end

  def handle_in("year", payload, socket) do
    year = payload["year"]

    branch_id = payload["branch_id"]

    yearly =
      if branch_id != "0" do
        all =
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: sp.salesid == s.salesid,
              left_join: b in BoatNoodle.BN.Branch,
              on: b.branchid == s.branchid,
              where:
                s.is_void == 0 and s.branchid == ^payload["branch_id"] and
                  s.brand_id == ^payload["brand_id"],
              group_by: [s.salesdate],
              select: %{
                salesdate: s.salesdate,
                pax: sum(s.pax),
                grand_total: sum(sp.grand_total),
                gst: sum(sp.gst_charge)
              }
            )
          )

        a = all |> Enum.reject(fn x -> x.salesdate == nil end)

        year =
          a |> Enum.filter(fn x -> x.salesdate.year == String.to_integer(payload["year"]) end)

        month = year |> Enum.group_by(fn x -> x.salesdate.month end)

        yearly =
          for item <- month do
            month = item |> elem(0) |> Timex.month_name()
            data = item |> elem(1)

            grand_total =
              Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end)
              |> Enum.sum()
              |> Float.round(2)

            gst =
              Enum.map(data, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum() |> Float.round(2)

            pax =
              Enum.map(data, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum() |> Float.round(2)

            yearly = %{month: month, grand_total: grand_total, gst: gst, pax: pax}
          end
      else
        all =
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: sp.salesid == s.salesid,
              where: s.is_void == 0 and s.brand_id == ^payload["brand_id"],
              group_by: [s.salesdate],
              select: %{
                salesdate: s.salesdate,
                pax: sum(s.pax),
                grand_total: sum(sp.grand_total),
                gst: sum(sp.gst_charge)
              }
            )
          )

        a = all |> Enum.reject(fn x -> x.salesdate == nil end)

        year =
          a |> Enum.filter(fn x -> x.salesdate.year == String.to_integer(payload["year"]) end)

        month = year |> Enum.group_by(fn x -> x.salesdate.month end)

        yearly =
          for item <- month do
            month = item |> elem(0) |> Timex.month_name()
            data = item |> elem(1)

            grand_total =
              Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end)
              |> Enum.sum()
              |> Float.round(2)

            gst =
              Enum.map(data, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum() |> Float.round(2)

            pax =
              Enum.map(data, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum() |> Float.round(2)

            yearly = %{month: month, grand_total: grand_total, gst: gst, pax: pax}
          end
      end

    broadcast(socket, "yearly", %{yearly: Poison.encode!(yearly)})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
