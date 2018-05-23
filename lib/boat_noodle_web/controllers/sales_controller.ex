defmodule BoatNoodleWeb.SalesController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Sales
  require IEx

  def index(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "index.html", branches: branches)
  end

  def get_date(conn, %{"daterange" => daterange, "branchid" => branchid}) do
    all = daterange |> String.replace(~r/\//, "-")
    start = String.slice(all, 0..9)
    finish = String.slice(all, 13..22)

    s_a = String.slice(start, 0..1)
    s_b = String.slice(start, 6..9)
    s_c = String.slice(start, 3..4)
    new_start = Enum.join([s_b, "-", s_a, "-", s_c], "")
    {:ok, date_start} = Date.from_iso8601(new_start)

    f_a = String.slice(finish, 0..1)
    f_b = String.slice(finish, 6..9)
    f_c = String.slice(finish, 3..4)
    new_finish = Enum.join([f_b, "-", f_a, "-", f_c], "")
    {:ok, date_end} = Date.from_iso8601(new_finish)
    a = Date.range(date_start, date_end)
    date_range = Enum.map(a, fn x -> x end)

    test =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where:
            s.branchid == ^branchid and s.salesdate >= ^new_start and s.salesdate <= ^new_finish,
          group_by: [s.salesdatetime, s.salesdate],
          select: %{
            salesdatetime: s.salesdatetime,
            salesdate: s.salesdate,
            pax: sum(s.pax),
            grand_total: sum(sp.grand_total)
          }
        )
      )

    list_year =
      test
      |> Enum.map(fn x ->
        %{
          year: x.salesdatetime.year,
          month: x.salesdatetime.month,
          day: x.salesdatetime.day,
          hour: x.salesdatetime.hour,
          salesdate: x.salesdate,
          pax: x.pax,
          grand_total: x.grand_total,
          salesdatetime: x.salesdatetime
        }
      end)
      |> Enum.group_by(fn x -> x.year end)

    years = list_year |> Map.keys()

    totals =
      for year <- years do
        month_map = list_year[year] |> Enum.group_by(fn x -> x.month end)
        months = month_map |> Map.keys()

        for month <- months do
          day_map = month_map[month] |> Enum.group_by(fn x -> x.day end)
          days = day_map |> Map.keys()

          for day <- days do
            hour_map = day_map[day] |> Enum.group_by(fn x -> x.hour end)
            hours = hour_map |> Map.keys()

            for hour <- hours do
              final =
                hour_map[hour] |> Enum.map(fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()

              grand_total =
                hour_map[hour] |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
                |> Enum.sum()

              %{
                year: year,
                month: month,
                day: day,
                hour: hour,
                sum: final,
                grand_total: grand_total
              }
            end
          end
        end
      end
      |> List.flatten()

      IEx.pry

    ranges = 1..24

    render(conn, "get_date.html", totals: totals, date_range: date_range)
  end

  def get_hourly_sales(conn, %{"daterange" => daterange, "branchid" => branchid}) do
    all = daterange |> String.replace(~r/\//, "-")
    start = String.slice(all, 0..9)
    finish = String.slice(all, 13..22)

    s_a = String.slice(start, 0..1)
    s_b = String.slice(start, 6..9)
    s_c = String.slice(start, 3..4)
    new_start = Enum.join([s_b, "-", s_a, "-", s_c], "")
    {:ok, date_start} = Date.from_iso8601(new_start)

    f_a = String.slice(finish, 0..1)
    f_b = String.slice(finish, 6..9)
    f_c = String.slice(finish, 3..4)
    new_finish = Enum.join([f_b, "-", f_a, "-", f_c], "")
    {:ok, date_end} = Date.from_iso8601(new_finish)
    a = Date.range(date_start, date_end)
    date_range = Enum.map(a, fn x -> x end)

    test =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where:
            s.branchid == ^branchid and s.salesdate >= ^new_start and s.salesdate <= ^new_finish,
          group_by: [s.salesdatetime, s.salesdate],
          select: %{
            salesdatetime: s.salesdatetime,
            salesdate: s.salesdate,
            pax: sum(s.pax),
            grand_total: sum(sp.grand_total)
          }
        )
      )

    list_year =
      test
      |> Enum.map(fn x ->
        %{
          year: x.salesdatetime.year,
          month: x.salesdatetime.month,
          day: x.salesdatetime.day,
          hour: x.salesdatetime.hour,
          salesdate: x.salesdate,
          pax: x.pax,
          grand_total: x.grand_total,
          salesdatetime: x.salesdatetime
        }
      end)
      |> Enum.group_by(fn x -> x.year end)

    years = list_year |> Map.keys()

    totals_o =
      for year <- years do
        month_map = list_year[year] |> Enum.group_by(fn x -> x.month end)
        months = month_map |> Map.keys()

        for month <- months do
          day_map = month_map[month] |> Enum.group_by(fn x -> x.day end)
          days = day_map |> Map.keys()

          for day <- days do
            hour_map = day_map[day] |> Enum.group_by(fn x -> x.hour end)
            hours = hour_map |> Map.keys()

            for hour <- hours do
              final =
                hour_map[hour] |> Enum.map(fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()

              grand_total =
                hour_map[hour] |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
                |> Enum.sum()

              %{
                year: year,
                month: month,
                day: day,
                hour: hour,
                sum: final,
                grand_total: grand_total
              }
            end
          end
        end
      end
      IEx.pry

      totals = totals_o
      |> List.flatten()


    ranges = 1..24

    render(conn, "get_hourly_sales.html", totals: totals, date_range: date_range)
  end

  def get_hourly_transaction(conn, %{"daterange" => daterange, "branchid" => branchid}) do
    all = daterange |> String.replace(~r/\//, "-")
    start = String.slice(all, 0..9)
    finish = String.slice(all, 13..22)

    s_a = String.slice(start, 0..1)
    s_b = String.slice(start, 6..9)
    s_c = String.slice(start, 3..4)
    new_start = Enum.join([s_b, "-", s_a, "-", s_c], "")
    {:ok, date_start} = Date.from_iso8601(new_start)

    f_a = String.slice(finish, 0..1)
    f_b = String.slice(finish, 6..9)
    f_c = String.slice(finish, 3..4)
    new_finish = Enum.join([f_b, "-", f_a, "-", f_c], "")
    {:ok, date_end} = Date.from_iso8601(new_finish)
    a = Date.range(date_start, date_end)
    date_range = Enum.map(a, fn x -> x end)

    test =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where:
            s.branchid == ^branchid and s.salesdate >= ^new_start and s.salesdate <= ^new_finish,
          group_by: [s.salesdatetime, s.salesdate],
          select: %{
            salesdatetime: s.salesdatetime,
            salesdate: s.salesdate,
            pax: sum(s.pax),
            grand_total: sum(sp.grand_total),
            transactions: count(sp.salespay_id)
          }
        )
      )

    list_year =
      test
      |> Enum.map(fn x ->
        %{
          year: x.salesdatetime.year,
          month: x.salesdatetime.month,
          day: x.salesdatetime.day,
          hour: x.salesdatetime.hour,
          salesdate: x.salesdate,
          pax: x.pax,
          grand_total: x.grand_total,
          transactions: x.transactions,
          salesdatetime: x.salesdatetime
        }
      end)
      |> Enum.group_by(fn x -> x.year end)

    years = list_year |> Map.keys()

    totals =
      for year <- years do
        month_map = list_year[year] |> Enum.group_by(fn x -> x.month end)
        months = month_map |> Map.keys()

        for month <- months do
          day_map = month_map[month] |> Enum.group_by(fn x -> x.day end)
          days = day_map |> Map.keys()

          for day <- days do
            hour_map = day_map[day] |> Enum.group_by(fn x -> x.hour end)
            hours = hour_map |> Map.keys()

            for hour <- hours do
              final =
                hour_map[hour] |> Enum.map(fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()

              grand_total =
                hour_map[hour] |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
                |> Enum.sum()

              transactions = hour_map[hour] |> Enum.map(fn x -> x.transactions end) |> Enum.sum()

              %{
                year: year,
                month: month,
                day: day,
                hour: hour,
                sum: final,
                grand_total: grand_total,
                transactions: transactions
              }
            end
          end
        end
      end
      |> List.flatten()

    render(conn, "get_hourly_transaction.html", totals: totals, date_range: date_range)
  end

  def new(conn, _params) do
    changeset = BN.change_sales(%Sales{})
    render(conn, "new.html", changeset: changeset)
  end

  def transaction(conn, _params) do
    transactions =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          left_join: st in BoatNoodle.BN.Staff,
          on: s.staffid == st.staff_id,
          where: s.branchid == "1",
          select: %{
            salesdatetime: s.salesdatetime,
            invoiceno: s.invoiceno,
            payment_type: sp.payment_type,
            grand_total: sp.grand_total,
            tbl_no: s.tbl_no,
            pax: s.pax,
            staff_name: st.staff_name
          },
          limit: 10
        )
      )

    render(conn, "transaction.html", transactions: transactions)
  end

  def hourly_pax_summary(conn, _params) do
    branchs = Repo.all(from(s in BoatNoodle.BN.Branch))

    render(conn, "hourly_pax_summary.html", branchs: branchs)
  end

  def hourly_sales_summary(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))

    render(conn, "hourly_sales_summary.html", branches: branches)
  end

  def hourly_transaction_summary(conn, _params) do
    branchs = Repo.all(from(s in BoatNoodle.BN.Branch))

    render(conn, "hourly_transaction_summary.html", branchs: branchs)
  end

  def item_sold(conn, _params) do
    date = "2017-06-07"

    item_solds =
      Repo.all(
        from(
          sd in BoatNoodle.BN.SalesMaster,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sd.salesid,
          left_join: i in BoatNoodle.BN.ItemSubcat,
          on: sd.itemid == i.subcatid,
          left_join: ic in BoatNoodle.BN.ItemCat,
          on: ic.itemcatid == i.itemcatid,
          group_by: i.itemname,
          where: s.branchid == "1" and s.salesdate == ^date,
          select: %{
            itemname: i.itemname,
            qty: sum(sd.qty),
            afterdisc: sum(sd.afterdisc),
            itemcatname: ic.itemcatname
          }
        )
      )

    render(conn, "item_sold.html", item_solds: item_solds)
  end

  def item_sales_detail(conn, _params) do
    date = "2017-06-07"

    item_sales_details =
      Repo.all(
        from(
          sd in BoatNoodle.BN.SalesMaster,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sd.salesid,
          left_join: i in BoatNoodle.BN.ItemSubcat,
          on: sd.itemid == i.subcatid,
          left_join: ic in BoatNoodle.BN.ItemCat,
          on: ic.itemcatid == i.itemcatid,
          left_join: f in BoatNoodle.BN.Staff,
          on: s.staffid == f.staff_id,
          where: s.branchid == "1" and s.salesdate == ^date,
          select: %{
            itemcatcode: ic.itemcatcode,
            itemname: i.itemname,
            qty: sd.qty,
            invoiceno: s.invoiceno,
            tbl_no: s.tbl_no,
            staff_name: f.staff_name,
            afterdisc: sd.afterdisc,
            salesdatetime: s.salesdatetime
          }
        )
      )

    render(conn, "item_sales_detail.html", item_sales_details: item_sales_details)
  end

  def detail_invoice(conn, %{"id" => id}) do
    date = "2017-06-07"
    sale = Repo.get_by(Sales, invoiceno: id, branchid: "1")
    staff = Repo.get_by(BN.Staff, staff_id: sale.staffid)

    sales =
      Repo.all(
        from(
          s in Sales,
          left_join: sd in BoatNoodle.BN.SalesMaster,
          on: s.salesid == sd.salesid,
          left_join: i in BoatNoodle.BN.ItemSubcat,
          on: sd.itemid == i.subcatid,
          where: s.invoiceno == ^id and s.branchid == "1",
          select: %{itemname: i.itemname, 
          qty: sd.qty,
           afterdisc: sd.afterdisc}
        )
      )

    total = Repo.get_by(BN.SalesPayment, salesid: sale.salesid)

    render(
      conn,
      "item_sales_detail_invoice.html",
      total: total,
      staff: staff,
      sale: sale,
      id: id,
      sales: sales
    )
  end

  def discount(conn, _params) do
    date = "2018-01-07"

    discounts =
      Repo.all(
        from(
          sd in BoatNoodle.BN.SalesMaster,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sd.salesid,
          left_join: sp in BoatNoodle.BN.SalesPayment,
          on: sp.salesid == s.salesid,
          left_join: i in BoatNoodle.BN.DiscountItem,
          on: sd.discountid == i.discountid,
          group_by: s.invoiceno,
          where: s.branchid == "1" and s.salesdate == ^date,
          select: %{
            salesdatetime: s.salesdatetime,
            invoiceno: s.invoiceno,
            after_disc: sp.after_disc,
            sub_total: sp.sub_total,
            discitemsname: i.descriptions
          }
        )
      )

    render(conn, "discount.html", discounts: discounts)
  end

  def discount_summary(conn, _params) do
    date = "2018-01-07"

    discount_summarys =
      Repo.all(
        from(
          sd in BoatNoodle.BN.SalesMaster,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sd.salesid,
          where: s.branchid == "1" and s.salesdate == ^date and sd.discountid != "0",
          select: %{
            total: count(sd.discountid),
            order_price: sum(sd.order_price),
            afterdisc: sum(sd.afterdisc)
          }
        )
      )

    render(conn, "discount_summary.html", discount_summarys: discount_summarys)
  end

  def voided_order(conn, _params) do
    date = "2018-01-07"

    voided_order =
      Repo.all(
        from(
          v in BoatNoodle.BN.VoidItems,
          left_join: sd in BoatNoodle.BN.SalesMaster,
          on: v.orderid == sd.orderid,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sd.salesid,
          where: s.branchid == "1" and s.salesdate == ^date,
          select: %{itemname: v.itemname, itempriceperqty: v.itempriceperqty}
        )
      )

    render(conn, "voided_order.html", voided_order: voided_order)
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
    |> redirect(to: sales_path(conn, :index))
  end
end
