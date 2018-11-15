defmodule BoatNoodleWeb.SalesController do
  use BoatNoodleWeb, :controller

  require IEx

  def top_sales(conn, params) do
    date_setting = params["date"]

    {start_date, end_date, dat} =
      case date_setting do
        "last_month" ->
          start_date = Timex.beginning_of_month(Date.utc_today())
          end_date = Timex.end_of_month(Date.utc_today())
          dat = "Monthly"
          {start_date, end_date, dat}

        "weekly" ->
          start_date = Timex.beginning_of_week(Date.utc_today()) |> Timex.shift(months: -3)
          end_date = Timex.end_of_week(Date.utc_today()) |> Timex.shift(months: -3)
          dat = "Weekly"
          {start_date, end_date, dat}

        "daily" ->
          # start_date = Date.utc_today
          #   end_date = Date.utc_today
          start_date = Date.new(2018, 6, 14) |> elem(1)
          end_date = Date.new(2018, 6, 14) |> elem(1)
          dat = "Daily"
          {start_date, end_date, dat}
      end

    outlet_sales =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: sp.salesid == s.salesid,
          left_join: b in BoatNoodle.BN.Branch,
          on: s.branchid == b.branchid,
          where: s.salesdate >= ^start_date and s.salesdate <= ^end_date,
          group_by: s.branchid,
          select: %{
            brand_id: s.brand_id,
            branch_id: s.branchid,
            branchname: b.branchname,
            sub_total: sum(sp.sub_total),
            service_charge: sum(sp.service_charge),
            gst_charge: sum(sp.gst_charge),
            after_disc: sum(sp.after_disc),
            grand_total: sum(sp.grand_total),
            rounding: sum(sp.rounding),
            pax: sum(s.pax)
          }
        )
      )
      |> Enum.sort_by(fn x -> x.grand_total end)
      |> Enum.reverse()

    json_map =
      %{outlet_sales: outlet_sales, start_date: start_date, end_date: end_date, dat: dat}
      |> Poison.encode!()

    send_resp(conn, 200, json_map)
  end

  defp branches() do
    Repo.all(
      from(s in BoatNoodle.BN.Branch, where: s.brand_id == 1, order_by: [asc: s.branchname])
    )
    |> Enum.reject(fn x -> x.branchid == 0 end)
  end

  def index(conn, _params) do
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

    render(conn, "index.html", branches: branches)
  end

  def new(conn, _params) do
    changeset = BN.change_sales(%Sales{})
    render(conn, "new.html", changeset: changeset)
  end

  def tables(conn, params) do
    branches =
      Repo.all(
        from(
          s in BoatNoodle.BN.Branch,
          where: s.brand_id == ^BN.get_brand_id(conn),
          order_by: s.branchname
        )
      )

    render(conn, "index.html", branches: branches)
  end

  def detail_invoice(conn, %{"branchid" => branchid, "invoiceno" => invoiceno}) do
    detail =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: sp.salesid == s.salesid,
          left_join: sd in BoatNoodle.BN.SalesMaster,
          on: sd.salesid == s.salesid,
          left_join: st in BoatNoodle.BN.Staff,
          on: st.staff_id == s.staffid,
          left_join: f in BoatNoodle.BN.Brand,
          on: sp.brand_id == f.id,
          where:
            s.invoiceno == ^invoiceno and s.branchid == ^branchid and
              f.domain_name == ^conn.params["brand"],
          select: %{
            staff_name: st.staff_name,
            tbl_no: s.tbl_no,
            pax: s.pax,
            sub_total: sp.sub_total,
            after_disc: sp.after_disc,
            service_charge: sp.service_charge,
            gst_charge: sp.gst_charge,
            rounding: sp.rounding,
            grand_total: sp.grand_total,
            cash: sp.cash,
            changes: sp.changes,
            salesdate: s.salesdatetime,
            invoiceno: s.invoiceno
          }
        )
      )
      |> hd

    salesdatetime =
      DateTime.from_naive!(detail.salesdate, "Etc/UTC")
      |> DateTime.to_string()
      |> String.split_at(19)
      |> elem(0)

    gst_charge = Decimal.to_float(detail.gst_charge)
    service_charge = Decimal.to_float(detail.service_charge)
    after_disc = Decimal.to_float(detail.after_disc)
    # IEx.pry()

    gstpercentage =
      if Decimal.to_float(detail.after_disc) == 0.0 do
        0
      else
        a = Decimal.to_float(detail.gst_charge) / Decimal.to_float(detail.after_disc) * 100

        a
        |> Float.round(0)
        |> Float.to_string()
        |> String.reverse()
        |> String.split_at(2)
        |> elem(1)
        |> String.reverse()
      end

    servicepercentage =
      if Decimal.to_float(detail.after_disc) == 0.0 do
        0
      else
        a = Decimal.to_float(detail.service_charge) / Decimal.to_float(detail.after_disc) * 100

        a
        |> Float.round(0)
        |> Float.to_string()
        |> String.reverse()
        |> String.split_at(2)
        |> elem(1)
        |> String.reverse()
      end

    detail = %{
      staff_name: detail.staff_name,
      tbl_no: detail.tbl_no,
      pax: detail.pax,
      sub_total: detail.sub_total,
      after_disc: detail.after_disc,
      service_charge: detail.service_charge,
      gst_charge: detail.gst_charge,
      rounding: detail.rounding,
      grand_total: detail.grand_total,
      cash: detail.cash,
      changes: detail.changes,
      salesdate: salesdatetime,
      invoiceno: detail.invoiceno,
      gstpercentage: gstpercentage,
      servicepercentage: servicepercentage
    }

    detail_item =
      Repo.all(
        from(
          s in BoatNoodle.BN.Sales,
          left_join: sd in BoatNoodle.BN.SalesMaster,
          on: sd.salesid == s.salesid,
          left_join: is in BoatNoodle.BN.ItemSubcat,
          on: is.subcatid == sd.itemid,
          left_join: c in BoatNoodle.BN.ComboDetails,
          on: sd.itemid == c.combo_item_id,
          left_join: b in BoatNoodle.BN.Branch,
          on: s.branchid == b.branchid,
          left_join: f in BoatNoodle.BN.Brand,
          on: sd.brand_id == f.id,
          where:
            s.invoiceno == ^invoiceno and s.branchid == ^branchid and
              f.domain_name == ^conn.params["brand"] and is.brand_id == f.id and
              b.brand_id == f.id,
          select: %{
            combo_item_name: c.combo_item_name,
            itemname: is.itemname,
            qty: sd.qty,
            afterdisc: sd.order_price
          }
        )
      )

    render(conn, "detail_invoice.html", detail: detail, detail_item: detail_item)
  end

  def monthly_sales_csv(conn, params) do
    brand = Repo.get_by(Brand, id: BN.get_brand_id(conn))

    branch = Repo.get_by(Branch, branchid: params["branch"], brand_id: brand.id)

    id = branch.branchid |> Integer.to_string()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"Monthly Sales" <> branch.branchcode <> ".csv\""
    )
    |> send_resp(200, csv_monthly_sales(conn, params))
  end

  defp csv_monthly_sales(conn, params) do
    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    brand_id = brand.id
    start_d = params["start_date"]
    end_d = params["end_date"]

    all =
      if branch_id != "0" do
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and s.branchid == ^params["branch"] and s.brand_id == ^brand_id and
                b.brand_id == ^brand_id and sp.brand_id == ^brand_id,
            select: %{
              salesdate: s.salesdate,
              id: s.invoiceno,
              pax: s.pax,
              grand_total: sp.grand_total,
              service_charge: sp.service_charge,
              gst: sp.gst_charge,
              after_disc: sp.after_disc,
              transaction: s.salesid,
              sub_total: sp.sub_total,
              rounding: sp.rounding
            }
          )
        )
      else
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and sp.brand_id == ^brand_id and s.brand_id == ^brand_id and
                b.brand_id == ^brand_id,
            select: %{
              id: s.invoiceno,
              salesdate: s.salesdate,
              pax: s.pax,
              grand_total: sp.grand_total,
              service_charge: sp.service_charge,
              gst: sp.gst_charge,
              after_disc: sp.after_disc,
              transaction: s.salesid,
              sub_total: sp.sub_total,
              rounding: sp.rounding
            }
          )
        )
      end

    a = Date.from_iso8601!(start_d)
    year = a.year

    total =
      all
      |> Enum.reject(fn x -> x.salesdate == nil end)
      |> Enum.filter(fn x -> x.salesdate.year == year end)

    ranges = 1..12

    data =
      for range <- ranges do
        bulan = range |> Timex.month_name()

        pax =
          total
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdate.month == range end)
          |> Enum.map(fn x -> x.pax end)
          |> Enum.sum()

        receipt =
          total
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdate.month == range end)
          |> Enum.map(fn x -> x.id end)
          |> Enum.count()

        service_charge =
          total
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdate.month == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.service_charge) end)
          |> Enum.sum()

        after_disc =
          total
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdate.month == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.after_disc) end)
          |> Enum.sum()

        sub_total =
          total
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdate.month == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.sub_total) end)
          |> Enum.sum()

        grand_total =
          total
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdate.month == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        gst =
          total
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdate.month == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.gst) end)
          |> Enum.sum()

        rounding =
          total
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdate.month == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.rounding) end)
          |> Enum.sum()

        disc_amt = grand_total - (sub_total + service_charge + gst + rounding)

        service_charge =
          if service_charge != 0 do
            service_charge |> :erlang.float_to_binary(decimals: 2)
          else
            0
          end

        after_disc =
          if after_disc != 0 do
            after_disc |> :erlang.float_to_binary(decimals: 2)
          else
            0
          end

        sub_total =
          if sub_total != 0 do
            sub_total |> :erlang.float_to_binary(decimals: 2)
          else
            0
          end

        grand_total =
          if grand_total != 0 do
            grand_total |> :erlang.float_to_binary(decimals: 2)
          else
            0
          end

        gst =
          if gst != 0 do
            gst |> :erlang.float_to_binary(decimals: 2)
          else
            0
          end

        rounding =
          if rounding != 0 do
            rounding |> :erlang.float_to_binary(decimals: 2)
          else
            0
          end

        disc_amt =
          if disc_amt != 0 do
            disc_amt |> :erlang.float_to_binary(decimals: 2)
          else
            0
          end

        [
          bulan,
          pax,
          receipt,
          sub_total,
          after_disc,
          disc_amt,
          gst,
          service_charge,
          rounding,
          grand_total
        ]
      end

    csv_content = [
      'Month ',
      'Pax',
      'Total Receipts',
      'SubTotal',
      'After Discount',
      'Discount Amount',
      'Tax',
      'Service Charge',
      'Roundings',
      'Total'
    ]

    csv_content =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end

  def export_to_csv_summary(conn, params) do
    brand = Repo.get_by(Brand, id: BN.get_brand_id(conn))

    branch = Repo.get_by(Branch, branchid: params["branch"], brand_id: brand.id)

    id = branch.branchid |> Integer.to_string()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"Daily Sales Summary" <> branch.branchcode <> ".csv\""
    )
    |> send_resp(200, csv_summary(conn, params))
  end

  defp csv_summary(conn, params) do
    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    brand_id = brand.id
    start_d = params["start_date"]
    end_d = params["end_date"]

    all =
      if branch_id != "0" do
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and s.branchid == ^params["branch"] and s.salesdate >= ^start_d and
                s.salesdate <= ^end_d and s.brand_id == ^brand_id and b.brand_id == ^brand_id and
                sp.brand_id == ^brand_id,
            group_by: [s.salesdate],
            order_by: [desc: s.salesdate],
            select: %{
              salesdate: s.salesdate,
              id: count(s.invoiceno),
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
      else
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and s.salesdate >= ^params["start_date"] and
                s.salesdate <= ^params["end_date"] and sp.brand_id == ^brand_id and
                s.brand_id == ^brand_id and b.brand_id == ^brand_id,
            group_by: [s.salesdate],
            order_by: [desc: s.salesdate],
            select: %{
              id: count(s.invoiceno),
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
      end

    data =
      for item <- all do
        afterdisc = Decimal.to_float(item.after_disc) |> Float.round(2)
        sub_total = Decimal.to_float(item.sub_total) |> Float.round(2)
        service_charge = Decimal.to_float(item.service_charge) |> Float.round(2)
        gst_charge = Decimal.to_float(item.gst) |> Float.round(2)
        rounding = Decimal.to_float(item.rounding) |> Float.round(2)

        disc_amt =
          Decimal.to_float(item.grand_total) -
            (Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
               Decimal.to_float(item.gst) + Decimal.to_float(item.rounding))

        dis =
          Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
            Decimal.to_float(item.gst) + Decimal.to_float(item.rounding) -
            Decimal.to_float(item.grand_total)

        grand_total = Decimal.to_float(item.grand_total) |> Float.round(2)

        after_disc = (sub_total - dis) |> Float.round(2)

        beforedisc =
          Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
            Decimal.to_float(item.gst) + Decimal.to_float(item.rounding)

        csv_content = [
          item.salesdate,
          item.pax,
          item.id,
          sub_total |> :erlang.float_to_binary(decimals: 2),
          after_disc |> :erlang.float_to_binary(decimals: 2),
          disc_amt |> :erlang.float_to_binary(decimals: 2),
          gst_charge |> :erlang.float_to_binary(decimals: 2),
          service_charge |> :erlang.float_to_binary(decimals: 2),
          rounding |> :erlang.float_to_binary(decimals: 2),
          grand_total |> :erlang.float_to_binary(decimals: 2)
        ]
      end

    csv_content = [
      'Day ',
      'Pax',
      'Total Receipts',
      'SubTotal',
      'After Discount',
      'Discount Amount',
      'GST',
      'Service Charge',
      'Roundings',
      'Total'
    ]

    csv_content =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end

  def export_to_csv_group_by_branch(conn, params) do
    brand = Repo.get_by(Brand, id: BN.get_brand_id(conn))

    branch = Repo.get_by(Branch, branchid: params["branch"], brand_id: brand.id)

    id = branch.branchid |> Integer.to_string()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"Daily Sales" <> branch.branchcode <> ".csv\""
    )
    |> send_resp(200, csv_group_by_branch(conn, params))
  end

  defp csv_group_by_branch(conn, params) do
    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    brand_id = brand.id
    start_d = params["start_date"]
    end_d = params["end_date"]

    all =
      if branch_id != "0" do
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and s.branchid == ^params["branch"] and s.salesdate >= ^start_d and
                s.salesdate <= ^end_d and s.brand_id == ^brand_id and b.brand_id == ^brand_id and
                sp.brand_id == ^brand_id,
            group_by: [s.salesdate, b.branchname],
            select: %{
              id: count(s.salesid),
              salesdate: s.salesdate,
              pax: sum(s.pax),
              branchname: b.branchname,
              grand_total: sum(sp.grand_total),
              service_charge: sum(sp.service_charge),
              gst: sum(sp.gst_charge),
              after_disc: sum(sp.after_disc),
              transaction: count(s.salesid),
              sub_total: sum(sp.sub_total),
              rounding: sum(sp.rounding),
              owner: b.manager
            }
          )
        )
      else
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and s.salesdate >= ^start_d and s.salesdate <= ^end_d and
                sp.brand_id == ^brand_id and b.brand_id == ^brand_id and s.brand_id == ^brand_id,
            group_by: [s.salesdate, b.branchname],
            select: %{
              id: count(s.salesid),
              salesdate: s.salesdate,
              pax: sum(s.pax),
              branchname: b.branchname,
              grand_total: sum(sp.grand_total),
              service_charge: sum(sp.service_charge),
              gst: sum(sp.gst_charge),
              after_disc: sum(sp.after_disc),
              transaction: count(s.salesid),
              sub_total: sum(sp.sub_total),
              rounding: sum(sp.rounding),
              owner: b.manager
            }
          )
        )
      end

    staffs =
      Repo.all(
        from(
          cd in Staff,
          where: cd.brand_id == ^brand.id,
          select: %{
            staff_id: cd.staff_id,
            staff_name: cd.staff_name
          }
        )
      )

    data =
      for item <- all do
        afterdisc = Decimal.to_float(item.after_disc) |> Float.round(2)
        sub_total = Decimal.to_float(item.sub_total) |> Float.round(2)
        service_charge = Decimal.to_float(item.service_charge) |> Float.round(2)
        gst_charge = Decimal.to_float(item.gst) |> Float.round(2)
        rounding = Decimal.to_float(item.rounding) |> Float.round(2)

        disc_amt =
          Decimal.to_float(item.grand_total) -
            (Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
               Decimal.to_float(item.gst) + Decimal.to_float(item.rounding))

        grand_total = Decimal.to_float(item.grand_total) |> Float.round(2)

        dis =
          Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
            Decimal.to_float(item.gst) + Decimal.to_float(item.rounding) -
            Decimal.to_float(item.grand_total)

        after_disc = (sub_total - dis + rounding) |> Float.round(2)

        nett_sales = grand_total - service_charge - gst_charge - rounding

        total_sales = nett_sales + service_charge

        beforedisc =
          Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
            Decimal.to_float(item.gst) + Decimal.to_float(item.rounding)

        csv_content = [
          item.salesdate,
          item.pax,
          item.id,
          sub_total |> :erlang.float_to_binary(decimals: 2),
          after_disc |> :erlang.float_to_binary(decimals: 2),
          disc_amt |> :erlang.float_to_binary(decimals: 2),
          gst_charge |> :erlang.float_to_binary(decimals: 2),
          service_charge |> :erlang.float_to_binary(decimals: 2),
          rounding |> :erlang.float_to_binary(decimals: 2),
          total_sales |> :erlang.float_to_binary(decimals: 2),
          item.branchname,
          manager(item.owner, staffs)
        ]
      end

    csv_content = [
      'Date ',
      'Pax',
      'Total Receipts',
      'Gross Sales',
      'After Discount',
      'Discount Amount',
      'SST',
      'Service Charge',
      'Roundings',
      'Total',
      'Branch Name',
      'Branch Owner'
    ]

    csv_content =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end

  def excel(conn, params) do
    brand = Repo.get_by(Brand, id: BN.get_brand_id(conn))

    branch = Repo.get_by(Branch, branchid: params["branch"], brand_id: brand.id)

    id = branch.branchid |> Integer.to_string()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"Receipt Report" <> branch.branchcode <> ".csv\""
    )
    |> send_resp(200, csv_content_excel(conn, params))
  end

  defp csv_content_excel(conn, params) do
    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    start_date = params["start_date"]
    end_date = params["end_date"]

    all =
      if branch_id != "0" do
        Repo.all(
          from(
            s in Sales,
            left_join: p in SalesPayment,
            on: s.salesid == p.salesid,
            left_join: b in Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and b.branchid == ^branch_id and s.brand_id == ^brand.id and
                p.brand_id == ^brand.id and b.brand_id == ^brand.id and
                s.salesdate >= ^params["start_date"] and s.salesdate <= ^params["end_date"],
            order_by: [s.salesdatetime],
            select: %{
              date: s.salesdate,
              time: s.salesdatetime,
              invoiceno: s.invoiceno,
              tbl_no: s.tbl_no,
              pax: s.pax,
              staff_id: s.staffid,
              sub_total: p.sub_total,
              service_charge: p.service_charge,
              gst_charge: p.gst_charge,
              grand_total: p.grand_total,
              payment_type: p.payment_type,
              is_void: s.is_void,
              rounding: p.rounding,
              branchcode: b.branchcode,
              branchname: b.branchname,
              after_disc: p.after_disc,
              payment_name1: p.payment_name1,
              payment_code1: p.payment_code1,
              payment_type_amt1: p.payment_type_amt1,
              payment_name2: p.payment_name2,
              payment_code2: p.payment_code2,
              payment_type_amt2: p.payment_type_amt2
            }
          )
        )
        |> Enum.with_index()
      else
        Repo.all(
          from(
            s in Sales,
            left_join: p in SalesPayment,
            on: s.salesid == p.salesid,
            left_join: b in Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and s.brand_id == ^brand.id and p.brand_id == ^brand.id and
                b.brand_id == ^brand.id and s.salesdate >= ^params["start_date"] and
                s.salesdate <= ^params["end_date"],
            order_by: [desc: s.salesdatetime],
            select: %{
              date: s.salesdate,
              time: s.salesdatetime,
              invoiceno: s.invoiceno,
              tbl_no: s.tbl_no,
              pax: s.pax,
              staff_id: s.staffid,
              sub_total: p.sub_total,
              service_charge: p.service_charge,
              gst_charge: p.gst_charge,
              grand_total: p.grand_total,
              payment_type: p.payment_type,
              is_void: s.is_void,
              rounding: p.rounding,
              branchcode: b.branchcode,
              branchname: b.branchname,
              after_disc: p.after_disc,
              payment_name1: p.payment_name1,
              payment_code1: p.payment_code1,
              payment_type_amt1: p.payment_type_amt1,
              payment_name2: p.payment_name2,
              payment_code2: p.payment_code2,
              payment_type_amt2: p.payment_type_amt2
            }
          )
        )
        |> Enum.with_index()
      end

    staff_data = Repo.all(from(s in Staff, where: s.brand_id == ^brand.id))

    data =
      for item <- all do
        seq_no = item |> elem(1)

        item = item |> elem(0)

        staff_name = get_staff_name(item.staff_id, staff_data)

        time =
          DateTime.from_naive!(item.time, "Etc/UTC")
          |> DateTime.to_time()
          |> Time.to_string()
          |> String.split_at(5)
          |> elem(0)

        afterdisc = Decimal.to_float(item.after_disc) |> Float.round(2)
        sub_total = Decimal.to_float(item.sub_total) |> Float.round(2)
        service_charge = Decimal.to_float(item.service_charge) |> Float.round(2)
        gst_charge = Decimal.to_float(item.gst_charge) |> Float.round(2)
        rounding = Decimal.to_float(item.rounding) |> Float.round(2)

        disc_amt =
          Decimal.to_float(item.grand_total) -
            (Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
               Decimal.to_float(item.gst_charge) + Decimal.to_float(item.rounding))

        grand_total = Decimal.to_float(item.grand_total) |> Float.round(2)

        after_disc = (sub_total - disc_amt) |> Float.round(2)

        beforedisc =
          Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
            Decimal.to_float(item.gst_charge) + Decimal.to_float(item.rounding)

        disc_percent =
          if beforedisc == 0 do
            100
          else
            disc_percent =
              if after_disc == 0 do
                0
              else
                (beforedisc - Decimal.to_float(item.grand_total)) / beforedisc * 100
              end
          end
          |> Float.round(2)

        salesstatus =
          if item.is_void == 0 do
            "C"
          else
            "V"
          end

        csv_content = [
          item.date,
          time,
          seq_no + 1,
          item.invoiceno,
          staff_name,
          item.tbl_no,
          item.pax,
          sub_total |> :erlang.float_to_binary(decimals: 2),
          disc_amt |> :erlang.float_to_binary(decimals: 2),
          disc_percent |> :erlang.float_to_binary(decimals: 2),
          afterdisc |> :erlang.float_to_binary(decimals: 2),
          service_charge |> :erlang.float_to_binary(decimals: 2),
          gst_charge |> :erlang.float_to_binary(decimals: 2),
          rounding |> :erlang.float_to_binary(decimals: 2),
          grand_total |> :erlang.float_to_binary(decimals: 2),
          item.payment_type,
          item.payment_name1,
          item.payment_code1,
          item.payment_type_amt1,
          item.payment_name2,
          item.payment_code2,
          item.payment_type_amt2,
          salesstatus,
          item.branchname
        ]
      end

    csv_content = [
      'DATE ',
      'TIME',
      'SEQNO',
      'RECEIPT_ID',
      'CASHIER',
      'TABLE',
      'PAX',
      'SUBTOTAL',
      'DISC_AMOUNT',
      'DISC_PERCENT',
      'SUB_TOTAL_AFTER_DISCOUNT',
      'SERVICE CHARGE',
      'GOVT_TAX',
      'ROUNDING',
      'TOTAL',
      'PAYMENT',
      'PAYMENT TYPE 1',
      'PAYMENT CODE 1',
      'PAYMENT AMT 1',
      'PAYMENT TYPE 2',
      'PAYMENT CODE 2',
      'PAYMENT AMT 2',
      'SALES_STATUS',
      'BRANCH'
    ]

    csv_content =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end

  defp get_staff_name(staff_id, staffs) do
    staff_name = Enum.filter(staffs, fn x -> x.staff_id == String.to_integer(staff_id) end)

    if staff_name != [] do
      a = staff_name |> hd
      a.staff_name
    else
      "unknown cashier"
    end
  end

  def quickbook(conn, params) do
    brand = Repo.get_by(Brand, id: BN.get_brand_id(conn))

    branch = Repo.get_by(Branch, branchid: params["branch"], brand_id: brand.id)

    id = branch.branchid |> Integer.to_string()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"Daily Item Sales" <> branch.branchcode <> ".csv\""
    )
    |> send_resp(200, csv_content(conn, params))
  end

  defp get_item_name(itemid, items, combo) do
    item_name = Enum.filter(items, fn x -> x.subcatid == itemid end)

    if item_name != [] do
      a = item_name |> hd
      a.itemname
    else
      b = Enum.filter(combo, fn x -> x.combo_item_id == itemid end)

      if b == [] do
        "unknown item"
      else
        a = b |> hd
        a.combo_item_name
      end
    end
  end

  defp get_item_desc(itemid, items, combo) do
    item_name = Enum.filter(items, fn x -> x.subcatid == itemid end)

    if item_name != [] do
      a = item_name |> hd
      a.itemdesc
    else
      b = Enum.filter(combo, fn x -> x.combo_item_id == itemid end)

      if b == [] do
        "unknown item"
      else
        a = b |> hd
        a.combo_item_name
      end
    end
  end

  defp csv_content(conn, params) do
    brand = Repo.get_by(Brand, id: BN.get_brand_id(conn))

    branch = Repo.get_by(Branch, branchid: params["branch"], brand_id: brand.id)

    id = branch.branchid |> Integer.to_string()

    if params["branch"] != "0" do
      a1 =
        Repo.all(
          from(
            s in Sales,
            left_join: p in SalesMaster,
            on: s.salesid == p.salesid,
            left_join: b in Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and p.is_void == 0 and b.branchid == ^id and b.brand_id == ^brand.id and
                s.brand_id == ^brand.id and s.salesdate >= ^params["start_date"] and
                s.salesdate <= ^params["end_date"] and p.combo_id == ^0,
            group_by: [s.salesdate, p.itemid, p.itemname, b.branchcode],
            order_by: [s.salesdate, p.itemname],
            select: %{
              date: s.salesdate,
              name: p.itemname,
              itemid: p.itemid,
              salesid: p.salesid,
              desc: p.itemname,
              branch: b.branchcode,
              qty: sum(p.qty),
              order_price: sum(p.order_price)
            }
          )
        )

      a2 =
        Repo.all(
          from(
            s in Sales,
            left_join: p in SalesMaster,
            on: s.salesid == p.salesid,
            left_join: b in Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and p.is_void == 0 and b.branchid == ^id and b.brand_id == ^brand.id and
                s.brand_id == ^brand.id and s.salesdate >= ^params["start_date"] and
                s.salesdate <= ^params["end_date"] and p.combo_id != ^0,
            group_by: [s.salesdate, p.itemid, p.itemname, b.branchcode],
            order_by: [s.salesdate, p.itemname],
            select: %{
              date: s.salesdate,
              name: p.itemname,
              itemid: p.itemid,
              salesid: p.salesid,
              desc: p.itemname,
              branch: b.branchcode,
              qty: sum(p.qty),
              order_price: sum(p.order_price)
            }
          )
        )
        |> Enum.reject(fn x -> String.length(Integer.to_string(x.itemid)) == 6 end)

      all = (a1 ++ a2) |> List.flatten()

      all =
        all
        |> Enum.group_by(fn x -> x.date end)

      csv_content = [
        'CustomerRefFullName ',
        'ClassRefFullName',
        'TempleteRefFullName',
        'TxnDate',
        'RefNumber',
        'DepositToAccountRefFullName',
        'ItemRefFullName',
        'Desc',
        'Quantity',
        'Rate',
        'Amount',
        'LineClassRefFullName',
        'SalesTaxCodeFullName'
      ]

      name_data = Repo.all(from(s in ItemSubcat, where: s.brand_id == ^brand.id))
      combo_data = Repo.all(from(s in ComboDetails, where: s.brand_id == ^brand.id))

      data =
        for item <- all do
          date2 = item |> elem(0) |> Date.to_string()
          date = item |> elem(0)
          item = item |> elem(1)

          rpt =
            Repo.all(
              from(
                s in Sales,
                left_join: sp in SalesPayment,
                on: s.salesid == sp.salesid,
                left_join: b in Branch,
                on: b.branchid == s.branchid,
                where:
                  s.is_void == 0 and s.salesdate == ^date2 and
                    b.report_class == ^branch.report_class and s.brand_id == ^brand.id and
                    b.brand_id == ^brand.id and sp.brand_id == ^brand.id and b.branchid == ^id,
                select: %{
                  grand_total: sum(sp.grand_total),
                  sub_total: sum(sp.sub_total),
                  service_charge: sum(sp.service_charge),
                  gst_charge: sum(sp.gst_charge),
                  rounding: sum(sp.rounding),
                  taxcode: sp.taxcode
                }
              )
            )

          rpt =
            rpt
            |> hd

          gft =
            for item <- item do
              trkh = item.date |> Date.to_string()

              item_name = get_item_name(item.itemid, name_data, combo_data)
              item_desc = get_item_desc(item.itemid, name_data, combo_data)

              order_price = Decimal.to_float(item.order_price) |> Float.to_string()
              qty = Decimal.to_float(item.qty) |> Float.to_string()

              date =
                item.date
                |> Date.to_string()
                |> String.split_at(2)
                |> elem(1)
                |> String.split("-")
                |> Enum.join()
                |> String.split_at(2)

              year = date |> elem(0)

              b = date |> elem(1)

              rate =
                (Decimal.to_float(item.order_price) / Decimal.to_float(item.qty))
                |> Float.to_string()

              c = b |> String.split_at(2)

              month = c |> elem(0)

              day = c |> elem(1)

              string = item.branch

              join = day <> month <> year <> string

              name = branch.report_class
              cashin = "CashInDrawer:"
              full = cashin <> name

              [
                'Daily Sales',
                branch.report_class,
                'Custom Sales Receipt',
                trkh,
                join,
                full,
                item_name,
                item_desc,
                qty,
                rate,
                order_price,
                branch.report_class,
                rpt.taxcode
              ]
            end

          date =
            date
            |> Date.to_string()
            |> String.split_at(2)
            |> elem(1)
            |> String.split("-")
            |> Enum.join()
            |> String.split_at(2)

          code = item |> hd

          year = date |> elem(0)

          b = date |> elem(1)

          c = b |> String.split_at(2)

          month = c |> elem(0)

          day = c |> elem(1)

          string = code.branch

          join = day <> month <> year <> string

          name = branch.report_class
          cashin = "CashInDrawer:"
          full = cashin <> name

          grand_total =
            if rpt.grand_total != nil do
              Decimal.to_float(rpt.grand_total)
            else
              0
            end

          sub_total =
            if rpt.sub_total != nil do
              Decimal.to_float(rpt.sub_total)
            else
              0
            end

          service_charge =
            if rpt.service_charge != nil do
              Decimal.to_float(rpt.service_charge)
            else
              0
            end

          gst_charge =
            if rpt.gst_charge != nil do
              Decimal.to_float(rpt.gst_charge)
            else
              0
            end

          rounding =
            if rpt.rounding != nil do
              Decimal.to_float(rpt.rounding)
            else
              0
            end

          rounding2 =
            Repo.all(
              from(
                s in Sales,
                left_join: sp in SalesPayment,
                on: s.salesid == sp.salesid,
                left_join: b in Branch,
                on: b.branchid == s.branchid,
                left_join: t in Brand,
                on: t.id == s.brand_id,
                where:
                  s.is_void == 0 and s.salesdate == ^date2 and
                    b.report_class == ^branch.report_class and t.id == ^brand.id and
                    s.brand_id == ^brand.id and b.brand_id == ^brand.id and
                    sp.brand_id == ^brand.id and b.branchid == ^id,
                select: %{
                  rounding: sum(sp.rounding)
                }
              )
            )
            |> hd

          rounding2 =
            if rounding2.rounding != nil do
              Decimal.to_float(rounding2.rounding)
            else
              0
            end

          disc_amt = grand_total - (sub_total + service_charge + gst_charge + rounding)

          serv =
            if rpt.taxcode == "SER" do
              ""
            else
              "SR0"
            end

          tpm = [
            'Daily Sales',
            branch.report_class,
            'Custom Sales Receipt',
            date2,
            join,
            full,
            "sevc charge",
            "",
            "",
            service_charge,
            service_charge,
            branch.report_class,
            serv
          ]

          tpf = [
            'Daily Sales',
            branch.report_class,
            'Custom Sales Receipt',
            date2,
            join,
            full,
            "Total Rounding",
            "",
            "",
            rounding2 |> :erlang.float_to_binary(decimals: 2),
            rounding2 |> :erlang.float_to_binary(decimals: 2),
            branch.report_class,
            ""
          ]

          tpq = [
            'Daily Sales',
            branch.report_class,
            'Custom Sales Receipt',
            date2,
            join,
            full,
            "Discount",
            "",
            "",
            disc_amt |> :erlang.float_to_binary(decimals: 2),
            disc_amt |> :erlang.float_to_binary(decimals: 2),
            branch.report_class,
            rpt.taxcode
          ]

          paytype1 =
            Repo.all(
              from(
                s in Sales,
                left_join: sp in SalesPayment,
                on: s.salesid == sp.salesid,
                left_join: p in PaymentType,
                on: p.payment_type_id == sp.payment_type_id1,
                left_join: b in Branch,
                on: b.branchid == s.branchid,
                left_join: t in Brand,
                on: t.id == s.brand_id,
                group_by: [p.payment_type_name, p.payment_type_id],
                where:
                  s.is_void == 0 and s.salesdate == ^date2 and sp.payment_type_id1 != 1 and
                    t.id == ^brand.id and s.brand_id == ^brand.id and p.brand_id == ^brand.id and
                    b.brand_id == ^brand.id and sp.brand_id == ^brand.id and b.branchid == ^id,
                select: %{
                  payment_type_name: p.payment_type_name,
                  pay_amt: sum(sp.payment_type_amt1)
                }
              )
            )

          paytype2 =
            Repo.all(
              from(
                s in Sales,
                left_join: sp in SalesPayment,
                on: s.salesid == sp.salesid,
                left_join: p in PaymentType,
                on: p.payment_type_id == sp.payment_type_id2,
                left_join: b in Branch,
                on: b.branchid == s.branchid,
                left_join: t in Brand,
                on: t.id == s.brand_id,
                group_by: [p.payment_type_name, p.payment_type_id],
                where:
                  s.is_void == 0 and s.salesdate == ^date2 and sp.payment_type_id2 != 1 and
                    t.id == ^brand.id and p.brand_id == ^brand.id and s.brand_id == ^brand.id and
                    b.brand_id == ^brand.id and sp.brand_id == ^brand.id and b.branchid == ^id,
                select: %{
                  payment_type_name: p.payment_type_name,
                  pay_amt: sum(sp.payment_type_amt2)
                }
              )
            )

          paytype = (paytype1 ++ paytype2) |> Enum.filter(fn x -> x.payment_type_name != nil end)

          shortextra =
            Repo.all(
              from(
                r in BoatNoodle.BN.RPTCASHIEREOD,
                left_join: b in Branch,
                on: b.branchcode == r.branchcode,
                left_join: t in Brand,
                on: t.id == r.brand_id,
                group_by: [r.time_end],
                where: r.branch_id == ^id and r.brand_id == ^brand.id,
                select: %{totalextra: sum(r.extra), time_end: r.time_end}
              )
            )

          extra =
            Enum.map(shortextra, fn x ->
              %{totalextra: x.totalextra, date: DateTime.to_date(x.time_end) |> Date.to_string()}
            end)

          extra = extra |> Enum.filter(fn x -> x.date == date2 end)

          shortextra =
            if extra != [] do
              Enum.map(extra, fn x -> Decimal.to_float(x.totalextra) end) |> Enum.sum()
            else
              0
            end

          tpt = [
            'Daily Sales',
            branch.report_class,
            'Custom Sales Receipt',
            date2,
            join,
            full,
            "Short/Extra",
            "",
            "",
            shortextra,
            shortextra,
            branch.report_class,
            ""
          ]

          ccard =
            Repo.all(
              from(
                s in Sales,
                left_join: sp in SalesPayment,
                on: s.salesid == sp.salesid,
                left_join: b in Branch,
                on: b.branchid == s.branchid,
                left_join: t in Brand,
                on: t.id == s.brand_id,
                where:
                  s.is_void == 0 and s.salesdate == ^date2 and t.id == ^brand.id and
                    s.brand_id == ^brand.id and b.brand_id == ^brand.id and
                    sp.brand_id == ^brand.id and b.branchid == ^id and
                    sp.payment_type == "CREDITCARD",
                select: sum(sp.grand_total)
              )
            )
            |> hd

          ccard =
            if ccard != nil do
              0 - Decimal.to_float(ccard)
            else
              0
            end

          tps = [
            'Daily Sales',
            branch.report_class,
            'Custom Sales Receipt',
            date2,
            join,
            full,
            "CREDITCARD",
            "",
            "",
            ccard,
            ccard,
            branch.report_class,
            ""
          ]

          trm =
            for item <- paytype do
              [
                'Daily Sales',
                branch.report_class,
                'Custom Sales Receipt',
                date2,
                join,
                full,
                item.payment_type_name,
                "",
                "",
                (0 - Decimal.to_float(item.pay_amt)) |> Float.to_string(),
                (0 - Decimal.to_float(item.pay_amt)) |> Float.to_string(),
                branch.report_class,
                ""
              ]
            end

          tq = List.insert_at(gft, -1, tpm)
          tq1 = List.insert_at(tq, -1, tpf)
          tq2 = List.insert_at(tq1, -1, tpq)
          tq3 = List.insert_at(tq2, -1, tpt)
          tq4 = List.insert_at(tq3, -1, tps)
          tq5 = tq4 ++ trm
        end
        |> Enum.flat_map(fn x -> x end)

      csv_content =
        List.insert_at(data, 0, csv_content)
        |> CSV.encode()
        |> Enum.to_list()
        |> to_string
    else
      conn
      |> put_flash(:info, "Please Choose a Branch.")
      |> redirect(to: sales_path(conn, :index, BN.get_domain(conn)))
    end
  end

  def summary(conn, _params) do
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

    render(conn, "summary.html", branches: branches)
  end

  def item_sales(conn, _params) do
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

    reports =
      Repo.all(from(r in BoatNoodle.BN.Report, where: r.brand_id == ^BN.get_brand_id(conn)))

    render(conn, "item_sales.html", branches: branches, reports: reports)
  end

  def discounts(conn, _params) do
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

    render(conn, "discounts.html", branches: branches)
  end

  def voided(conn, _params) do
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

    render(conn, "voided.html", branches: branches)
  end

  def csv_compare_category_qty(conn, _params) do
    branches =
      Repo.all(
        from(
          s in BoatNoodle.BN.Branch,
          where: s.brand_id == ^BN.get_brand_id(conn),
          order_by: s.branchname
        )
      )

    render(conn, "csv_compare_category_qty.html", branches: branches)
  end

  def create_cv(conn, _params) do
    s_date = _params["start_date"]
    e_date = _params["end_date"]

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data1 =
      Date.range(a, b)
      |> Enum.map(fn x -> %{date: x} end)
      |> Enum.group_by(fn x -> Integer.to_string(x.date.month) end)
      |> Map.keys()

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    try1 =
      Repo.all(
        from(
          sd in BoatNoodle.BN.SalesMaster,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sd.salesid,
          left_join: is in BoatNoodle.BN.ItemSubcat,
          on: sd.itemid == is.subcatid,
          left_join: ic in BoatNoodle.BN.ItemCat,
          on: ic.itemcatid == is.itemcatid,
          where:
            s.branchid == ^_params["branchid"] and s.salesdate >= ^_params["start_date"] and
              s.salesdate <= ^_params["end_date"],
          select: %{
            total: sd.qty,
            date: s.salesdate,
            price: sd.order_price,
            itemcatname: ic.itemcatname,
            combo_id: is.is_comboitem
          }
        )
      )

    month =
      for item <- date_data1 do
        item |> String.to_integer() |> Timex.month_name()
      end

    addon_qty_ind =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x -> x.date.month == item and x.itemcatname == "F_AddOn" end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{sum: a}
      end

    beverages_qty_ind =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id == 0 and x.itemcatname == "F_Beverages"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{sum: a}
      end

    beverages_qty_com =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id != 0 and x.itemcatname == "F_Beverages"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{sum: a}
      end

    breakfast_qty_ind =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id == 0 and x.itemcatname == "F_Breakfast"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{sum: a}
      end

    breakfast_qty_com =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id != 0 and x.itemcatname == "F_Breakfast"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{sum: a}
      end

    noodle_qty_ind =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id == 0 and x.itemcatname == "F_Noodle"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{sum: a}
      end

    noodle_qty_com =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id != 0 and x.itemcatname == "F_Noodle"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{sum: a}
      end

    rice_qty_ind =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id == 0 and x.itemcatname == "F_Rice"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{sum: a}
      end

    rice_qty_com =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id != 0 and x.itemcatname == "F_Rice"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{month: item, sum: a}
      end

    sidedish_qty_ind =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id == 0 and x.itemcatname == "F_SideDish"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{month: item, sum: a}
      end

    sidedish_qty_com =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id != 0 and x.itemcatname == "F_SideDish"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{month: item, sum: a}
      end

    toppings_qty_ind =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id == 0 and x.itemcatname == "Toppings"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{month: item, sum: a}
      end

    toppings_qty_com =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x ->
            x.date.month == item and x.combo_id != 0 and x.itemcatname == "Toppings"
          end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{month: item, sum: a}
      end

    grand_total =
      for item <- date_data1 do
        item = String.to_integer(item)

        a =
          Enum.filter(try1, fn x -> x.date.month == item end)
          |> Enum.map(fn x -> x.total end)
          |> Enum.sum()

        %{month: item, sum: a}
      end

    count_month = Enum.count(date_data1)

    render(
      conn,
      "create_cv.html",
      count_month: count_month,
      month: month,
      grand_total: grand_total,
      addon_qty_ind: addon_qty_ind,
      beverages_qty_ind: beverages_qty_ind,
      beverages_qty_com: beverages_qty_com,
      breakfast_qty_ind: breakfast_qty_ind,
      breakfast_qty_com: breakfast_qty_com,
      noodle_qty_ind: noodle_qty_ind,
      noodle_qty_com: noodle_qty_com,
      rice_qty_ind: rice_qty_ind,
      rice_qty_com: rice_qty_com,
      sidedish_qty_ind: sidedish_qty_ind,
      sidedish_qty_com: sidedish_qty_com,
      toppings_qty_ind: toppings_qty_ind,
      toppings_qty_com: toppings_qty_com
    )
  end

  def item_sales_report_csv(conn, params) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"Item Sales Report.csv\"")
    |> send_resp(200, item_sales_report_csv_content(conn, params))
  end

  defp item_sales_report_csv_content(conn, params) do
    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    start_date = params["start_date"]
    end_date = params["end_date"]

    item_sold_data =
      if branch_id != "0" do
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: sd.itemid == i.subcatid,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: ic in BoatNoodle.BN.ItemCat,
            on: ic.itemcatid == i.itemcatid,
            group_by: sd.itemid,
            where:
              sd.order_price > 0 and s.is_void == 0 and sd.is_void == 0 and
                s.branchid == ^branch_id and s.salesdate >= ^start_date and
                s.salesdate <= ^end_date and i.brand_id == ^brand.id and s.brand_id == ^brand.id and
                ic.brand_id == ^brand.id,
            select: %{
              itemcode: i.itemcode,
              itemname: sd.itemname,
              itemid: sd.itemid,
              itemcatname: ic.itemcatname,
              qty: sum(sd.qty),
              nett_price: sum(sd.afterdisc),
              gross_price: sum(sd.order_price)
            }
          )
        )
      else
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: sd.itemid == i.subcatid,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: ic in BoatNoodle.BN.ItemCat,
            on: ic.itemcatid == i.itemcatid,
            group_by: sd.itemid,
            where:
              sd.order_price > 0 and s.is_void == 0 and sd.is_void == 0 and
                s.salesdate >= ^start_date and s.salesdate <= ^end_date and
                i.brand_id == ^brand.id and s.brand_id == ^brand.id and ic.brand_id == ^brand.id,
            select: %{
              itemcode: i.itemcode,
              itemname: sd.itemname,
              itemid: sd.itemid,
              itemcatname: ic.itemcatname,
              qty: sum(sd.qty),
              nett_price: sum(sd.afterdisc),
              gross_price: sum(sd.order_price)
            }
          )
        )
      end

    csv_content = ['Item Code ', 'Item Name', 'Category', 'Quantity', 'Net Sales', 'Gross Sales']

    data =
      for item <- item_sold_data do
        [
          item.itemcode,
          item.itemname,
          item.itemcatname,
          Decimal.to_string(item.qty),
          Decimal.to_string(item.nett_price),
          Decimal.to_string(item.gross_price)
        ]
      end

    qty =
      Enum.map(item_sold_data, fn x -> Decimal.to_float(x.qty) end)
      |> Enum.reject(fn x -> x == 0 end)
      |> Enum.sum()

    qty =
      if qty == 0 do
        0
      else
        qty
        |> Float.round(2)
        |> Float.to_string()
      end

    nett_price =
      Enum.map(item_sold_data, fn x -> Decimal.to_float(x.nett_price) end)
      |> Enum.sum()

    nett_price =
      if nett_price == 0 do
        0
      else
        nett_price
        |> Float.round(2)
        |> Float.to_string()
      end

    gross_price =
      Enum.map(item_sold_data, fn x -> Decimal.to_float(x.gross_price) end)
      |> Enum.sum()

    gross_price =
      if gross_price == 0 do
        0
      else
        gross_price
        |> Float.round(2)
        |> Float.to_string()
      end

    a = "Total"
    b = ""
    c = ""
    bottem = ['Total', '-', '-', qty, nett_price, gross_price]
    csv_content2 = List.insert_at(data, 0, csv_content)

    final =
      List.insert_at(csv_content2, -1, bottem)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end

  def combo_item_report_csv(conn, params) do
    csv_header = [
      [
        'Date',
        'Outlet',
        'Hieracachy',
        'Category',
        'Item Code',
        'Item Name',
        'Combo Name',
        'Item ID',
        'Gross Quantity',
        'Nett Quantity',
        'FOC Quantity',
        'Gross Sales',
        'Nett Sales',
        'Unit Price',
        'Discount Value',
        'Service Charge',
        'Store Owner'
      ]
    ]

    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    start_date = params["start_date"]
    end_date = params["end_date"]

    item_sales_outlet =
      if branch_id != "0" do
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            group_by: [s.salesdate, b.branchname, sd.itemid],
            where:
              s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.brand_id == ^brand.id and
                b.brand_id == ^brand.id and s.is_void == ^0 and sd.combo_id != 0 and
                sd.is_void == ^0 and s.branchid == ^branch_id,
            select: %{
              salesdate: s.salesdate,
              branchname: b.branchname,
              itemcode: sd.itemcode,
              itemname: sd.itemname,
              itemid: sd.itemid,
              gross_qty: sum(sd.qty),
              gross_sales: sum(sd.order_price),
              nett_sales: sum(sd.afterdisc),
              unit_price: sd.unit_price,
              store_owner: b.manager,
              combo_id: sd.combo_id
            }
          )
        )
      else
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            left_join: st in BoatNoodle.BN.Staff,
            on: st.staff_id == b.manager,
            group_by: [s.salesdate, b.branchname, sd.itemid],
            where:
              s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.brand_id == ^brand.id and
                b.brand_id == ^brand.id and s.is_void == ^0 and sd.combo_id != 0 and
                sd.is_void == ^0,
            select: %{
              salesdate: s.salesdate,
              branchname: b.branchname,
              itemcode: sd.itemcode,
              itemname: sd.itemname,
              itemid: sd.itemid,
              gross_qty: sum(sd.qty),
              gross_sales: sum(sd.order_price),
              nett_sales: sum(sd.afterdisc),
              unit_price: sd.unit_price,
              store_owner: b.manager,
              combo_id: sd.combo_id
            }
          )
        )
      end
      |> Enum.reject(fn x -> String.length(Integer.to_string(x.itemid)) == 6 end)

    subcat_data =
      Repo.all(
        from(
          is in ItemSubcat,
          left_join: ic in ItemCat,
          on: ic.itemcatid == is.itemcatid,
          where: is.brand_id == ^brand.id and ic.brand_id == ^brand.id,
          select: %{
            category_type: ic.category_type,
            subcatid: is.subcatid,
            category_name: ic.itemcatname,
            itemcode: is.itemcode,
            itemname: is.itemname
          }
        )
      )

    combo_data =
      Repo.all(
        from(
          cd in ComboDetails,
          left_join: is in ItemSubcat,
          on: is.itemcode == cd.combo_item_code,
          left_join: ic in ItemCat,
          on: ic.itemcatid == is.itemcatid,
          where:
            cd.brand_id == ^brand.id and is.brand_id == ^brand.id and ic.brand_id == ^brand.id,
          select: %{
            combo_id: cd.combo_id,
            itemid: cd.combo_item_id,
            itemcode: cd.combo_item_code,
            category_type: ic.category_type,
            category_name: ic.itemcatname,
            unit_price: cd.unit_price,
            top_up: cd.top_up
          }
        )
      )

    staffs =
      Repo.all(
        from(
          cd in Staff,
          where: cd.brand_id == ^brand.id,
          select: %{
            staff_id: cd.staff_id,
            staff_name: cd.staff_name
          }
        )
      )

    combo_data_price =
      Repo.all(
        from(
          cd in ComboDetails,
          where: cd.brand_id == ^brand.id,
          select: %{
            itemid: cd.combo_item_id,
            unit_price: cd.unit_price,
            top_up: cd.top_up
          }
        )
      )

    name =
      if branch_id != "0" do
        b = Repo.get_by(Branch, brand_id: brand.id, branchid: branch_id)
        b.branchname
      else
        "ALL"
      end

    item_sales_outlet
    |> Stream.map(fn x ->
      combo_item_report_csv_content(
        x,
        conn,
        params,
        staffs,
        brand,
        subcat_data,
        combo_data,
        combo_data_price
      )
    end)
    |> (fn stream -> Stream.concat(csv_header, stream) end).()
    |> CSV.encode()
    |> Enum.into(
      conn
      |> put_resp_content_type("application/csv")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"Combo Sales Report - #{name}.csv\""
      )
      |> send_chunked(200)
    )
  end

  defp combo_item_report_csv_content(
         item,
         conn,
         params,
         staffs,
         brand,
         subcat_data,
         combo_data,
         combo_data_price
       ) do
    discount_value = Decimal.to_float(item.gross_sales) - Decimal.to_float(item.nett_sales)
    up = unit_price(item.unit_price, item.itemid, item.combo_id, combo_data_price)
    foc = foc_qty(discount_value, up)
    gs = gross_sales(item.gross_sales, item.gross_qty, item.itemid, subcat_data, combo_data_price)
    nett_sales = nett_sales(gs, discount_value)

    service_charge =
      if brand.id == 8 do
        0.00
      else
        :erlang.float_to_binary(nett_sales(gs, discount_value) * 0.1, decimals: 2)
      end

    [
      item.salesdate,
      item.branchname,
      hierachy(item.itemid, subcat_data, combo_data),
      category(item.itemid, subcat_data, combo_data),
      itemcode(item.itemid, item.itemcode, item.combo_id, subcat_data, combo_data),
      item.itemname,
      combo_name(item.itemid, item.combo_id, subcat_data, combo_data),
      item.itemid,
      item.gross_qty,
      nett_qty(item.gross_qty, foc),
      foc,
      gs,
      nett_sales,
      up,
      discount_value |> :erlang.float_to_binary(decimals: 2),
      service_charge,
      manager(item.store_owner, staffs)
    ]
  end

  def item_sales_outlet_csv(conn, params) do
    csv_header = [
      [
        'Date',
        'Outlet',
        'Hieracachy',
        'Category',
        'Item Code',
        'Item Name',
        'Item ID',
        'Gross Quantity',
        'Nett Quantity',
        'FOC Quantity',
        'Gross Sales',
        'Nett Sales',
        'Unit Price',
        'Discount Value',
        'Service Charge',
        'Store Owner',
        'Combo'
      ]
    ]

    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    start_date = params["start_date"]
    end_date = params["end_date"]

    item_sales_outlet =
      if branch_id != "0" do
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            group_by: [s.salesdate, b.branchname, sd.itemid],
            where:
              s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.brand_id == ^brand.id and
                b.brand_id == ^brand.id and s.is_void == ^0 and sd.is_void == ^0 and
                s.branchid == ^branch_id,
            select: %{
              salesdate: s.salesdate,
              branchname: b.branchname,
              itemcode: sd.itemcode,
              itemname: sd.itemname,
              itemid: sd.itemid,
              gross_qty: sum(sd.qty),
              gross_sales: sum(sd.order_price),
              nett_sales: sum(sd.afterdisc),
              unit_price: sd.unit_price,
              store_owner: b.manager,
              combo_id: sd.combo_id
            }
          )
        )
      else
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            group_by: [s.salesdate, b.branchname, sd.itemid],
            where:
              s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.brand_id == ^brand.id and
                b.brand_id == ^brand.id and s.is_void == ^0 and sd.is_void == ^0,
            select: %{
              salesdate: s.salesdate,
              branchname: b.branchname,
              itemcode: sd.itemcode,
              itemname: sd.itemname,
              itemid: sd.itemid,
              gross_qty: sum(sd.qty),
              gross_sales: sum(sd.order_price),
              nett_sales: sum(sd.afterdisc),
              unit_price: sd.unit_price,
              store_owner: b.manager,
              combo_id: sd.combo_id
            }
          )
        )
      end
      |> Enum.reject(fn x -> String.length(Integer.to_string(x.itemid)) == 6 end)

    subcat_data =
      Repo.all(
        from(
          is in ItemSubcat,
          left_join: ic in ItemCat,
          on: ic.itemcatid == is.itemcatid,
          where:
            is.brand_id == ^brand.id and ic.brand_id == ^brand.id and ic.is_delete == ^0 and
              is.is_delete == ^0,
          select: %{
            category_type: ic.category_type,
            subcatid: is.subcatid,
            category_name: ic.itemcatname,
            itemcode: is.itemcode,
            itemname: is.itemname
          }
        )
      )

    combo_data =
      Repo.all(
        from(
          cd in ComboDetails,
          left_join: is in ItemSubcat,
          on: is.itemcode == cd.combo_item_code,
          left_join: ic in ItemCat,
          on: ic.itemcatid == is.itemcatid,
          where:
            cd.brand_id == ^brand.id and is.brand_id == ^brand.id and ic.brand_id == ^brand.id and
              ic.is_delete == ^0 and is.is_delete == ^0,
          select: %{
            combo_id: cd.combo_id,
            itemid: cd.combo_item_id,
            itemcode: cd.combo_item_code,
            category_type: ic.category_type,
            category_name: ic.itemcatname,
            unit_price: cd.unit_price,
            top_up: cd.top_up
          }
        )
      )

    staffs =
      Repo.all(
        from(
          cd in Staff,
          where: cd.brand_id == ^brand.id,
          select: %{
            staff_id: cd.staff_id,
            staff_name: cd.staff_name
          }
        )
      )

    combo_data_price =
      Repo.all(
        from(
          cd in ComboDetails,
          where: cd.brand_id == ^brand.id,
          select: %{
            itemid: cd.combo_item_id,
            unit_price: cd.unit_price,
            top_up: cd.top_up
          }
        )
      )

    name =
      if branch_id != "0" do
        b = Repo.get_by(Branch, brand_id: brand.id, branchid: branch_id)
        b.branchname
      else
        "ALL"
      end

    item_sales_outlet
    |> Stream.map(fn x ->
      item_sales_outlet_csv_content(
        x,
        conn,
        params,
        staffs,
        brand,
        subcat_data,
        combo_data,
        combo_data_price
      )
    end)
    |> (fn stream -> Stream.concat(csv_header, stream) end).()
    |> CSV.encode()
    |> Enum.into(
      conn
      |> put_resp_content_type("application/csv")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"Item Outlet Sales Report - #{name}.csv\""
      )
      |> send_chunked(200)
    )
  end

  def item_sales_outlet_csv_v2(conn, params) do
    csv_header = [
      [
        'Date',
        'Outlet',
        'Hieracachy',
        'Category',
        'Item Code',
        'Item Name',
        'Item ID',
        'Gross Quantity',
        'Nett Quantity',
        'FOC Quantity',
        'Gross Sales',
        'Nett Sales',
        'Unit Price',
        'Discount Value',
        'Service Charge',
        'Store Owner',
        'Combo'
      ]
    ]

    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    start_date = params["start_date"]
    end_date = params["end_date"]

    branch = Repo.get_by(Branch, branchid: branch_id, brand_id: brand.id)

    item_sales_outlet =
      if branch_id != "0" do
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            group_by: [sd.salesdate, sd.branchname, sd.itemid],
            where:
              sd.salesdate >= ^start_date and sd.salesdate <= ^end_date and
                sd.brand_id == ^brand.id and sd.is_void == ^0 and
                sd.branchname == ^branch.branchname,
            select: %{
              salesdate: sd.salesdate,
              branchname: sd.branchname,
              itemcode: sd.itemcode,
              hierachy: sd.cat_type,
              category: sd.cat_name,
              itemcode: sd.itemcode,
              itemname: sd.itemname,
              itemid: sd.itemid,
              qty: sum(sd.qty),
              order_price: sum(sd.order_price),
              final_nett_sales: sum(sd.final_nett_sales),
              combo_total_topup_qty: sum(sd.combo_total_topup_qty),
              foc_qty: sum(sd.foc_qty),
              discount_value: sum(sd.discount_value),
              service_charge: sum(sd.service_charge),
              nett_sales: sum(sd.afterdisc),
              unit_price: sd.unit_price,
              store_owner: sd.staffname,
              combo_name: sd.combo_name
            }
          )
        )
      else
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            group_by: [sd.salesdate, sd.branchname, sd.itemid],
            where:
              sd.salesdate >= ^start_date and sd.salesdate <= ^end_date and
                sd.brand_id == ^brand.id and sd.is_void == 0,
            select: %{
              salesdate: sd.salesdate,
              branchname: sd.branchname,
              itemcode: sd.itemcode,
              hierachy: sd.cat_type,
              category: sd.cat_name,
              itemcode: sd.itemcode,
              itemname: sd.itemname,
              itemid: sd.itemid,
              qty: sum(sd.qty),
              order_price: sum(sd.order_price),
              final_nett_sales: sum(sd.final_nett_sales),
              combo_total_topup_qty: sum(sd.combo_total_topup_qty),
              foc_qty: sum(sd.foc_qty),
              discount_value: sum(sd.discount_value),
              service_charge: sum(sd.service_charge),
              nett_sales: sum(sd.afterdisc),
              unit_price: sd.unit_price,
              store_owner: sd.staffname,
              combo_name: sd.combo_name
            }
          )
        )
      end

    name =
      if branch_id != "0" do
        b = Repo.get_by(Branch, brand_id: brand.id, branchid: branch_id)
        b.branchname
      else
        "ALL"
      end

    item_sales_outlet
    |> Stream.map(fn x ->
      item_sales_outlet_csv_content_v2(x, conn, params, brand)
    end)
    |> (fn stream -> Stream.concat(csv_header, stream) end).()
    |> CSV.encode()
    |> Enum.into(
      conn
      |> put_resp_content_type("application/csv")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"Item Outlet Sales Report - #{name}.csv\""
      )
      |> send_chunked(200)
    )
  end

  defp item_sales_outlet_csv_content_v2(
         item,
         conn,
         params,
         brand
       ) do
    item_qty =
      if item.qty == nil do
        0
      else
        item.qty
      end

    item_foc =
      if item.foc_qty == nil do
        0
      else
        item.foc_qty
      end

    IO.inspect(item_qty)
    IO.inspect(item_foc)

    item_qty =
      if Decimal.decimal?(item_qty) do
        Decimal.to_float(item_qty)
      else
        item_qty
      end

    item_foc =
      if Decimal.decimal?(item_foc) do
        Decimal.to_float(item_foc)
      else
        item_foc
      end

    nett_qty = item_qty - item_foc

    [
      item.salesdate,
      item.branchname,
      item.hierachy,
      item.category,
      item.itemcode,
      item.itemname,
      item.itemid,
      item.qty,
      nett_qty,
      item.foc_qty,
      item.final_nett_sales,
      item.nett_sales,
      item.unit_price,
      item.discount_value,
      item.service_charge,
      item.store_owner,
      item.combo_name
    ]
  end

  defp item_sales_outlet_csv_content(
         item,
         conn,
         params,
         staffs,
         brand,
         subcat_data,
         combo_data,
         combo_data_price
       ) do
    discount_value = Decimal.to_float(item.gross_sales) - Decimal.to_float(item.nett_sales)
    up = unit_price(item.unit_price, item.itemid, item.combo_id, combo_data_price)
    foc = foc_qty(discount_value, up)
    gs = gross_sales(item.gross_sales, item.gross_qty, item.itemid, subcat_data, combo_data_price)

    service_charge =
      if brand.id == 8 do
        0.00
      else
        :erlang.float_to_binary(nett_sales(gs, discount_value) * 0.1, decimals: 2)
      end

    [
      item.salesdate,
      item.branchname,
      hierachy(item.itemid, subcat_data, combo_data),
      category(item.itemid, subcat_data, combo_data),
      itemcode(item.itemid, item.itemcode, item.combo_id, subcat_data, combo_data),
      item.itemname,
      item.itemid,
      item.gross_qty,
      nett_qty(item.gross_qty, foc),
      foc,
      gs,
      nett_sales(gs, discount_value),
      up,
      discount_value |> :erlang.float_to_binary(decimals: 2),
      service_charge,
      manager(item.store_owner, staffs),
      combo_name(item.itemid, item.combo_id, subcat_data, combo_data)
    ]
  end

  def combo_name(itemid, combo_id, subcat_data, combo_data) do
    # a = subcat_data |> Enum.filter(fn x -> x.subcatid == combo_id end)
    # if a != [] do
    #   hd(a).itemname
    # else
    #   IEx.pry
    #   "Ala Carte"
    # end

    if String.length(Integer.to_string(itemid)) > 5 do
      a = subcat_data |> Enum.filter(fn x -> x.subcatid == combo_id end)

      if a != [] do
        hd(a).itemname
      else
        b = subcat_data |> Enum.filter(fn x -> x.subcatid == itemid end)

        c =
          if b != [] do
            hd(b).category_type
          else
            "Empty"
          end

        c
      end
    else
      "Ala Carte"
    end
  end

  def manager(store_owner, staffs) do
    a = staffs |> Enum.filter(fn x -> x.staff_id == store_owner end)

    if a != [] do
      hd(a).staff_name
    else
      "Unknown Manager"
    end
  end

  def hierachy(itemid, subcat_data, combo_data) do
    if String.length(Integer.to_string(itemid)) > 5 do
      a = subcat_data |> Enum.filter(fn x -> x.subcatid == itemid end)

      if a != [] do
        hd(a).category_type
      else
        b = combo_data |> Enum.filter(fn x -> x.itemid == itemid end)

        c =
          if b != [] do
            hd(b).category_type
          else
            "Empty"
          end

        c
      end
    else
      a = subcat_data |> Enum.filter(fn x -> x.subcatid == itemid end)

      if a != [] do
        hd(a).category_type
      else
        "Empty"
      end
    end
  end

  def category(itemid, subcat_data, combo_data) do
    if String.length(Integer.to_string(itemid)) > 5 do
      a = subcat_data |> Enum.filter(fn x -> x.subcatid == itemid end)

      if a != [] do
        hd(a).category_name
      else
        b = combo_data |> Enum.filter(fn x -> x.itemid == itemid end)

        c =
          if b != [] do
            hd(b).category_name
          else
            "Empty"
          end

        c
      end
    else
      a = subcat_data |> Enum.filter(fn x -> x.subcatid == itemid end)

      if a != [] do
        hd(a).category_name
      else
        "Empty"
      end
    end
  end

  def itemcode(itemid, itemcode, combo_id, subcat_data, combo_data) do
    if String.length(Integer.to_string(itemid)) > 5 do
      a = subcat_data |> Enum.filter(fn x -> x.subcatid == itemid end)

      if a != [] do
        hd(a).itemcode
      else
        b = combo_data |> Enum.filter(fn x -> x.itemid == itemid end)

        c =
          if b != [] do
            hd(b).itemcode
          else
            "Empty"
          end

        c
      end
    else
      a = subcat_data |> Enum.filter(fn x -> x.subcatid == itemid end)

      if a != [] do
        hd(a).itemcode
      else
        "Empty"
      end
    end
  end

  def foc_qty(discount_value, up) do
    cond do
      up == Decimal.new("0.00") ->
        0

      Decimal.decimal?(up) ->
        # IO.inspect(discount_value)
        # IO.inspect(up)
        Float.round(discount_value / Decimal.to_float(up))

      up = "0.00" ->
        0

      true ->
        Float.round(discount_value / String.to_float(up))
    end
  end

  def nett_qty(gross_qty, foc) do
    Decimal.to_float(gross_qty) - foc
  end

  def nett_sales(gs, discount_value) do
    if Decimal.decimal?(gs) do
      Decimal.to_float(gs) - discount_value
    else
      gs - discount_value
    end
  end

  def gross_sales(gross_sales, qty, itemid, subcat_data, combo_data) do
    if String.length(Integer.to_string(itemid)) == 9 do
      data = combo_data |> Enum.filter(fn x -> x.itemid == itemid end) |> Enum.uniq()

      if data != [] do
        unit_price = hd(data).unit_price |> Decimal.to_float()
        top_up = hd(data).top_up |> Decimal.to_float()

        if Decimal.to_float(gross_sales) != (qty |> Decimal.to_float()) * top_up do
          # IEx.pry()
          Decimal.to_float(qty) * unit_price + Decimal.to_float(gross_sales)
        else
          Decimal.to_float(qty) * (unit_price + top_up)
        end
      else
        0
      end
    else
      Decimal.to_float(gross_sales)
    end
  end

  def unit_price(unit_price, item_id, combo_id, combo_data) do
    if String.length(Integer.to_string(item_id)) == 9 do
      data = combo_data |> Enum.filter(fn x -> x.itemid == item_id end) |> Enum.uniq()

      if data != [] do
        unit_price = hd(data).unit_price |> Decimal.to_float()
        top_up = hd(data).top_up |> Decimal.to_float()

        res = unit_price + top_up
        :erlang.float_to_binary(res, decimals: 2)
      else
        "0"
      end
    else
      unit_price
    end
  end

  def item_transaction_report(conn, params) do
    Task.start_link(__MODULE__, :item_transaction_report_save_file, [conn, params])

    # |> Enum.into(
    #   conn
    #   |> put_resp_content_type("application/csv")
    #   |> put_resp_header(
    #     "content-disposition",
    #     "attachment; filename=\"Item Transaction Report- #{name}.csv\""
    #   )
    #   |> send_chunked(200)
    # )

    conn
    |> put_flash(:info, "Item Sales Transaction Report is being prepared...")
    |> redirect(to: sales_path(conn, :item_sales, BN.get_domain(conn)))
  end

  def item_transaction_report_save_file(conn, params) do
    csv_header = [
      [
        'BILL DATE',
        'BILL TIME',
        'INVOICE NO',
        'ITEM NAME',
        'QTY',
        'GROSS AMT',
        'NETT AMT',
        'BRANCH NAME',
        'PAYMENT TYPE',
        'PAYMENT TYPE NAME',
        'PAYMENT TYPE ID 1',
        'PAYMENT CODE 1'
      ]
    ]

    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    start_date = params["start_date"]
    end_date = params["end_date"]

    item_transaction_report =
      if branch_id != "0" do
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: s.salesid == sp.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.brand_id == ^brand.id and
                b.brand_id == ^brand.id and s.is_void == ^0 and sd.is_void == ^0 and
                s.branchid == ^branch_id and sp.brand_id == ^brand.id,
            select: %{
              salesdate: s.salesdate,
              salesdatetime: s.salesdatetime,
              invoiceno: s.invoiceno,
              itemname: sd.itemname,
              qty: sd.qty,
              gross_amt: sd.order_price,
              nett_amt: sd.afterdisc,
              branchname: b.branchname,
              payment_type: sp.payment_type,
              payment_name1: sp.payment_name1,
              payment_type_id1: sp.payment_type_id1,
              payment_code1: sp.payment_code1
            },
            order_by: s.salesdatetime
          )
        )
      else
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: s.salesid == sp.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.brand_id == ^brand.id and
                b.brand_id == ^brand.id and s.is_void == ^0 and sd.is_void == ^0 and
                sp.brand_id == ^brand.id,
            select: %{
              salesdate: s.salesdate,
              salesdatetime: s.salesdatetime,
              invoiceno: s.invoiceno,
              itemname: sd.itemname,
              qty: sd.qty,
              gross_amt: sd.order_price,
              nett_amt: sd.afterdisc,
              branchname: b.branchname,
              payment_type: sp.payment_type,
              payment_name1: sp.payment_name1,
              payment_type_id1: sp.payment_type_id1,
              payment_code1: sp.payment_code1
            },
            order_by: s.salesdatetime
          )
        )
      end

    name =
      if branch_id != "0" do
        b = Repo.get_by(Branch, brand_id: brand.id, branchid: branch_id)
        b.branchname
      else
        "ALL"
      end

    a =
      item_transaction_report
      |> Stream.map(fn x ->
        item_transaction_report_csv(x, conn, params)
      end)
      |> (fn stream -> Stream.concat(csv_header, stream) end).()
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    # csv_content2 =
    #   List.insert_at(data, 0, csv_content)
    #   |> CSV.encode()
    #   |> Enum.to_list()
    #   |> to_string
    image_path = Application.app_dir(:boat_noodle, "priv/static/images")

    new_path = image_path <> "/item_transaction_report_#{name}_#{start_date}_#{end_date}.csv"

    if File.exists?(new_path) do
      file =
        Repo.get_by(
          BoatNoodle.BN.Report,
          filename: "item_transaction_report_#{name}_#{start_date}_#{end_date}.csv",
          brand_id: brand.id,
          branch_id: String.to_integer(branch_id)
        )

      case BoatNoodle.BN.Report.changeset(file, %{updated_at: DateTime.utc_now()})
           |> Repo.update() do
        {:ok, file} ->
          true

        {:error, cg} ->
          IO.inspect(cg)
      end
    else
      BoatNoodle.BN.Report.changeset(%BoatNoodle.BN.Report{}, %{
        filename: "item_transaction_report_#{name}_#{start_date}_#{end_date}.csv",
        url_path: new_path,
        brand_id: brand.id,
        branch_id: String.to_integer(branch_id)
      })
      |> Repo.insert()
    end

    File.write(new_path, a)
  end

  defp item_transaction_report_csv(
         item,
         conn,
         params
       ) do
    [
      item.salesdate,
      DateTime.from_naive!(item.salesdatetime, "Etc/UTC")
      |> DateTime.to_string()
      |> String.split_at(19)
      |> elem(0),
      item.invoiceno,
      item.itemname,
      item.qty,
      item.gross_amt,
      item.nett_amt,
      item.branchname,
      item.payment_type,
      item.payment_name1,
      item.payment_type_id1,
      item.payment_code1
    ]
  end

  def item_sales_outlet_csv2(conn, params) do
    csv_header = [
      [
        'Date',
        'Outlet',
        'Hieracachy',
        'Category',
        'Item Code',
        'Item Name',
        'Gross Quantity',
        'Nett Quantity',
        'FOC Quantity',
        'Gross Sales',
        'Nett Sales',
        'Unit Price',
        'Discount Value',
        'Service Charge',
        'Store Owner',
        'Combo'
      ]
    ]

    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    start_date = params["start_date"]
    end_date = params["end_date"]

    item_sales_outlet =
      if branch_id != "0" do
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            group_by: [s.salesdate, b.branchname, sd.itemid],
            where:
              s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.brand_id == ^brand.id and
                b.brand_id == ^brand.id and s.is_void == ^0 and sd.is_void == ^0 and
                s.branchid == ^branch_id,
            select: %{
              salesdate: s.salesdate,
              branchname: b.branchname,
              itemcode: sd.itemcode,
              itemname: sd.itemname,
              itemid: sd.itemid,
              gross_qty: sum(sd.qty),
              gross_sales: sum(sd.order_price),
              nett_sales: sum(sd.afterdisc),
              unit_price: sd.unit_price,
              store_owner: b.manager,
              combo_id: sd.combo_id
            }
          )
        )
      else
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            group_by: [s.salesdate, b.branchname, sd.itemid],
            where:
              s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.brand_id == ^brand.id and
                b.brand_id == ^brand.id and s.is_void == ^0 and sd.is_void == ^0,
            select: %{
              salesdate: s.salesdate,
              branchname: b.branchname,
              itemcode: sd.itemcode,
              itemname: sd.itemname,
              itemid: sd.itemid,
              gross_qty: sum(sd.qty),
              gross_sales: sum(sd.order_price),
              nett_sales: sum(sd.afterdisc),
              unit_price: sd.unit_price,
              store_owner: b.manager,
              combo_id: sd.combo_id
            }
          )
        )
      end

    subcat_data =
      Repo.all(
        from(
          is in ItemSubcat,
          left_join: ic in ItemCat,
          on: ic.itemcatid == is.itemcatid,
          where: is.brand_id == ^brand.id and ic.brand_id == ^brand.id,
          select: %{
            category_type: ic.category_type,
            subcatid: is.subcatid,
            category_name: ic.itemcatname,
            itemcode: is.itemcode,
            itemname: is.itemname
          }
        )
      )

    combo_data =
      Repo.all(
        from(
          cd in ComboDetails,
          left_join: is in ItemSubcat,
          on: is.itemcode == cd.combo_item_code,
          left_join: ic in ItemCat,
          on: ic.itemcatid == is.itemcatid,
          where:
            cd.brand_id == ^brand.id and is.brand_id == ^brand.id and ic.brand_id == ^brand.id,
          select: %{
            combo_id: cd.combo_id,
            itemid: cd.combo_item_id,
            itemcode: cd.combo_item_code,
            category_type: ic.category_type,
            category_name: ic.itemcatname,
            unit_price: cd.unit_price,
            top_up: cd.top_up
          }
        )
      )

    staffs =
      Repo.all(
        from(
          cd in Staff,
          where: cd.brand_id == ^brand.id,
          select: %{
            staff_id: cd.staff_id,
            staff_name: cd.staff_name
          }
        )
      )

    combo_data_price =
      Repo.all(
        from(
          cd in ComboDetails,
          where: cd.brand_id == ^brand.id,
          select: %{
            itemid: cd.combo_item_id,
            unit_price: cd.unit_price,
            top_up: cd.top_up
          }
        )
      )

    name =
      if branch_id != "0" do
        b = Repo.get_by(Branch, brand_id: brand.id, branchid: branch_id)
        b.branchname
      else
        "ALL"
      end

    item_sales_outlet
    |> Stream.map(fn x ->
      item_sales_outlet_csv_content2(
        x,
        conn,
        params,
        staffs,
        brand,
        subcat_data,
        combo_data,
        combo_data_price
      )
    end)
    |> (fn stream -> Stream.concat(csv_header, stream) end).()
    |> CSV.encode()
    |> Enum.into(
      conn
      |> put_resp_content_type("application/csv")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"Item Outlet Sales Report with Combo Summary - #{name}.csv\""
      )
      |> send_chunked(200)
    )
  end

  defp item_sales_outlet_csv_content2(
         item,
         conn,
         params,
         staffs,
         brand,
         subcat_data,
         combo_data,
         combo_data_price
       ) do
    discount_value = Decimal.to_float(item.gross_sales) - Decimal.to_float(item.nett_sales)

    service_charge =
      if brand.id == 8 do
        0.00
      else
        (Decimal.to_float(item.nett_sales) / 10) |> Float.round(2)
      end

    foc = foc_qty(discount_value, item.unit_price)

    [
      item.salesdate,
      item.branchname,
      hierachy(item.itemid, subcat_data, combo_data),
      category(item.itemid, subcat_data, combo_data),
      itemcode(item.itemid, item.itemcode, item.combo_id, subcat_data, combo_data),
      item.itemname,
      item.gross_qty,
      nett_qty(item.gross_qty, foc),
      foc,
      Decimal.to_float(item.gross_sales) |> :erlang.float_to_binary(decimals: 2),
      Decimal.to_float(item.nett_sales) |> :erlang.float_to_binary(decimals: 2),
      Decimal.to_float(item.unit_price) |> :erlang.float_to_binary(decimals: 2),
      discount_value |> :erlang.float_to_binary(decimals: 2),
      service_charge |> :erlang.float_to_binary(decimals: 2),
      manager(item.store_owner, staffs),
      combo_name(item.itemid, item.combo_id, subcat_data, combo_data)
    ]
  end

  def combo_item_sales_csv(conn, params) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"Combo Item Sales Report.csv\""
    )
    |> send_resp(200, combo_item_sales_csv_content(conn, params))
  end

  defp combo_item_sales_csv_content(conn, params) do
    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    start_date = params["start_date"]
    end_date = params["end_date"]

    item_sales_outlet =
      if branch_id != "0" do
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sd in BoatNoodle.BN.SalesMaster,
            on: s.salesid == sd.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            left_join: cd in BoatNoodle.BN.ComboDetails,
            on: cd.combo_item_id == sd.itemid,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: cd.combo_id == i.subcatid,
            left_join: ic in BoatNoodle.BN.ItemCat,
            on: ic.itemcatid == cd.menu_cat_id,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: di.discountitemsid == sd.discountid,
            left_join: st in BoatNoodle.BN.Staff,
            on: st.staff_id == b.manager,
            group_by: [s.salesdate, s.branchid, sd.itemid],
            where:
              s.is_void == 0 and s.branchid == ^branch_id and s.salesdate >= ^start_date and
                s.salesdate <= ^end_date and s.brand_id == ^brand.id and sd.brand_id == ^brand.id and
                b.brand_id == ^brand.id and cd.brand_id == ^brand.id and i.brand_id == ^brand.id and
                ic.brand_id == ^brand.id and di.brand_id == ^brand.id and st.brand_id == ^brand.id,
            select: %{
              salesdate: s.salesdate,
              branchname: b.branchname,
              hierachy: ic.category_type,
              category: ic.itemcatname,
              itemcode: i.itemcode,
              comboname: i.itemname,
              itemname: cd.combo_item_name,
              gross_sales: sum(sd.order_price),
              gross_qty: sum(sd.qty),
              foc_qty: sum(di.disc_qty),
              nett_sales: sum(sd.afterdisc),
              unit_price: cd.unit_price,
              store_owner: st.staff_name
            }
          )
        )
      else
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sd in BoatNoodle.BN.SalesMaster,
            on: s.salesid == sd.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            left_join: cd in BoatNoodle.BN.ComboDetails,
            on: cd.combo_item_id == sd.itemid,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: cd.combo_id == i.subcatid,
            left_join: ic in BoatNoodle.BN.ItemCat,
            on: ic.itemcatid == cd.menu_cat_id,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: di.discountitemsid == sd.discountid,
            left_join: st in BoatNoodle.BN.Staff,
            on: st.staff_id == b.manager,
            group_by: [s.salesdate, s.branchid, sd.itemid],
            where:
              s.is_void == 0 and s.salesdate >= ^start_date and s.salesdate <= ^end_date and
                s.brand_id == ^brand.id and sd.brand_id == ^brand.id and b.brand_id == ^brand.id and
                cd.brand_id == ^brand.id and i.brand_id == ^brand.id and ic.brand_id == ^brand.id and
                di.brand_id == ^brand.id and st.brand_id == ^brand.id,
            select: %{
              salesdate: s.salesdate,
              branchname: b.branchname,
              hierachy: ic.category_type,
              category: ic.itemcatname,
              itemcode: i.itemcode,
              comboname: i.itemname,
              itemname: cd.combo_item_name,
              gross_sales: sum(sd.order_price),
              gross_qty: sum(sd.qty),
              foc_qty: sum(di.disc_qty),
              nett_sales: sum(sd.afterdisc),
              unit_price: cd.unit_price,
              store_owner: st.staff_name
            }
          )
        )
      end

    csv_content = [
      'Date ',
      'Outlet',
      'Hieracachy',
      'Category',
      'Item Code',
      'Combo Name',
      'Item Name',
      'Gross Quantity',
      'Nett Quantity',
      'FOC Quantity',
      'Gross Sales',
      'Nett Sales',
      'Unit Price',
      'Discount Value',
      'Service Charge',
      'Store Owner'
    ]

    data =
      for item <- item_sales_outlet do
        foc_qty =
          if item.foc_qty == nil do
            0
          else
            Decimal.to_float(item.foc_qty)
          end

        nett_qty = Decimal.to_float(item.gross_qty) - foc_qty
        discount_value = Decimal.to_float(item.gross_sales) - Decimal.to_float(item.nett_sales)
        service_charge = (Decimal.to_float(item.nett_sales) / 20) |> Float.round(2)

        [
          item.salesdate,
          item.branchname,
          item.hierachy,
          item.category,
          item.itemcode,
          item.comboname,
          item.itemname,
          item.gross_qty,
          nett_qty,
          foc_qty,
          item.gross_sales,
          item.nett_sales,
          item.unit_price,
          discount_value,
          service_charge,
          item.store_owner
        ]
      end

    csv_content2 =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end

  def discount_item_report_csv(conn, params) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"Discount Item Report.csv\"")
    |> send_resp(200, discount_item_report_csv_content(conn, params))
  end

  defp discount_item_report_csv_content(conn, params) do
    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    start_date = params["start_date"]
    end_date = params["end_date"]

    {discount_item_report_csv_content, s} =
      if branch_id != "0" do
        discount_item_report_csv_content =
          Repo.all(
            from(
              sd in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: s.salesid == sd.salesid,
              left_join: di in BoatNoodle.BN.DiscountItem,
              on: sd.discountid == di.discountitemsid,
              left_join: d in BoatNoodle.BN.Discount,
              on: d.discountid == di.discountid,
              left_join: b in BoatNoodle.BN.Branch,
              on: b.branchid == s.branchid,
              group_by: [
                s.salesdate,
                d.discname,
                di.disctype,
                di.discitemsname,
                di.discountitemsid
              ],
              where:
                s.is_void == 0 and sd.discountid != "0" and sd.brand_id == ^brand.id and
                  di.brand_id == ^brand.id and d.brand_id == ^brand.id and s.brand_id == ^brand.id and
                  b.brand_id == ^brand.id and s.branchid == ^branch_id and
                  s.salesdate >= ^start_date and s.salesdate <= ^end_date,
              select: %{
                salesdate: s.salesdate,
                discname: d.discname,
                disctype: di.disctype,
                discitemsname: di.discitemsname,
                discountitemsid: di.discountitemsid,
                qty: count(s.salesid),
                discount_qty: sum(s.salesid),
                grand_total: sum(sd.grand_total),
                sub_total: sum(sd.sub_total),
                service_charge: sum(sd.service_charge),
                gst_charge: sum(sd.gst_charge),
                rounding: sum(sd.rounding)
              }
            )
          )

        s =
          Repo.all(
            from(
              s in BoatNoodle.BN.Sales,
              left_join: sp in BoatNoodle.BN.SalesPayment,
              on: s.salesid == sp.salesid,
              left_join: sm in BoatNoodle.BN.SalesMaster,
              on: s.salesid == sm.salesid,
              left_join: i in BoatNoodle.BN.DiscountItem,
              on: sp.discountid == i.discountitemsid,
              left_join: br in BoatNoodle.BN.Branch,
              on: br.branchid == s.branchid,
              group_by: [s.salesid],
              where:
                s.is_void == 0 and sp.discountid != "0" and s.salesdate >= ^params["start_date"] and
                  s.salesdate <= ^params["end_date"] and s.brand_id == ^brand.id and
                  sp.brand_id == ^brand.id and i.brand_id == ^brand.id and
                  br.brand_id == ^brand.id,
              select: %{
                salesid: s.salesid,
                itemname: sm.itemname,
                itemid: sm.itemid
              }
            )
          )

        {discount_item_report_csv_content, s}
      else
        discount_item_report_csv_content =
          Repo.all(
            from(
              sd in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: s.salesid == sd.salesid,
              left_join: di in BoatNoodle.BN.DiscountItem,
              on: sd.discountid == di.discountitemsid,
              left_join: d in BoatNoodle.BN.Discount,
              on: d.discountid == di.discountid,
              left_join: b in BoatNoodle.BN.Branch,
              on: b.branchid == s.branchid,
              group_by: [
                s.salesdate,
                d.discname,
                di.disctype,
                di.discitemsname,
                di.discountitemsid
              ],
              where:
                s.is_void == 0 and sd.brand_id == ^brand.id and sd.discountid != "0" and
                  di.brand_id == ^brand.id and d.brand_id == ^brand.id and s.brand_id == ^brand.id and
                  b.brand_id == ^brand.id and s.salesdate >= ^start_date and
                  s.salesdate <= ^end_date,
              select: %{
                salesdate: s.salesdate,
                discname: d.discname,
                discitemsname: di.discitemsname,
                qty: count(s.salesid),
                discountitemsid: di.discountitemsid,
                disctype: di.disctype,
                grand_total: sum(sd.grand_total),
                sub_total: sum(sd.sub_total),
                service_charge: sum(sd.service_charge),
                gst_charge: sum(sd.gst_charge),
                rounding: sum(sd.rounding)
              }
            )
          )

        s =
          Repo.all(
            from(
              s in BoatNoodle.BN.Sales,
              left_join: sp in BoatNoodle.BN.SalesPayment,
              on: s.salesid == sp.salesid,
              left_join: sm in BoatNoodle.BN.SalesMaster,
              on: s.salesid == sm.salesid,
              left_join: i in BoatNoodle.BN.DiscountItem,
              on: sp.discountid == i.discountitemsid,
              left_join: br in BoatNoodle.BN.Branch,
              on: br.branchid == s.branchid,
              left_join: g in BoatNoodle.BN.Brand,
              on: g.id == ^brand.id,
              group_by: [s.salesid],
              where:
                s.is_void == 0 and sp.discountid != "0" and s.salesdate >= ^params["start_date"] and
                  s.salesdate <= ^params["end_date"] and s.brand_id == ^brand.id and
                  sp.brand_id == ^brand.id and i.brand_id == ^brand.id and
                  br.brand_id == ^brand.id,
              select: %{
                salesid: s.salesid,
                itemname: sm.itemname,
                itemid: sm.itemid
              }
            )
          )

        {discount_item_report_csv_content, s}
      end

    csv_content = [
      'Date ',
      'Discount Item',
      'Discount Category',
      'Discount Number',
      'Discount Amount'
    ]

    data =
      for item <- discount_item_report_csv_content do
        discount_amount =
          Decimal.to_float(item.grand_total) -
            (Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
               Decimal.to_float(item.gst_charge) + Decimal.to_float(item.rounding))

        [
          item.salesdate,
          item.discitemsname,
          item.discname,
          item.qty,
          discount_amount |> :erlang.float_to_binary(decimals: 2)
        ]
      end

    csv_content2 =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end

  # def discount_item_detail_report_csv(conn, params) do
  #   conn
  #   |> put_resp_content_type("text/csv")
  #   |> put_resp_header(
  #     "content-disposition",
  #     "attachment; filename=\"Discount Item Detail Report.csv\""
  #   )
  #   |> send_resp(200, discount_item_detail_report_csv_content(conn, params))
  # end

  def discount_item_detail_report_csv(conn, params) do
    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    start_date = params["start_date"]
    end_date = params["end_date"]

    discount_item_detail_report_csv =
      if branch_id != "0" do
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sd in BoatNoodle.BN.SalesMaster,
            on: s.salesid == sd.salesid,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: sp.salesid == s.salesid,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: di.discountitemsid == sp.discountid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and sd.is_void == 0 and sp.discountid != "0" and sd.order_price != 0 and
                s.brand_id == ^brand.id and sd.brand_id == ^brand.id and di.brand_id == ^brand.id and
                sp.brand_id == ^brand.id and b.brand_id == ^brand.id and s.branchid == ^branch_id and
                s.salesdate >= ^start_date and s.salesdate <= ^end_date,
            select: %{
              salesdate: s.salesdate,
              invoiceno: s.invoiceno,
              salesid: s.salesid,
              itemcode: sd.itemcode,
              itemname: sd.itemname,
              discitemsname: di.discitemsname,
              disamtpercentage: di.discamtpercentage,
              disctype: di.disctype,
              discountid: di.discountid,
              qty: sd.qty,
              afterdisc: sd.afterdisc,
              itemprice: sd.order_price,
              tbl_no: s.tbl_no,
              staffid: s.staffid,
              branchname: b.branchname,
              branchid: b.branchid,
              voucher_code: sp.voucher_code
            }
          )
        )
      else
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sd in BoatNoodle.BN.SalesMaster,
            on: s.salesid == sd.salesid,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: sp.salesid == s.salesid,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: di.discountitemsid == sp.discountid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and sd.is_void == 0 and sp.discountid != "0" and sd.order_price != 0 and
                s.brand_id == ^brand.id and sd.brand_id == ^brand.id and di.brand_id == ^brand.id and
                sp.brand_id == ^brand.id and b.brand_id == ^brand.id and
                s.salesdate >= ^start_date and s.salesdate <= ^end_date,
            select: %{
              salesdate: s.salesdate,
              invoiceno: s.invoiceno,
              salesid: s.salesid,
              itemcode: sd.itemcode,
              itemname: sd.itemname,
              discitemsname: di.discitemsname,
              disamtpercentage: di.discamtpercentage,
              disctype: di.disctype,
              discountid: di.discountid,
              qty: sd.qty,
              afterdisc: sd.afterdisc,
              itemprice: sd.order_price,
              tbl_no: s.tbl_no,
              staffid: s.staffid,
              branchname: b.branchname,
              branchid: b.branchid,
              voucher_code: sp.voucher_code
            }
          )
        )
      end

    # discount_item =
    #   Repo.all(
    #     from(
    #       di in DiscountItem,
    #       where: di.brand_id == ^brand.id,
    #       select: %{
    #         discountid: di.discountid,
    #         discamtpercentage: di.discamtpercentage,
    #         disctype: di.disctype,
    #         discitemsname: di.discitemsname
    #       }
    #     )
    #   )

    staffs =
      Repo.all(
        from(
          cd in Staff,
          where: cd.brand_id == ^brand.id,
          select: %{
            staff_id: cd.staff_id,
            staff_name: cd.staff_name
          }
        )
      )

    discount =
      Repo.all(
        from(
          d in Discount,
          where: d.brand_id == ^brand.id,
          select: %{
            discountid: d.discountid,
            discname: d.discname
          }
        )
      )

    salesdetail =
      Repo.all(
        from(
          s in Sales,
          left_join: sd in SalesMaster,
          on: s.salesid == sd.salesid,
          where:
            s.is_void == 0 and sd.is_void == 0 and s.brand_id == ^brand.id and sd.order_price != 0 and
              sd.brand_id == ^brand.id and s.salesdate >= ^start_date and s.salesdate <= ^end_date,
          group_by: sd.salesid,
          select: %{
            total: count(sd.salesid),
            salesid: sd.salesid
          }
        )
      )

    name =
      if branch_id != "0" do
        b = Repo.get_by(Branch, brand_id: brand.id, branchid: branch_id)
        b.branchname
      else
        "ALL"
      end

    csv_header = [
      [
        'Date ',
        'Invoice No',
        'Item Code',
        'Item Name',
        'Quantity',
        'Unit Price',
        'Price Before Discount',
        'Discount Amount',
        'Discount Name',
        'Discount Item Name',
        'Staff Name',
        'Table No',
        'Branch Name ',
        'Voucher Code'
      ]
    ]

    discount_item_detail_report_csv
    |> Stream.map(fn x ->
      discount_item_detail_report_csv_contant(x, conn, params, discount, salesdetail, staffs)
    end)
    |> (fn stream -> Stream.concat(csv_header, stream) end).()
    |> CSV.encode()
    |> Enum.into(
      conn
      |> put_resp_content_type("application/csv")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"Discount Item Detail Report - #{name}.csv\""
      )
      |> send_chunked(200)
    )
  end

  defp discount_item_detail_report_csv_contant(
         x,
         conn,
         params,
         discount,
         salesdetail,
         staffs
       ) do
    # disctype = discount_type(item.discountid, discount_item)
    # discamtpercentage = discount_amount(item.discountid, discount_item)

    unit_price =
      if Decimal.to_float(x.itemprice) == 0.00 do
        0.00
      else
        Decimal.to_float(x.itemprice) / x.qty
      end

    discount_amount =
      if x.disctype == "VOUCHER" do
        qty = qty_lookoup(salesdetail, x.salesid)

        Decimal.to_float(x.disamtpercentage) / qty
      else
        Decimal.to_float(x.itemprice) - Decimal.to_float(x.afterdisc)
      end

    [
      x.salesdate,
      x.invoiceno,
      x.itemcode,
      x.itemname,
      x.qty,
      unit_price,
      x.itemprice,
      discount_amount |> :erlang.float_to_binary(decimals: 2),
      discount_name(x.discountid, discount),
      x.discitemsname,
      staff_name(x.staffid, staffs),
      x.tbl_no,
      x.branchname,
      x.voucher_code
    ]
  end

  def qty_lookoup(salesdetail, salesid) do
    a = salesdetail |> Enum.filter(fn x -> x.salesid == salesid end) |> hd
    a.total
  end

  def staff_name(staffid, staffs) do
    a = staffs |> Enum.filter(fn x -> x.staff_id == String.to_integer(staffid) end)

    if a != [] do
      hd(a).staff_name
    else
      "Unknown Staff"
    end
  end

  def discount_name(discountid, discounts) do
    a = discounts |> Enum.filter(fn x -> x.discountid == discountid end)

    if a != [] do
      hd(a).discname
    else
      "Unknown Discount"
    end
  end

  def discount_item_name(discountid, discount_item) do
    a = discount_item |> Enum.filter(fn x -> x.discountid == String.to_integer(discountid) end)

    if a != [] do
      hd(a).discitemsname
    else
      "Unknown Discount Item"
    end
  end

  def discount_type(discountid, discount_item) do
    a = discount_item |> Enum.filter(fn x -> x.discountid == String.to_integer(discountid) end)

    if a != [] do
      hd(a).disctype
    else
      "Unknown Discount Type"
    end
  end

  def discount_amount(discountid, discount_item) do
    a = discount_item |> Enum.filter(fn x -> x.discountid == String.to_integer(discountid) end)

    if a != [] do
      hd(a).discamtpercentage
    else
      "Unknown Discount Amount"
    end
  end

  def sales_chart(conn, params) do
    render(conn, "sales_chart.html", branches: branches())
  end

  def report(conn, params) do
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

    brand_id = BN.get_brand_id(conn)

    render(conn, "report.html", brand_id: brand_id, branches: branches)
  end

  def create(conn, %{"sales" => sales_params}) do
    case BN.create_sales(sales_params) do
      {:ok, sales} ->
        conn
        |> put_flash(:info, "Sales created successfully.")
        |> redirect(to: sales_path(conn, :show, sales))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sales = BN.get_sales!(id)
    render(conn, "show.html", sales: sales)
  end

  def edit(conn, %{"id" => id}) do
    sales = BN.get_sales!(id)
    changeset = BN.change_sales(sales)
    render(conn, "edit.html", sales: sales, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sales" => sales_params}) do
    sales = BN.get_sales!(id)

    case BN.update_sales(sales, sales_params) do
      {:ok, sales} ->
        conn
        |> put_flash(:info, "Sales updated successfully.")
        |> redirect(to: sales_path(conn, :show, sales))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sales: sales, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sales = BN.get_sales!(id)

    {:ok, _sales} = BN.delete_sales(sales)

    conn
    |> put_flash(:info, "Sales deleted successfully.")
    |> redirect(to: sales_path(conn, :index, BN.get_domain(conn)))
  end
end
