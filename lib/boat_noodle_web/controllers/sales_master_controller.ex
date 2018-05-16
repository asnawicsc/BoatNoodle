defmodule BoatNoodleWeb.SalesMasterController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.SalesMaster
  require IEx
  def index(conn, _params) do
    sales_master = Repo.all(from s in SalesMaster, limit: 10)

      year_range = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sp.salesid,where: s.branchid== "1", select: s.salesdatetime) |> Enum.map(fn x -> x.year end) |> Enum.uniq()

   date= "2018-01-07"
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


    range = 1..12 
    month=Enum.map(range, fn x -> Timex.month_name(x) end)

   
time=Timex.now

year=time.year
   q_date = year


     sales_master = Repo.all(from s in SalesMaster, limit: 10)

      year_range = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sp.salesid,where: s.branchid== "1", select: s.salesdatetime) |> Enum.map(fn x -> x.year end) |> Enum.uniq()

   date= "2018-01-07"
  
   total_count = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, where: s.salesid== sp.salesid and s.branchid=="1",
    select: %{datetime: s.salesdatetime, grand_total: sp.grand_total})

    total_count1 = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, where: s.salesid== sp.salesid and s.branchid=="1",
    select: %{datetime: s.salesdatetime, gst_charge: sp.gst_charge})

     total_count2 = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, where: s.salesid== sp.salesid and s.branchid=="1",
    select: %{datetime: s.salesdatetime, service_charge: sp.service_charge})



  year_map = 
  total_count 
  |> Enum.map(fn x -> %{year: x.datetime.year, month: x.datetime.month,grand_total: x.grand_total} end) 
  |> Enum.group_by(fn x -> x.year end)


  year_map1 = 
  total_count1 
  |> Enum.map(fn x -> %{year: x.datetime.year, month: x.datetime.month, gst_charge: x.gst_charge} end) 
  |> Enum.group_by(fn x -> x.year end)

  year_map2 = 
  total_count2 
  |> Enum.map(fn x -> %{year: x.datetime.year, month: x.datetime.month, service_charge: x.service_charge} end) 
  |> Enum.group_by(fn x -> x.year end)


  
    
    month_map = year_map[q_date] |> Enum.group_by(fn x -> x.month end)
    months = month_map |> Map.keys

    totals=for month <- months do
           final = month_map[month] |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()
           %{year: q_date, month: month, sum: final}
           end

         
    month_map1 = year_map1[q_date] |> Enum.group_by(fn x -> x.month end)
    months1 = month_map1 |> Map.keys

    totals1=for month <- months1 do
           final = month_map1[month] |> Enum.map(fn x -> Decimal.to_float(x.gst_charge) end) |> Enum.sum()
           %{year: q_date, month: month, sum: final}
           end

    month_map2 = year_map2[q_date] |> Enum.group_by(fn x -> x.month end)
    months2 = month_map2 |> Map.keys

    totals2=for month <- months2 do
           final = month_map2[month] |> Enum.map(fn x -> Decimal.to_float(x.service_charge) end) |> Enum.sum()
           %{year: q_date, month: month, sum: final}
           end


     render(conn, "index.html",totals1: totals1,totals2: totals2,totals: totals,month: month,year_range: year_range,date: date,tax_graph: tax_graph,sales_graph: sales_graph,service_graph: service_graph, sales_master: sales_master)
  end

 

  def sales_bar_graph_by_year(conn, %{"year" => year}) do

   q_date = String.to_integer(year)


     sales_master = Repo.all(from s in SalesMaster, limit: 10)

      year_range = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sp.salesid,where: s.branchid== "1", select: sp.updated_at) |> Enum.map(fn x -> x.year end) |> Enum.uniq()

   date= "2018-01-07"
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


    range = 1..12 
    month=Enum.map(range, fn x -> Timex.month_name(x) end)

   total_count = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, where: s.salesid== sp.salesid and s.branchid=="1",
    select: %{datetime: s.salesdatetime, grand_total: sp.grand_total})

    total_count1 = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, where: s.salesid== sp.salesid and s.branchid=="1",
    select: %{datetime: s.salesdatetime, gst_charge: sp.gst_charge})

     total_count2 = Repo.all(from sp in  BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales, where: s.salesid== sp.salesid and s.branchid=="1",
    select: %{datetime: s.salesdatetime, service_charge: sp.service_charge})



  year_map = 
  total_count 
  |> Enum.map(fn x -> %{year: x.datetime.year, month: x.datetime.month,grand_total: x.grand_total} end) 
  |> Enum.group_by(fn x -> x.year end)


  year_map1 = 
  total_count1 
  |> Enum.map(fn x -> %{year: x.datetime.year, month: x.datetime.month, gst_charge: x.gst_charge} end) 
  |> Enum.group_by(fn x -> x.year end)

  year_map2 = 
  total_count2 
  |> Enum.map(fn x -> %{year: x.datetime.year, month: x.datetime.month, service_charge: x.service_charge} end) 
  |> Enum.group_by(fn x -> x.year end)


  
    
    month_map = year_map[q_date] |> Enum.group_by(fn x -> x.month end)
    months = month_map |> Map.keys

    totals=for month <- months do
           final = month_map[month] |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()
           %{year: year, month: month, sum: final}
           end

         
    month_map1 = year_map1[q_date] |> Enum.group_by(fn x -> x.month end)
    months1 = month_map1 |> Map.keys

    totals1=for month <- months1 do
           final = month_map1[month] |> Enum.map(fn x -> Decimal.to_float(x.gst_charge) end) |> Enum.sum()
           %{year: year, month: month, sum: final}
           end

    month_map2 = year_map2[q_date] |> Enum.group_by(fn x -> x.month end)
    months2 = month_map2 |> Map.keys

    totals2=for month <- months2 do
           final = month_map2[month] |> Enum.map(fn x -> Decimal.to_float(x.service_charge) end) |> Enum.sum()
           %{year: year, month: month, sum: final}
           end


     render(conn, "index.html",totals1: totals1,totals2: totals2,totals: totals,month: month,year_range: year_range,date: date,tax_graph: tax_graph,sales_graph: sales_graph,service_graph: service_graph, sales_master: sales_master)
  end




  def new(conn, _params) do
    changeset = BN.change_sales_master(%SalesMaster{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sales_master" => sales_master_params}) do
    case BN.create_sales_master(sales_master_params) do
      {:ok, sales_master} ->
        conn
        |> put_flash(:info, "Sales master created successfully.")
        |> redirect(to: sales_master_path(conn, :show, sales_master))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sales_master = BN.get_sales_master!(id)
    render(conn, "show.html", sales_master: sales_master)
  end

  def edit(conn, %{"id" => id}) do
    sales_master = BN.get_sales_master!(id)
    changeset = BN.change_sales_master(sales_master)
    render(conn, "edit.html", sales_master: sales_master, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sales_master" => sales_master_params}) do
    sales_master = BN.get_sales_master!(id)

    case BN.update_sales_master(sales_master, sales_master_params) do
      {:ok, sales_master} ->
        conn
        |> put_flash(:info, "Sales master updated successfully.")
        |> redirect(to: sales_master_path(conn, :show, sales_master))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sales_master: sales_master, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sales_master = BN.get_sales_master!(id)
    {:ok, _sales_master} = BN.delete_sales_master(sales_master)

    conn
    |> put_flash(:info, "Sales master deleted successfully.")
    |> redirect(to: sales_master_path(conn, :index))
  end
end
