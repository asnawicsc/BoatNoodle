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

       
     all =if branch_id != "0" do


      Repo.all(
        from(
          s in Sales,
          left_join: p in SalesPayment,
          on: s.salesid == p.salesid,
          left_join: b in Branch,
          on: b.branchid == s.branchid,
          where:
            s.is_void == 0 and 
            b.branchid == ^branch_id and 
            s.brand_id == ^brand.id and
            p.brand_id == ^brand.id and
            b.brand_id == ^brand.id and
            s.salesdate >= ^params["start_date"] and 
            s.salesdate <= ^params["end_date"],
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
      )|>Enum.with_index


    else
      

      Repo.all(
        from(
          s in Sales,
          left_join: p in SalesPayment,
          on: s.salesid == p.salesid,
          left_join: b in Branch,
          on: b.branchid == s.branchid,
          where:
            s.is_void == 0 and 
            s.brand_id == ^brand.id and
            p.brand_id == ^brand.id and
            b.brand_id == ^brand.id and
            s.salesdate >= ^params["start_date"] and 
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
      )|>Enum.with_index


          end

    
staff_data=Repo.all(from s in Staff, where: s.brand_id==^brand.id)



      data=for item <- all do


 

                seq_no= item|>elem(1)

                item=item|>elem(0)


                staff_name=get_staff_name(item.staff_id,staff_data)
         
 
          
              time=DateTime.from_naive!(item.time, "Etc/UTC")|>DateTime.to_time|>Time.to_string|>String.split_at(5)|>elem(0)
           
            afterdisc=Decimal.to_float(item.after_disc)|>Float.round(2)
            sub_total=Decimal.to_float(item.sub_total)|>Float.round(2)
            service_charge=Decimal.to_float(item.service_charge)|>Float.round(2)
            gst_charge=Decimal.to_float(item.gst_charge)|>Float.round(2)
            rounding=Decimal.to_float(item.rounding)|>Float.round(2)

        disc_amt=Decimal.to_float(item.grand_total)-( Decimal.to_float(item.sub_total)+ Decimal.to_float(item.service_charge) + Decimal.to_float(item.gst_charge) + Decimal.to_float(item.rounding))

          grand_total= Decimal.to_float(item.grand_total)|>Float.round(2)

          after_disc=(sub_total-(disc_amt))|>Float.round(2)

          beforedisc= Decimal.to_float(item.sub_total)+ Decimal.to_float(item.service_charge) + Decimal.to_float(item.gst_charge) + Decimal.to_float(item.rounding)

              disc_percent=if  beforedisc == 0  do
                100
              else

                  disc_percent=
                        if after_disc == 0  do
                          0
                        else
                          ((beforedisc-Decimal.to_float(item.grand_total))/beforedisc)*100
                        end
               
              end|>Float.round(2)

                  salesstatus=if item.is_void == 0 do
                    "C"

                  else
                    "V"
                  end



   csv_content = [
      item.date,
      time,
      seq_no+1,
      item.invoiceno,
      staff_name,
      item.tbl_no,
      item.pax,
      sub_total,
      disc_amt|>Float.round(2),
      disc_percent,
      afterdisc,
      service_charge,
      gst_charge,
      rounding,
      grand_total,
      item.payment_type,
      item.payment_name1,
      item.payment_code1,
      item.payment_type_amt1,
      item.payment_name2,
      item.payment_code2,
      item.payment_type_amt2,
      salesstatus,
      item.branchname]


   
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
      'BRANCH']


  csv_content =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string


  end



    defp get_staff_name(staff_id,staffs) do



          staff_name= Enum.filter(staffs,fn x -> x.staff_id==String.to_integer(staff_id) end)

          if staff_name != [] do

            a=staff_name|>hd
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


      defp get_item_name(itemid,items,combo) do


          item_name= Enum.filter(items,fn x -> x.subcatid==itemid end)
          if item_name != [] do

            a=item_name|>hd
            a.itemname
          else

            b= Enum.filter(combo,fn x -> x.combo_item_id==itemid end)

            if b == [] do
              "unknown item"
            else


            a=b|>hd
            a.combo_item_name
            
            end

          end


    end




  defp csv_content(conn, params) do
    brand = Repo.get_by(Brand, id: BN.get_brand_id(conn))

    branch = Repo.get_by(Branch, branchid: params["branch"], brand_id: brand.id)

    id = branch.branchid |> Integer.to_string()

    if params["branch"] != "0" do
      


    all =
      Repo.all(
        from(
          s in Sales,
          left_join: p in SalesMaster,
          on: s.salesid == p.salesid,
          left_join: b in Branch,
          on: b.branchid == s.branchid,
          where:
            s.is_void == 0 and
            p.is_void == 0 and
            b.branchid == ^id and 
            b.brand_id == ^brand.id and
            p.brand_id == ^brand.id and 
            s.brand_id == ^brand.id and
            s.salesdate >= ^params["start_date"] and 
            s.salesdate <= ^params["end_date"],
          group_by: [s.salesdate, p.itemid,p.itemname,b.branchcode],
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

        name_data=Repo.all(from s in ItemSubcat, where: s.brand_id==^brand.id)
        combo_data=Repo.all(from s in ComboDetails, where: s.brand_id==^brand.id)
    data =
      for item <- all do
        date2 = item |> elem(0) |> Date.to_string()
        date = item |> elem(0)
        item = item |> elem(1)

        gft =
          for item <- item do
            trkh = item.date |> Date.to_string()

                  item_name=get_item_name(item.itemid,name_data,combo_data)

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

            name = branch.branchname
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
              item_name,
              qty,
              rate,
              order_price,
              branch.report_class,
              'SR0'
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

        name = branch.branchname
        cashin = "CashInDrawer:"
        full = cashin <> name

        rpt =
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
                  s.brand_id == ^brand.id and b.brand_id == ^brand.id and sp.brand_id == ^brand.id and
                  b.branchid == ^id,
              select: %{
                grand_total: sum(sp.grand_total),
                sub_total: sum(sp.sub_total),
                service_charge: sum(sp.service_charge),
                gst_charge: sum(sp.gst_charge),
                rounding: sum(sp.rounding)
              }
            )
          )
          |> hd

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
                  s.brand_id == ^brand.id and b.brand_id == ^brand.id and sp.brand_id == ^brand.id and
                  b.branchid == ^id,
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

        disc_amt = 0 - (sub_total + service_charge + gst_charge + rounding)

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
          'SR0'
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
          rounding2,
          rounding2,
          branch.report_class,
          'SR0'
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
          disc_amt,
          disc_amt,
          branch.report_class,
          'SR0'
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
              group_by: p.payment_type_name,
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
              group_by: p.payment_type_name,
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
          'SR0'
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
                  s.brand_id == ^brand.id and b.brand_id == ^brand.id and sp.brand_id == ^brand.id and
                  b.branchid == ^id and sp.payment_type == "CREDITCARD",
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
          'SR0'
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
              'SR0'
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

    render(conn, "item_sales.html", branches: branches)
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
            group_by: i.itemname,
            where:
              sd.afterdisc != 0.00 and s.branchid == ^branch_id and s.salesdate >= ^start_date and
                s.salesdate <= ^end_date and i.brand_id == ^brand.id and s.brand_id == ^brand.id and
                ic.brand_id == ^brand.id,
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
            group_by: i.itemname,
            where:
              sd.afterdisc != 0.00 and s.salesdate >= ^start_date and s.salesdate <= ^end_date and
                i.brand_id == ^brand.id and s.brand_id == ^brand.id and ic.brand_id == ^brand.id,
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

  def item_sales_outlet_csv(conn, params) do
    csv_header = [
      [
        'Date',
        'Outlet',
        'Hieracachy',
        'Category',
        'Item Code',
        'Item Name',
        'Gross Quantity',
        'FOC Quantity',
        'Nett Quantity',
        'Gross Sales',
        'Nett Sales',
        'Unit Price',
        'Discount Value',
        'Service Charge',
        'Store Owner',
        'Combo',
        'Combo Gross Sales'
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
            left_join: st in BoatNoodle.BN.Staff,
            on: st.staff_id == b.manager,
            group_by: [s.salesdate, b.branchname, sd.itemid],
            where:
              s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.brand_id == ^brand.id and
                b.brand_id == ^brand.id and st.brand_id == ^brand.id and s.is_void == ^0 and
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
              store_owner: st.staff_name,
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
                b.brand_id == ^brand.id and st.brand_id == ^brand.id and s.is_void == ^0 and
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
              store_owner: st.staff_name,
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

    name =
      if branch_id != "0" do
        b = Repo.get_by(Branch, brand_id: brand.id, branchid: branch_id)
        b.branchname
      else
        "ALL"
      end

    item_sales_outlet
    |> Stream.map(fn x ->
      item_sales_outlet_csv_content(x, conn, params, subcat_data, combo_data)
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

  defp item_sales_outlet_csv_content(item, conn, params, subcat_data, combo_data) do
    discount_value = Decimal.to_float(item.gross_sales) - Decimal.to_float(item.nett_sales)
    service_charge = (Decimal.to_float(item.nett_sales) / 10) |> Float.round(2)

    [
      item.salesdate,
      item.branchname,
      hierachy(item.itemid, subcat_data, combo_data),
      category(item.itemid, subcat_data, combo_data),
      itemcode(item.itemcode, item.combo_id, subcat_data, combo_data),
      item.itemname,
      item.gross_qty,
      foc_qty(),
      nett_qty(),
      item.gross_sales,
      item.nett_sales,
      unit_price(item.unit_price, item.itemid, item.combo_id, combo_data),
      discount_value,
      service_charge,
      item.store_owner,
      combo_name(item.combo_id, subcat_data),
      combo_gross_sales(item.gross_qty, item.itemid, subcat_data, combo_data)
    ]
  end

  def combo_name(combo_id, subcat_data) do
    a = subcat_data |> Enum.filter(fn x -> x.subcatid == combo_id end)

    if a != [] do
      hd(a).itemname
    else
      "Ala Carte"
    end
  end

  def hierachy(itemid, subcat_data, combo_data) do
    if String.length(Integer.to_string(itemid)) > 5 do
      a = combo_data |> Enum.filter(fn x -> x.itemid == itemid end)

      if a != [] do
        hd(a).category_type
      else
        "Empty"
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
      a = combo_data |> Enum.filter(fn x -> x.itemid == itemid end)

      if a != [] do
        hd(a).category_name
      else
        "Empty"
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

  def itemcode(itemcode, combo_id, subcat_data, combo_data) do
    itemcode
  end

  def foc_qty() do
    0
  end

  def nett_qty() do
    0
  end

  def combo_gross_sales(qty, itemid, subcat_data, combo_data) do
    if String.length(Integer.to_string(itemid)) > 6 do
      data = combo_data |> Enum.filter(fn x -> x.itemid == itemid end) |> Enum.uniq()

      if data != [] do
        unit_price = hd(data).unit_price |> Decimal.to_float()
        top_up = hd(data).top_up |> Decimal.to_float()

        res = Decimal.to_float(qty) * (unit_price + top_up)
        :erlang.float_to_binary(res, decimals: 2)
      else
        0
      end
    else
      0
    end
  end

  def unit_price(unit_price, item_id, combo_id, combo_data) do
    if unit_price > 0 do
      unit_price
    else
      if String.length(Integer.to_string(item_id)) > 5 do
        IEx.pry()
      end
    end
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

    discount_item_report_csv_content =
      if branch_id != "0" do
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: sd.discountid == di.discountitemsid,
            left_join: d in BoatNoodle.BN.Discount,
            on: d.discountid == di.discountid,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            left_join: br in BoatNoodle.BN.Brand,
            on: br.id == sd.brand_id,
            group_by: [s.salesdate, di.discitemsname],
            where:
              sd.brand_id == ^brand.id and sd.discountid != "0" and di.brand_id == ^brand.id and
                d.brand_id == ^brand.id and s.brand_id == ^brand.id and b.brand_id == ^brand.id and
                br.id == ^brand.id and s.branchid == ^branch_id and s.salesdate >= ^start_date and
                s.salesdate <= ^end_date,
            select: %{
              salesdate: s.salesdate,
              discname: d.discname,
              discitemsname: di.discitemsname,
              qty: sum(di.discountitemsid),
              order_price: sum(sd.order_price),
              after_disc: sum(sd.afterdisc)
            }
          )
        )
      else
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: sd.discountid == di.discountitemsid,
            left_join: d in BoatNoodle.BN.Discount,
            on: d.discountid == di.discountid,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            left_join: br in BoatNoodle.BN.Brand,
            on: br.id == sd.brand_id,
            group_by: [s.salesdate, di.discitemsname],
            where:
              sd.brand_id == ^brand.id and sd.discountid != "0" and di.brand_id == ^brand.id and
                d.brand_id == ^brand.id and s.brand_id == ^brand.id and b.brand_id == ^brand.id and
                br.id == ^brand.id and s.salesdate >= ^start_date and s.salesdate <= ^end_date,
            select: %{
              salesdate: s.salesdate,
              discname: d.discname,
              discitemsname: di.discitemsname,
              qty: sum(di.discountitemsid),
              order_price: sum(sd.order_price),
              after_disc: sum(sd.afterdisc)
            }
          )
        )
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
        discount_amount = Decimal.to_float(item.order_price) - Decimal.to_float(item.after_disc)

        [item.salesdate, item.discname, item.discitemsname, item.qty, discount_amount]
      end

    csv_content2 =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end

  def discount_item_detail_report_csv(conn, params) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"Discount Item Detail Report.csv\""
    )
    |> send_resp(200, discount_item_detail_report_csv_content(conn, params))
  end

  defp discount_item_detail_report_csv_content(conn, params) do
    branch_id = params["branch"]
    brand = params["brand"]
    brand = Repo.get_by(Brand, domain_name: brand)
    start_date = params["start_date"]
    end_date = params["end_date"]

    discount_item_detail_report_csv =
      if branch_id != "0" do
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: sd.itemid == i.subcatid,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: di.discountitemsid == sd.discountid,
            left_join: d in BoatNoodle.BN.Discount,
            on: d.discountid == di.discountid,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: st in BoatNoodle.BN.Staff,
            on: st.staff_id == s.staffid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            left_join: br in BoatNoodle.BN.Brand,
            on: br.id == sd.brand_id,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: sp.salesid == s.salesid,
            where:
              sd.discountid != "0" and i.brand_id == ^brand.id and sd.brand_id == ^brand.id and
                di.brand_id == ^brand.id and d.brand_id == ^brand.id and s.brand_id == ^brand.id and
                st.brand_id == ^brand.id and b.brand_id == ^brand.id and br.id == ^brand.id and
                sp.brand_id == ^brand.id and b.brand_id == ^brand.id and s.branchid == ^branch_id and
                s.salesdate >= ^start_date and s.salesdate <= ^end_date,
            select: %{
              salesdate: s.salesdate,
              invoiceno: s.invoiceno,
              itemcode: i.itemcode,
              itemname: i.itemname,
              qty: sd.qty,
              itemprice: i.itemprice,
              discname: d.discname,
              discitemsname: di.discitemsname,
              tbl_no: s.tbl_no,
              staff_name: st.staff_name,
              branchname: b.branchname,
              voucher_code: sp.voucher_code
            }
          )
        )
      else
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: sd.itemid == i.subcatid,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: di.discountitemsid == sd.discountid,
            left_join: d in BoatNoodle.BN.Discount,
            on: d.discountid == di.discountid,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: st in BoatNoodle.BN.Staff,
            on: st.staff_id == s.staffid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            left_join: br in BoatNoodle.BN.Brand,
            on: br.id == sd.brand_id,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: sp.salesid == s.salesid,
            where:
              sd.discountid != "0" and i.brand_id == ^brand.id and sd.brand_id == ^brand.id and
                di.brand_id == ^brand.id and d.brand_id == ^brand.id and s.brand_id == ^brand.id and
                st.brand_id == ^brand.id and b.brand_id == ^brand.id and br.id == ^brand.id and
                sp.brand_id == ^brand.id and b.brand_id == ^brand.id and
                s.salesdate >= ^start_date and s.salesdate <= ^end_date,
            select: %{
              salesdate: s.salesdate,
              invoiceno: s.invoiceno,
              itemcode: i.itemcode,
              itemname: i.itemname,
              qty: sd.qty,
              itemprice: i.itemprice,
              discname: d.discname,
              discitemsname: di.discitemsname,
              tbl_no: s.tbl_no,
              staff_name: st.staff_name,
              branchname: b.branchname,
              voucher_code: sp.voucher_code
            }
          )
        )
      end

    csv_content = [
      'Date ',
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

    data =
      for item <- discount_item_detail_report_csv do
        price_before_discount = Decimal.to_float(item.itemprice) * item.qty

        discount_amount = price_before_discount * item.qty

        [
          item.salesdate,
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

    csv_content2 =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
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
