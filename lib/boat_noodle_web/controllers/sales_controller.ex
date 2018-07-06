defmodule BoatNoodleWeb.SalesController do
  use BoatNoodleWeb, :controller

  require IEx

  def top_sales(conn, params) do
    date_setting = params["date"]

    case date_setting do
      "last_month" ->
        start_date = Timex.beginning_of_month(Date.utc_today())
        end_date = Timex.end_of_month(Date.utc_today())
        dat = "Monthly"

      "weekly" ->
        start_date = Timex.beginning_of_week(Date.utc_today()) |> Timex.shift(months: -3)
        end_date = Timex.end_of_week(Date.utc_today()) |> Timex.shift(months: -3)
        dat = "Weekly"

      "daily" ->
        # start_date = Date.utc_today
        #   end_date = Date.utc_today
        start_date = Date.new(2018, 6, 14) |> elem(1)
        end_date = Date.new(2018, 6, 14) |> elem(1)
        dat = "Daily"
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

    Repo.all(from(s in BoatNoodle.BN.Branch, where: s.brand_id==1, order_by: [asc: s.branchname]))
    |> Enum.reject(fn x -> x.branchid == 0 end)
  end

  def index(conn, _params) do
    render(conn, "index.html", branches: branches())
  end

  def new(conn, _params) do
    changeset = BN.change_sales(%Sales{})
    render(conn, "new.html", changeset: changeset)
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
          where: s.invoiceno == ^invoiceno and s.branchid == ^branchid,
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
            salesdate: s.salesdate,
            invoiceno: s.invoiceno
          }
        )
      )
      |> hd

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
          where: s.invoiceno == ^invoiceno and s.branchid == ^branchid,
          select: %{
            combo_item_name: c.combo_item_name,
            itemname: is.itemname,
            qty: sd.qty,
            afterdisc: sd.afterdisc
          }
        )
      )

    render(conn, "detail_invoice.html", detail: detail, detail_item: detail_item)
  end

  def summary(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "summary.html", branches: branches())
  end

  def item_sales(conn, _params) do
    render(conn, "item_sales.html", branches: branches())
  end

  def discounts(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "discounts.html", branches: branches())
  end

  def voided(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "voided.html", branches: branches)
  end

  def csv_compare_category_qty(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))
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
          Enum.filter(try1, fn x -> x.date.month == item end) |> Enum.map(fn x -> x.total end)
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

  def sales_chart(conn, params) do
    render(conn, "sales_chart.html", branches: branches())
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
