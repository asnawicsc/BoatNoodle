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
       branches = Repo.all(from(s in BoatNoodle.BN.Branch, where: s.brand_id==^BN.get_brand_id(conn),order_by: s.branchname))
    render(conn, "index.html", branches: branches)
  end

  def new(conn, _params) do
    changeset = BN.change_sales(%Sales{})
    render(conn, "new.html", changeset: changeset)
  end

  def tables(conn, params) do
   branches = Repo.all(from(s in BoatNoodle.BN.Branch, where: s.brand_id==^BN.get_brand_id(conn),order_by: s.branchname))
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


   def quickbook(conn,params) do


   
   conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"Daily Item Sales.csv\"")
    |> send_resp(200, csv_content(conn,params))

  end

 

  defp csv_content(conn,params) do

   brand=Repo.get_by(Brand,id: BN.get_brand_id(conn))

    branch=Repo.get_by(Branch,branchid: params["branch"],brand_id: brand.id)

id=branch.branchid|>Integer.to_string

all=Repo.all(from s in Sales,
left_join: p in SalesMaster, on: s.salesid==p.salesid,
left_join: g in ItemSubcat, on: p.itemid==g.subcatid, 
  where: s.branchid==^id and s.salesdate >= ^params["start_date"] and s.salesdate <= ^params["end_date"],
  group_by: [s.salesdate,g.itemname,g.itemdesc],
 select: %{
 date: s.salesdate,
 name: g.itemname,
 desc: g.itemdesc,
 qty: sum(p.qty),
 order_price: sum(p.order_price)
 })

 

 csv_content = ['CustomerRefFullName ', 'ClassRefFullName', 'TempleteRefFullName','TxnDate','RefNumber','DepositToAccountRefFullName','ItemRefFullName','Desc','Quantity','Rate','Amount','LineClassRefFullName','SalesTaxCodeFullName'] 
    data=for item <- all do

      date=item.date|>Date.to_string|>String.split_at(2)|>elem(1)|>String.split("-")|>Enum.join|>String.split_at(2)
 
      year=date|>elem(0)

      b=date|>elem(1)


      c= b|>String.split_at(2)

      month=c|>elem(0)

      day=c|>elem(1)

      string="BNAM"

      join=day<>month<>year<>string

      name=branch.branchname
      cashin="CashInDrawer:"
      full=cashin<>name



    ['Daily Sales',branch.branchname,'Custom Sales Receipt',item.date,join,full,item.name,item.desc,item.qty,'rate',item.order_price,branch.branchname,'SR'] 
    end
   
   csv_content=List.insert_at(data,0,csv_content)
    |> CSV.encode
    |> Enum.to_list
    |> to_string
  end

  def summary(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch, where: s.brand_id==^BN.get_brand_id(conn),order_by: s.branchname))
    render(conn, "summary.html", branches: branches)
  end

  def item_sales(conn, _params) do
     branches = Repo.all(from(s in BoatNoodle.BN.Branch, where: s.brand_id==^BN.get_brand_id(conn),order_by: s.branchname))
    render(conn, "item_sales.html", branches: branches)
  end

  def discounts(conn, _params) do
     branches = Repo.all(from(s in BoatNoodle.BN.Branch, where: s.brand_id==^BN.get_brand_id(conn),order_by: s.branchname))
    render(conn, "discounts.html", branches: branches)
  end

  def voided(conn, _params) do
     branches = Repo.all(from(s in BoatNoodle.BN.Branch, where: s.brand_id==^BN.get_brand_id(conn),order_by: s.branchname))
    render(conn, "voided.html", branches: branches)
  end

  def csv_compare_category_qty(conn, _params) do
     branches = Repo.all(from(s in BoatNoodle.BN.Branch, where: s.brand_id==^BN.get_brand_id(conn),order_by: s.branchname))
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

   def quickbook(conn,params) do


   
  

  end

 

 
  def item_sales_report_csv(conn, params) do

     conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"Item Sales Report.csv\"")
    |> send_resp(200, item_sales_report_csv_content(conn,params))


  end

  defp item_sales_report_csv_content(conn,params) do

    branch_id=params["branch"]
   brand=params["brand"]
   brand=Repo.get_by(Brand, domain_name: brand)
   start_date=params["start_date"]
   end_date=params["end_date"]


     item_sold_data =
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: sd.itemid == i.subcatid,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: ic in BoatNoodle.BN.ItemCat,
            on: ic.itemcatid == i.itemcatid,
            group_by: i.itemname,
            where:
              sd.afterdisc != 0.00 and s.branchid == ^branch_id and
                s.salesdate >= ^start_date and s.salesdate <= ^end_date and sd.brand_id==^brand.id,
            select: %{
              itemcode: i.itemcode,
              itemname: i.itemname,
              itemcatname: ic.itemcatname,
              qty: sum(sd.qty),
              nett_price: sum(sd.afterdisc),
              gross_price: sum(sd.order_price)
              
            }
          )
        )
 

 csv_content = ['Item Code ', 'Item Name', 'Category','Quantity','Net Sales','Gross Sales'] 
    data=for item <- item_sold_data do

     
    [item.itemcode,item.itemname,item.itemcatname,Decimal.to_string(item.qty),Decimal.to_string(item.nett_price),Decimal.to_string(item.gross_price)] 
    end



          qty=Enum.map(item_sold_data,fn x -> Decimal.to_float(x.qty) end)|>Enum.sum|>Float.round(2)|>Float.to_string
          nett_price=Enum.map(item_sold_data,fn x -> Decimal.to_float(x.nett_price) end)|>Enum.sum|>Float.round(2)|>Float.to_string
          gross_price=Enum.map(item_sold_data,fn x -> Decimal.to_float(x.gross_price) end)|>Enum.sum|>Float.round(2)|>Float.to_string
   a="Total"
   b=""
   c=""
   bottem = ['Total','-','-',qty,nett_price,gross_price] 
   csv_content2=List.insert_at(data,0,csv_content)

   
   final=List.insert_at(csv_content2,-1,bottem )

    |> CSV.encode
    |> Enum.to_list
    |> to_string
  end

  def item_sales_outlet_csv(conn, params) do

     conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"Item Sales Report.csv\"")
    |> send_resp(200, item_sales_outlet_csv_content(conn,params))


  end

  defp item_sales_outlet_csv_content(conn,params) do

    branch_id=params["branch"]
   brand=params["brand"]
   brand=Repo.get_by(Brand, domain_name: brand)
   start_date=params["start_date"]
   end_date=params["end_date"]


     item_sales_outlet=
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: sd.itemid == i.subcatid,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
             left_join: ic in BoatNoodle.BN.ItemCat,
            on: ic.itemcatid == i.itemcatid,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: di.discountitemsid== sd.discountid,
            left_join: st in BoatNoodle.BN.Staff,
            on: st.staff_id== s.staffid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid== s.branchid,
            group_by: [s.salesdate,i.itemname],
            where:
                s.branchid == ^branch_id and
                s.salesdate >= ^start_date and 
                s.salesdate <= ^end_date,
            select: %{
              salesdate: s.salesdate,
              branchname: b.branchname,
              hierachy: ic.category_type,
              category: ic.itemcatname,
              itemcode: i.itemcode,
              itemname: i.itemname,
              gross_qty:  sum(sd.qty),
              foc_qty: sum(di.disc_qty),
              gross_sales: sum(sd.order_price),
              nett_sales: sum(sd.afterdisc),
              unit_price: sd.unit_price,
              store_owner: st.staff_name
              
              
            }
          )
        )

 csv_content = ['Date ',
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
               'Store Owner'
                ] 
    data=for item <- item_sales_outlet do

            if item.foc_qty == nil do

              foc_qty= 0
            else
              foc_qty=Decimal.to_float(item.foc_qty)

            end
           

                nett_qty=Decimal.to_float(item.gross_qty)-foc_qty
          discount_value=Decimal.to_float(item.gross_sales)-Decimal.to_float(item.nett_sales)
          service_charge=(Decimal.to_float(item.nett_sales)/20)|>Float.round(2)
 
    [item.salesdate,
    item.branchname,
    item.hierachy,
    item.category,
    item.itemcode,
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



        
   csv_content2=List.insert_at(data,0,csv_content)

    |> CSV.encode
    |> Enum.to_list
    |> to_string
  end

  def combo_item_sales_csv(conn, params) do

     conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"Combo Item Sales Report.csv\"")
    |> send_resp(200, combo_item_sales_csv_content(conn,params))


  end

    defp combo_item_sales_csv_content(conn,params) do

    branch_id=params["branch"]
   brand=params["brand"]
   brand=Repo.get_by(Brand, domain_name: brand)
   start_date=params["start_date"]
   end_date=params["end_date"]


     item_sales_outlet=
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: sd.combo_id == i.subcatid,
            left_join: cd in BoatNoodle.BN.ComboDetails,
            on: cd.combo_item_id == sd.itemid,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
             left_join: ic in BoatNoodle.BN.ItemCat,
            on: ic.itemcatid == cd.menu_cat_id,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: di.discountitemsid== sd.discountid,
            left_join: st in BoatNoodle.BN.Staff,
            on: st.staff_id== s.staffid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid== s.branchid,
            group_by: [s.salesdate,cd.combo_item_name],
            where:
                sd.combo_id != 0 and
                s.branchid == ^branch_id and
                s.salesdate >= ^start_date and 
                s.salesdate <= ^end_date,
            select: %{
              salesdate: s.salesdate,
              branchname: b.branchname,
              hierachy: ic.category_type,
              category: ic.itemcatname,
              itemcode: i.itemcode,
              comboname: i.itemname,
              itemname: cd.combo_item_name,
              gross_qty:  sum(sd.qty),
              foc_qty: sum(di.disc_qty),
              unit_price: cd.unit_price,
              store_owner: st.staff_name
              
              
            }
          )
        )

 csv_content = ['Date ',
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
    data=for item <- item_sales_outlet do

            if item.foc_qty == nil do

              foc_qty=0
            else
              foc_qty=Decimal.to_float(item.foc_qty)

       end
           

                nett_qty=Decimal.to_float(item.gross_qty)-foc_qty
         
          gross_sales=Decimal.to_float(item.unit_price)*nett_qty
          nett_sales=Decimal.to_float(item.unit_price)*nett_qty
          service_charge=(nett_sales/20)|>Float.round(2)
           discount_value=gross_sales-nett_sales
 
    [item.salesdate,
    item.branchname,
    item.hierachy,
    item.category,
    item.itemcode,
    item.comboname,
    item.itemname,
    item.gross_qty,
    nett_qty,
    foc_qty,
    gross_sales,
    nett_sales,
    item.unit_price,
    discount_value,
    service_charge,
    item.store_owner
    ] 
    end



        
   csv_content2=List.insert_at(data,0,csv_content)

    |> CSV.encode
    |> Enum.to_list
    |> to_string
  end



  def discount_item_report_csv(conn, params) do

     conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"Discount Item Report.csv\"")
    |> send_resp(200, discount_item_report_csv_content(conn,params))


  end

  defp discount_item_report_csv_content(conn,params) do

    branch_id=params["branch"]
   brand=params["brand"]
   brand=Repo.get_by(Brand, domain_name: brand)
   start_date=params["start_date"]
   end_date=params["end_date"]

     discount_item_report_csv_content=
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: sd.discountid == di.discountitemsid,
            left_join: d in BoatNoodle.BN.Discount,
            on: d.discountid== di.discountid,
             left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid== sd.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid== s.branchid,
            left_join: br in BoatNoodle.BN.Brand,
            on: br.id== sd.brand_id,
            group_by: [s.salesdate,di.discitemsname],   
            where:
                sd.discountid != "0" and
                sd.brand_id==^brand.id and
                 b.brand_id==^brand.id and
                s.branchid == ^branch_id and
                s.salesdate >= ^start_date and 
                s.salesdate <= ^end_date,
            select: %{
              salesdate: s.salesdate,
              discname:  d.discname,
              discitemsname: di.discitemsname,
              qty:  sum(di.discountitemsid),
              order_price: sum(sd.order_price),
              after_disc: sum(sd.afterdisc)          
            }
          )
        )
        

    csv_content = ['Date ',
              'Discount Item',
               'Discount Category',
               'Discount Number',
               'Discount Amount'
                ] 
    data=for item <- discount_item_report_csv_content do

          
              discount_amount=Decimal.to_float(item.order_price)-Decimal.to_float(item.after_disc)

         
                   [item.salesdate,item.discname,item.discitemsname,item.qty,discount_amount] 
    end



        
   csv_content2=List.insert_at(data,0,csv_content)

    |> CSV.encode
    |> Enum.to_list
    |> to_string

  end

   def discount_item_detail_report_csv(conn, params) do

     conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"Discount Item Detail Report.csv\"")
    |> send_resp(200, discount_item_detail_report_csv_content(conn,params))


  end

  defp discount_item_detail_report_csv_content(conn,params) do

    branch_id=params["branch"]
   brand=params["brand"]
   brand=Repo.get_by(Brand, domain_name: brand)
   start_date=params["start_date"]
   end_date=params["end_date"]


     discount_item_detail_report_csv=
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: sd.itemid == i.subcatid,
             left_join: di in BoatNoodle.BN.DiscountItem,
            on: di.discountitemsid== sd.discountid,
            left_join: d in BoatNoodle.BN.Discount,
            on: d.discountid== di.discountid,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: st in BoatNoodle.BN.Staff,
            on: st.staff_id== s.staffid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid== s.branchid,
            left_join: br in BoatNoodle.BN.Brand,
            on: br.id== sd.brand_id,
             left_join: sp in BoatNoodle.BN.SalesPayment,
            on: sp.salesid == s.salesid,     
            where:
                sd.discountid != "0" and
                sd.brand_id==^brand.id and
                 b.brand_id==^brand.id and
                s.branchid == ^branch_id and
                s.salesdate >= ^start_date and 
                s.salesdate <= ^end_date,
            select: %{
              salesdate: s.salesdate,
              invoiceno: s.invoiceno,
              itemcode: i.itemcode,
              itemname: i.itemname,
              qty: sd.qty,
              itemprice: i.itemprice,
              discname:  d.discname,
              discitemsname: di.discitemsname,
              tbl_no: s.tbl_no,
              staff_name: st.staff_name,
              branchname: b.branchname,
              voucher_code: sp.voucher_code
              
              
            }
          )
        )

 csv_content = ['Date ',
               'Invoice No',
               'Item Code',
               'Item Name',
               'Quantity',
               'Item Price',
               'Price Before Discount',
               'Discount Amount',
               'Discount Name',
               'Discount Item Name',
               'Table No',
               'Staff Name',
               'Branch Name ',
               'Voucher Code'
               
                ] 
    data=for item <- discount_item_detail_report_csv do

           

                price_before_discount=Decimal.to_float(item.itemprice)*item.qty
         
          discount_amount=price_before_discount*item.qty
  
   
 
    [item.salesdate,
    item.invoiceno,
    item.itemcode,
    item.itemname,
    item.qty,
    item.itemprice,
    price_before_discount,
    discount_amount,
    item.discname,
    item.discitemsname,
    item.tbl_no,
    item.staff_name,
    item.branchname,
    item.voucher_code
    ] 
    end

  
   csv_content2=List.insert_at(data,0,csv_content)

    |> CSV.encode
    |> Enum.to_list
    |> to_string
  end


  def sales_chart(conn, params) do
    render(conn, "sales_chart.html", branches: branches())
  end

   def report(conn, params) do
  branches = Repo.all(from(s in BoatNoodle.BN.Branch, where: s.brand_id==^BN.get_brand_id(conn),order_by: s.branchname))
    render(conn, "report.html", branches: branches)
   
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
