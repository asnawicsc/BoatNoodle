defmodule BoatNoodleWeb.TaxController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Tax

  def index(conn, _params) do
     date= "2018-01-07"
    total=Repo.all(from s in BoatNoodle.BN.Sales, where: s.branchid== "1" and s.salesdate == ^date)
    pax=Enum.map(total,fn x -> x.pax end)|>Enum.sum()

    total_order=Repo.all(from sm in BoatNoodle.BN.SalesMaster,
    left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sm.salesid,
    where: s.branchid== "1"and s.salesdate == ^date,
    select: %{ orderid: sm.orderid})
    order=Enum.map(total_order,fn x -> x.orderid end)|>Enum.count()

    total_transaction=Repo.all(from sp in BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales,on: sp.salesid==s.salesid, where: s.branchid== "1" and s.salesdate == ^date)


    transaction=Enum.map(total_transaction,fn x -> x.salesid end)|>Enum.count()

    tax=:erlang.float_to_binary(Enum.map(total_transaction,fn x -> Decimal.to_float(x.gst_charge) end) |> Enum.sum(), decimals: 2)

   
   grand_total=:erlang.float_to_binary(Enum.map(total_transaction,fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum(), decimals: 2)

   total1=Enum.map(total_transaction,fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum()
   total2=Enum.map(total_transaction,fn x -> Decimal.to_float(x.gst_charge) end)|>Enum.sum()
   t=:erlang.float_to_binary(total1-total2, decimals: 2);

    outlet_sales_information=Repo.all(from sp in BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales,on: sp.salesid==s.salesid,
    left_join: b in BoatNoodle.BN.Branch,on: s.branchid==b.branchid,
     where: s.branchid== "1" and s.salesdate == ^date,group_by: s.branchid,
     select: %{branchname: b.branchname,
      sub_total: sum(sp.sub_total),
       service_charge: sum(sp.service_charge),
       gst_charge: sum(sp.gst_charge),
       after_disc: sum(sp.after_disc),
       grand_total: sum(sp.grand_total),
       rounding: sum(sp.rounding),
       pax: sum(s.pax)
       })
  

  
   tax_graph=Repo.all(from sp in BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sp.salesid,
    where: s.branchid== "1" and s.salesdate == ^date,select: %{ tax: sum(sp.gst_charge)})
    |> hd() |> Enum.map(fn x -> elem(x,1) end)|>hd|>Decimal.to_float()

     sales_graph=Repo.all(from sp in BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sp.salesid,
    where: s.branchid== "1" and s.salesdate == ^date,select: %{sales: sum(sp.grand_total)})
    |> hd() |> Enum.map(fn x -> elem(x,1) end)|>hd|>Decimal.to_float()

     discount=Repo.all(from sp in BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sp.salesid,
    where: s.branchid== "1" and s.salesdate == ^date,select: %{discount: sum(sp.after_disc)})
    |> hd() |> Enum.map(fn x -> elem(x,1) end)|>hd|>Decimal.to_float()

     sub_total=Repo.all(from sp in BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sp.salesid,
    where: s.branchid== "1" and s.salesdate == ^date,select: %{sub_total: sum(sp.sub_total)})
    |> hd() |> Enum.map(fn x -> elem(x,1) end)|>hd|>Decimal.to_float()
    

    discount_graph=:erlang.float_to_binary( discount-sub_total,decimals: 2)

     service_graph=Repo.all(from sp in BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sp.salesid,
    where: s.branchid== "1" and s.salesdate == ^date,select: %{service_charge: sum(sp.service_charge)})
    |> hd() |> Enum.map(fn x -> elem(x,1) end)|>hd|>Decimal.to_float()

    transaction_graph=Repo.all(from sp in BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sp.salesid,
    where: s.branchid== "1" and s.salesdate == ^date,select: %{trasaction: count(sp.salespay_id)})
    |> hd() |> Enum.map(fn x -> elem(x,1) end)|>hd

    disc=discount-sales_graph
    disc2=:erlang.float_to_binary(disc,decimals: 2)|> :erlang.binary_to_float 


    top_10_sales_item= Repo.all(from sd in BoatNoodle.BN.SalesMaster,
     left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sd.salesid,
     left_join: i in BoatNoodle.BN.ItemSubcat, 
     where: i.subcatid== sd.itemid and s.branchid== "1" and s.salesdate == ^date, 
     group_by: [sd.itemid], 
     select: %{qty: count(sd.itemid),itemname: i.itemname} ,order_by: [desc: count(sd.itemid)], limit: 10)
   
    p = top_10_sales_item |> Enum.map(fn x -> {x.itemname, x.qty} end)

     item_sales_by_category= Repo.all(from sd in BoatNoodle.BN.SalesMaster,
     left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sd.salesid,
     left_join: i in BoatNoodle.BN.ItemSubcat, on: i.subcatid== sd.itemid,
     left_join: is in BoatNoodle.BN.ItemCat, on: is.itemcatid==i.itemcatid,
     where: s.branchid== "1" and s.salesdate == ^date, 
     group_by: [is.itemcatid], 
     select: %{itemcatdesc: is.itemcatdesc,qty: count(sd.itemid)})

      cat = item_sales_by_category |> Enum.map(fn x -> {x.itemcatdesc, x.qty} end)

      year_range = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sp.salesid,where: s.branchid== "1", select: sp.updated_at) |> Enum.map(fn x -> x.year end) |> Enum.uniq()

        range = 1..12 
    month_all=Enum.map(range, fn x -> Timex.month_name(x) end)



   total_sales = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, where: s.salesid== sp.salesid and s.branchid=="1",
    select: %{datetime: sp.updated_at, grand_total: sp.grand_total})

    total_taxes = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, where: s.salesid== sp.salesid and s.branchid=="1",
    select: %{datetime: sp.updated_at, gst_charge: sp.gst_charge})

     total_visits = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, where: s.salesid== sp.salesid and s.branchid=="1",
    select: %{datetime: sp.updated_at, pax: s.pax})



  year_map = 
  total_sales 
  |> Enum.map(fn x -> %{year: x.datetime.year, month: x.datetime.month,grand_total: x.grand_total} end) 
  |> Enum.group_by(fn x -> x.year end)


  year_map1 = 
  total_taxes 
  |> Enum.map(fn x -> %{year: x.datetime.year, month: x.datetime.month, gst_charge: x.gst_charge} end) 
  |> Enum.group_by(fn x -> x.year end)

  year_map2 = 
  total_visits 
  |> Enum.map(fn x -> %{year: x.datetime.year, month: x.datetime.month, pax: x.pax} end) 
  |> Enum.group_by(fn x -> x.year end)

