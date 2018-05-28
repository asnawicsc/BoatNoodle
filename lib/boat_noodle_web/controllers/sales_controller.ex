defmodule BoatNoodleWeb.SalesController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Sales
  require IEx

  def index(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "index.html", branches: branches)
  end

  def new(conn, _params) do
    changeset = BN.change_sales(%Sales{})
    render(conn, "new.html", changeset: changeset)
  end

  def summary(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "summary.html",branches: branches)
  end

  def summary2(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "summary2.html",branches: branches)
  end

  def item_sales(conn, _params) do
   branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "item_sales.html",branches: branches)
  end

  def discounts(conn, _params) do  
   branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "discounts.html",branches: branches)
  end


  def voided(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "voided.html",branches: branches)
  end

  def csv_compare_category_qty(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "csv_compare_category_qty.html",branches: branches)

  end

  def create_cv(conn, _params) do

    s_date =_params["start_date"]
    e_date =_params["end_date"]

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data1 = Date.range(a, b) |> Enum.map(fn x -> %{date: x} end)|>Enum.group_by(fn x->Integer.to_string(x.date.month) end)|>Map.keys
    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)
  


  
      try1=Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,on: s.salesid == sd.salesid,
            left_join: is in BoatNoodle.BN.ItemSubcat,on: sd.itemid == is.subcatid,
            left_join: ic in BoatNoodle.BN.ItemCat,on: ic.itemcatid == is.itemcatid,
            where: s.branchid >= ^_params["branchid"] and s.salesdate >= ^_params["start_date"] and
            s.salesdate <= ^_params["end_date"],
            select: %{
              total: sd.qty,
              date: s.salesdate,
              itemcatname: ic.itemcatname,
              category_type: ic.category_type
            }
          )
        )
  

      try2=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.itemcatname=="F_AddOn" end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{month: item,sum: a}

      end

      try4=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.category_type !="COMBO" and x.itemcatname=="F_Beverages"  end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{sum: a}

      end

      try5=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.category_type =="COMBO" and x.itemcatname=="F_Beverages" end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{sum: a}

      end


      try7=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.category_type !="COMBO" and x.itemcatname=="F_Breakfast"  end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{sum: a}

      end

      try8=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.category_type =="COMBO" and x.itemcatname=="F_Breakfast"  end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{sum: a}
      end


      try10=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.category_type !="COMBO" and x.itemcatname=="F_Noodle"  end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{sum: a}

      end

      try11=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.category_type =="COMBO" and x.itemcatname=="F_Noodle" end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{sum: a}

      end


      try13=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.category_type !="COMBO" and x.itemcatname=="F_Rice"  end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{sum: a}

      end

      try14=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.category_type =="COMBO" and x.itemcatname=="F_Rice"  end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{month: item,sum: a}

      end


      try16=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.category_type !="COMBO" and x.itemcatname=="F_SideDish"  end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{month: item,sum: a}

      end

      try17=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.category_type =="COMBO" and x.itemcatname=="F_SideDish"  end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{month: item,sum: a}

      end

      try19=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and x.category_type !="COMBO"  and x.itemcatname=="Toppings"  end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{month: item,sum: a}

      end

      try20=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item and  x.category_type =="COMBO" and x.itemcatname=="Toppings"  end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{month: item,sum: a}

      end

      grand_total=for item <- date_data1 do

        item= String.to_integer(item)
        a=Enum.filter(try1, fn x -> x.date.month == item end)|>Enum.map(fn x-> x.total end)|>Enum.sum
        %{month: item,sum: a}

      end

     render(conn, "create_cv.html",try2: try2,try4: try4,try5: try5,try7: try7,try8: try8,try10: try10,try11: try11,try13: try13,try14: try14,try16: try16,try17: try17,try19: try19,try20: try20,grand_total: grand_total)
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