year=Timex.now.year

     q_date = year
    
    month_map = year_map[q_date] |> Enum.group_by(fn x -> x.month end)
    months = month_map |> Map.keys

    totals=for month <- months do
           final = month_map[month] |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()
           %{year: year, month: month, sum: :erlang.float_to_binary(final,decimals: 2)}
           end

         
    month_map1 = year_map1[q_date] |> Enum.group_by(fn x -> x.month end)
    months1 = month_map1 |> Map.keys

    totals1=for month <- months1 do
           final = month_map1[month] |> Enum.map(fn x -> Decimal.to_float(x.gst_charge) end) |> Enum.sum()
           %{year: year, month: month, sum: :erlang.float_to_binary(final,decimals: 2)}
           end

    month_map2 = year_map2[q_date] |> Enum.group_by(fn x -> x.month end)
    months2 = month_map2 |> Map.keys

    totals2=for month <- months2 do
           final = month_map2[month] |> Enum.map(fn x -> x.pax end) |> Enum.sum()
           %{year: year, month: month, sum: final}
           end




    render(conn, "index.html",totals1: totals1,totals2: totals2,totals: totals,month_all: month_all,t: t,year_range: year_range,cat: cat,p: p,disc2: disc2,date: date,transaction_graph: transaction_graph,tax_graph: tax_graph,sales_graph: sales_graph,discount_graph: discount_graph,service_graph: service_graph,transaction: transaction, pax: pax, order: order, tax: tax,grand_total: grand_total,outlet_sales_information: outlet_sales_information)
  end


  def new(conn, _params) do
    changeset = BN.change_tax(%Tax{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tax" => tax_params}) do
    case BN.create_tax(tax_params) do
      {:ok, tax} ->
        conn
        |> put_flash(:info, "Tax created successfully.")
        |> redirect(to: tax_path(conn, :show, tax))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tax = BN.get_tax!(id)
    render(conn, "show.html", tax: tax)
  end

  def edit(conn, %{"id" => id}) do
    tax = BN.get_tax!(id)
    changeset = BN.change_tax(tax)
    render(conn, "edit.html", tax: tax, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tax" => tax_params}) do
    tax = BN.get_tax!(id)

    case BN.update_tax(tax, tax_params) do
      {:ok, tax} ->
        conn
        |> put_flash(:info, "Tax updated successfully.")
        |> redirect(to: tax_path(conn, :show, tax))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tax: tax, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tax = BN.get_tax!(id)
    {:ok, _tax} = BN.delete_tax(tax)

    conn
    |> put_flash(:info, "Tax deleted successfully.")
    |> redirect(to: tax_path(conn, :index))
  end
end
