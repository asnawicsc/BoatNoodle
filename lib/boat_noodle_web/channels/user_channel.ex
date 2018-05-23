defmodule BoatNoodleWeb.UserChannel do
  use BoatNoodleWeb, :channel
  require IEx

  def join("user:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("dashboard", payload, socket) do

    branchid=payload["branch_id"]

    if branchid == "0" do

      total_order =
        Repo.all(
          from(
            sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sm.salesid,
            where:  s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
            select: %{orderid: sm.orderid}
          )
        )

        total_transaction =
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: sp.salesid == s.salesid,
              where: s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
              select: %{gst_charge: sp.gst_charge, grand_total: sp.grand_total, salesid: s.salesid,pax: s.pax}
            )
          )

    else
      total_order =
        Repo.all(
          from(
            sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sm.salesid,
            where: s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
            select: %{orderid: sm.orderid}
          )
        )

         total_transaction =
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: sp.salesid == s.salesid,
              where: s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
              select: %{gst_charge: sp.gst_charge, grand_total: sp.grand_total, salesid: s.salesid,pax: s.pax}
            )
          )
    end


    


    order = Enum.map(total_order, fn x -> x.orderid end) |> Enum.count()
    pax = Enum.map(total_transaction, fn x -> x.pax end) |> Enum.sum()
    transaction = Enum.map(total_transaction, fn x -> x.salesid end) |> Enum.count()
    tax =:erlang.float_to_binary(Enum.map(total_transaction, fn x -> Decimal.to_float(x.gst_charge) end) |> Enum.sum(),decimals: 2)
    total1 = Enum.map(total_transaction, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()
    total2 = Enum.map(total_transaction, fn x -> Decimal.to_float(x.gst_charge) end) |> Enum.sum()
    grand_total = :erlang.float_to_binary(total1 - total2, decimals: 2)

    if  branchid == "0"  do

      outlet_sales=
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: s.branchid == b.branchid,
             where: s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
            group_by: s.branchid,
            select: %{
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
    else

      outlet_sales=
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: s.branchid == b.branchid,
             where: s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
            group_by: s.branchid,
            select: %{
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
    end

    broadcast(socket, "populate_dashboard", %{outlet_sales: outlet_sales,grand_total: grand_total,tax: tax,order: order,pax: pax,transaction: transaction})
    {:noreply, socket}
  end

  def handle_in("open_login_modal", payload, socket) do
    broadcast(socket, "open_login_modal", payload)
    {:noreply, socket}
  end

  def handle_in("list_items", %{"item_cat_id" => item_cat_id}, socket) do
    items =
      Repo.all(
        from(
          i in BoatNoodle.BN.ItemSubcat,
          where: i.itemcatid == ^item_cat_id,
          select: %{
            itemcode: i.itemcode,
            product_code: i.product_code,
            itemname: i.itemname,
            itemprice: i.itemprice,
            is_activate: i.is_activate
          }
        )
      )

    # IEx.pry()
    broadcast(socket, "populate_table_items", %{items: items})
    {:noreply, socket}
  end




  def handle_in("sales_transaction", payload, socket) do

    branchid=payload["branch_id"]

    if branchid == "0" do

       sales_data =
       Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where: s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            salesdate: s.salesdate,
            invoiceno: s.invoiceno,
            payment_type: sp.payment_type,
            grand_total: sp.grand_total,
            tbl_no: s.tbl_no,
            pax: s.pax
          },
         
        )
      )
    else
      
        sales_data =
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: s.salesid == sp.salesid,
              left_join: st in BoatNoodle.BN.Staff,
              on: s.staffid == st.staff_id,
              where: s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
              select: %{
                salesdate: s.salesdate,
                invoiceno: s.invoiceno,
                payment_type: sp.payment_type,
                grand_total: sp.grand_total,
                tbl_no: s.tbl_no,
                pax: s.pax,
                staff_name: st.staff_name
              },
             
            )
          )

    end

    broadcast(socket, "populate_table_sales_transaction", %{sales_data: sales_data})
    {:noreply, socket}
  end

  def handle_in("hourly_sales_summary", payload, socket) do

      s_date=payload["s_date"]
      e_date=payload["e_date"]


      a=Date.from_iso8601!(s_date)
      b=Date.from_iso8601!(e_date)


      date_data = Date.range(a, b)|>Enum.map(fn x -> Date.to_string(x) end)

      luck =for date <- date_data do

        test =
        Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where: s.branchid == ^payload["branch_id"] and s.salesdate == ^date,
          group_by: [s.salesdatetime, s.salesdate],
          select: %{
            salesdatetime: s.salesdatetime,
            salesdate: s.salesdate,
            pax: sum(s.pax),
            grand_total: sum(sp.grand_total)
          }
        )
       )

        pax=test|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        grand_total=test|>Enum.map(fn x -> Decimal.to_float(x.grand_total)end)|>Enum.sum
        if grand_total == 0 do
          grand_total = 0
          else
        grand_total =  :erlang.float_to_binary(grand_total,decimals: 2)
        end
       

        h1=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 1 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h2=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 2 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h3=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 3 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h4=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 4 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h5=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 5 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h6=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 6 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h7=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 7 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h8=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 8 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h9=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 9 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h10=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 10 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h11=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 11 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h12=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 12 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h13=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 13 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h14=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 14 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h15=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 15 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h16=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 16 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h17=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 17 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h18=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 18 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h19=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 19 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h20=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 20 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h21=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 21 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h22=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 22 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h23=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 23 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum
        h24=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 24 end)|>Enum.map(fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum

        if h1 == 0 do
          h1 = 0.0
          else
        h1 =  :erlang.float_to_binary(h1,decimals: 2)
        end
        if h2 == 0 do
          h2 = 0.0
          else
        h1 =  :erlang.float_to_binary(h2,decimals: 2)
        end
        if h3 == 0 do
          h1 = 0.0
          else
        h3 =  :erlang.float_to_binary(h3,decimals: 2)
        end
        if h4 == 0 do
          h4 = 0.0
          else
        h4 =  :erlang.float_to_binary(h4,decimals: 2)
        end
        if h5 == 0 do
          h5 = 0.0
          else
        h5 =  :erlang.float_to_binary(h5,decimals: 2)
        end
        if h6 == 0 do
          h6 = 0.0
          else
        h6 =  :erlang.float_to_binary(h6,decimals: 2)
        end
        if h7 == 0 do
          h7 = 0.0
          else
        h1 =  :erlang.float_to_binary(h7,decimals: 2)
        end
        if h8 == 0 do
          h8 = 0.0
          else
        h8 =  :erlang.float_to_binary(h8,decimals: 2)
        end
        if h9 == 0 do
          h9 = 0.0
          else
        h9 =  :erlang.float_to_binary(h9,decimals: 2)
        end
        if h10 == 0 do
          h1 = 0.0
          else
        h10 =  :erlang.float_to_binary(h10,decimals: 2)
        end
        if h11 == 0 do
          h11 = 0.0
          else
        h11 =  :erlang.float_to_binary(h11,decimals: 2)
        end
        if h12 == 0 do
          h12 = 0.0
          else
        h12 =  :erlang.float_to_binary(h12,decimals: 2)
        end
        if h13 == 0 do
          h13 = 0.0
          else
        h13 =  :erlang.float_to_binary(h13,decimals: 2)
        end
        if h14 == 0 do
          h14 = 0.0
          else
        h14 =  :erlang.float_to_binary(h14,decimals: 2)
        end
        if h15 == 0 do
          h15 = 0.0
          else
        h15 =  :erlang.float_to_binary(h15,decimals: 2)
        end
        if h16 == 0 do
          h16 = 0.0
          else
        h16 =  :erlang.float_to_binary(h16,decimals: 2)
        end
        if h17 == 0 do
          h17 = 0.0
          else
        h17 =  :erlang.float_to_binary(h17,decimals: 2)
        end
        if h18 == 0 do
          h18 = 0.0
          else
        h18 =  :erlang.float_to_binary(h18,decimals: 2)
        end
        if h19 == 0 do
          h19 = 0.0
          else
        h19 =  :erlang.float_to_binary(h19,decimals: 2)
        end
        if h20 == 0 do
          h20 = 0.0
          else
        h20 =  :erlang.float_to_binary(h20,decimals: 2)
        end
        if h21 == 0 do
          h1 = 0.0
          else
        h21 =  :erlang.float_to_binary(h21,decimals: 2)
        end
        if h22 == 0 do
          h22 = 0.0
          else
        h22 =  :erlang.float_to_binary(h22,decimals: 2)
        end
        if h23 == 0 do
          h23 = 0.0
          else
        h23 =  :erlang.float_to_binary(h23,decimals: 2)
        end
        if h24 == 0 do
          h24 = 0.0
          else
        h24 =  :erlang.float_to_binary(h24,decimals: 2)
        end
       


        %{date: date,pax: pax,grand_total: grand_total,h1: h1, h2: h2, h3: h3,h4: h4,h5: h5,h6: h6,h7: h7,h8: h8,h9: h9,h10: h10,h11: h11,h12: h12,h13: h13,h14: h14,h15: h15,h16: h16,h17: h17,h18: h18,h19: h19,h20: h20,h21: h21,h22: h22,h23: h23,h24: h24}
      end

  broadcast(socket, "populate_table_hourly_sales_summary", %{luck: luck})
    {:noreply, socket}

  end

  def handle_in("hourly_pax_summary", payload, socket) do

          s_date=payload["s_date"]
      e_date=payload["e_date"]


      a=Date.from_iso8601!(s_date)
      b=Date.from_iso8601!(e_date)


      date_data = Date.range(a, b)|>Enum.map(fn x -> Date.to_string(x) end)

      luck =for date <- date_data do

        test =
        Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where: s.branchid == ^payload["branch_id"] and s.salesdate == ^date,
          group_by: [s.salesdatetime, s.salesdate],
          select: %{
            salesdatetime: s.salesdatetime,
            salesdate: s.salesdate,
            pax: sum(s.pax),
            grand_total: sum(sp.grand_total)
          }
        )
       )

        pax=test|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        grand_total=test|>Enum.map(fn x -> Decimal.to_float(x.grand_total)end)|>Enum.sum

         if grand_total == 0 do
          grand_total = 0
          else
        grand_total =  :erlang.float_to_binary(grand_total,decimals: 2)
        end
       

        h1=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 1 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h2=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 2 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h3=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 3 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h4=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 4 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h5=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 5 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h6=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 6 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h7=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 7 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h8=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 8 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h9=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 9 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h10=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 10 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h11=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 11 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h12=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 12 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h13=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 13 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h14=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 14 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h15=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 15 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h16=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 16 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h17=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 17 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h18=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 18 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h19=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 19 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h20=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 20 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h21=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 21 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h22=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 22 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h23=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 23 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        h24=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 24 end)|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum

        

        %{date: date,pax: pax,grand_total: grand_total,h1: h1, h2: h2, h3: h3,h4: h4,h5: h5,h6: h6,h7: h7,h8: h8,h9: h9,h10: h10,h11: h11,h12: h12,h13: h13,h14: h14,h15: h15,h16: h16,h17: h17,h18: h18,h19: h19,h20: h20,h21: h21,h22: h22,h23: h23,h24: h24}
      end

  broadcast(socket, "populate_table_hourly_pax_summary", %{luck: luck})
    {:noreply, socket}

   
  end

  def handle_in("hourly_transaction_summary", payload, socket) do


          s_date=payload["s_date"]
      e_date=payload["e_date"]


      a=Date.from_iso8601!(s_date)
      b=Date.from_iso8601!(e_date)


      date_data = Date.range(a, b)|>Enum.map(fn x -> Date.to_string(x) end)

      luck =for date <- date_data do

        test =
        Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where: s.branchid == ^payload["branch_id"] and s.salesdate == ^date,
          group_by: [s.salesdatetime, s.salesdate],
          select: %{
            salesid: s.salesid,
            salesdatetime: s.salesdatetime,
            salesdate: s.salesdate,
            pax: sum(s.pax),
            grand_total: sum(sp.grand_total)
          }
        )
       )

        pax=test|>Enum.map(fn x -> Decimal.to_float(x.pax) end)|>Enum.sum
        grand_total=test|>Enum.map(fn x -> Decimal.to_float(x.grand_total)end)|>Enum.sum

         if grand_total == 0 do
          grand_total = 0
          else
        grand_total =  :erlang.float_to_binary(grand_total,decimals: 2)
        end
       

        h1=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 1 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h2=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 2 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h3=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 3 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h4=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 4 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h5=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 5 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h6=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 6 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h7=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 7 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h8=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 8 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h9=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 9 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h10=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 10 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h11=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 11 end)|>Enum.map(fn x ->x.salesid end)|>Enum.count
        h12=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 12 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h13=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 13 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h14=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 14 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h15=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 15 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h16=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 16 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h17=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 17 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h18=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 18 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h19=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 19 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h20=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 20 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h21=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 21 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h22=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 22 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h23=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 23 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count
        h24=test|>List.flatten|>Enum.filter(fn x -> x.salesdatetime.hour == 24 end)|>Enum.map(fn x -> x.salesid end)|>Enum.count

        %{date: date,pax: pax,grand_total: grand_total,h1: h1, h2: h2, h3: h3,h4: h4,h5: h5,h6: h6,h7: h7,h8: h8,h9: h9,h10: h10,h11: h11,h12: h12,h13: h13,h14: h14,h15: h15,h16: h16,h17: h17,h18: h18,h19: h19,h20: h20,h21: h21,h22: h22,h23: h23,h24: h24}
      end

  broadcast(socket, "populate_table_hourly_transaction_summary", %{luck: luck})
    {:noreply, socket}

   

  end

  def handle_in("item_sold", payload, socket) do

   branchid=payload["branch_id"]

    if branchid == "0" do


      item_sold_data =
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
            where: sd.afterdisc != 0.00  and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
            select: %{
              itemname: i.itemname,
              qty: sum(sd.qty),
              afterdisc: sum(sd.afterdisc),
              itemcatname: ic.itemcatname
            }
          )
        )
    else

        item_sold_data =
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
            where: sd.afterdisc != 0.00 and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
            select: %{
              itemname: i.itemname,
              qty: sum(sd.qty),
              afterdisc: sum(sd.afterdisc),
              itemcatname: ic.itemcatname
            }
          )
        )
    end
    broadcast(socket, "populate_table_item_sold", %{item_sold_data: item_sold_data})
    {:noreply, socket}
  end

  def handle_in("item_sales_detail", payload, socket) do

    branchid=payload["branch_id"]

    if branchid == "0" do
      item_sales_detail_data =
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
          where: s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            itemcatcode: ic.itemcatcode,
            itemname: i.itemname,
            qty: sd.qty,
            invoiceno: s.invoiceno,
            tbl_no: s.tbl_no,
            staff_name: f.staff_name,
            afterdisc: sd.afterdisc,
            salesdate: s.salesdate
          }
        )
      )
    else
      item_sales_detail_data =
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
          where: s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            itemcatcode: ic.itemcatcode,
            itemname: i.itemname,
            qty: sd.qty,
            invoiceno: s.invoiceno,
            tbl_no: s.tbl_no,
            staff_name: f.staff_name,
            afterdisc: sd.afterdisc,
            salesdate: s.salesdate
          }
        )
      )
    
    end


   
    broadcast(socket, "populate_table_item_sales_detail", %{item_sales_detail_data: item_sales_detail_data})
    {:noreply, socket}
  end

  def handle_in("discount_receipt", payload, socket) do


   discount_receipt_data =
      Repo.all(
        from(
          sd in BoatNoodle.BN.SalesMaster,
          left_join: s in BoatNoodle.BN.Sales,on: s.salesid == sd.salesid,
          left_join: i in BoatNoodle.BN.DiscountItem,on: sd.discountid == i.discountitemsid,
          group_by: [s.invoiceno],
           where: sd.discountid== i.discountitemsid and  s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            salesdate: s.salesdate,
            invoiceno: s.invoiceno,
            after_disc: sum(sd.afterdisc),
            order_price: sum(sd.order_price),
            discitemsname: i.discitemsname
          }
        )
      ) |> Enum.map(fn x -> %{salesdate: x.salesdate, invoiceno: x.invoiceno, after_disc: :erlang.float_to_binary(Decimal.to_float(x.after_disc) - Decimal.to_float(x.order_price),decimals: 2), discitemsname: x.discitemsname} end)

      broadcast(socket, "populate_table_discount_receipt", %{discount_receipt_data: discount_receipt_data})
      {:noreply, socket}
  end

  def handle_in("discount_summary", payload, socket) do


   discount_summary_data =
       Repo.all(
        from(
          sd in BoatNoodle.BN.SalesMaster,
          left_join: s in BoatNoodle.BN.Sales,on: s.salesid == sd.salesid,
          left_join: di in BoatNoodle.BN.DiscountItem,on: sd.discountid==di.discountitemsid, 
          left_join: d in BoatNoodle.BN.Discount,on: d.discountid==di.discountid,
          group_by: [d.discountid],
          where: sd.discountid== di.discountitemsid and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            discname: d.discname,
            after_disc: sum(sd.afterdisc),
            order_price: sum(sd.order_price),
            total: count(sd.sales_details)

           
          }
        )
      )|> Enum.map(fn x -> %{discname: x.discname, total: x.total, after_disc: :erlang.float_to_binary(Decimal.to_float(x.after_disc) - Decimal.to_float(x.order_price),decimals: 2)} end)


     

    broadcast(socket, "populate_table_discount_summary", %{discount_summary_data: discount_summary_data})
    {:noreply, socket}
  end

  def handle_in("voided_receipt", payload, socket) do


    voided_receipt_data =
         Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,on: s.salesid == sp.salesid, 
            left_join: f in BoatNoodle.BN.Staff,on: s.staffid == f.staff_id,
            group_by: [s.invoiceno],
            where: s.is_void != 0 and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              invoiceno: s.invoiceno,
              total: sp.grand_total,
              table: s.tbl_no,
              pax: s.pax,
              staff: f.staff_name
             
            }
          )
        )

     

    broadcast(socket, "populate_table_voided_receipt_data", %{voided_receipt_data: voided_receipt_data})
    {:noreply, socket}
  end

  def handle_in("voided_order", payload, socket) do


    voided_order_data =
         Repo.all(
          from(
            v in BoatNoodle.BN.VoidItems,
            left_join: s in BoatNoodle.BN.Sales,on: s.salesid == v.orderid,
            left_join: g in BoatNoodle.BN.ItemSubcat,on: g.subcatid == v.itemid,
            left_join: f in BoatNoodle.BN.Staff,on: s.staffid == f.staff_id,
            where: s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              itemname: v.itemname,
              unit_price: g.itemprice,
              quantity: v.quantity,
              totalprice: v.price,
              staff: f.staff_name
             
            }
          )
        )


     

    broadcast(socket, "populate_table_voided_order_data", %{voided_order_data: voided_order_data})
    {:noreply, socket}
  end

  def handle_in("morning_sales_summary", payload, socket) do

    s_date=payload["s_date"]
    e_date=payload["e_date"]

    a=Date.from_iso8601!(s_date)
    b=Date.from_iso8601!(e_date)



    date_data = Date.range(a, b)|>Enum.map(fn x -> Date.to_string(x) end)

    morning_sales_summary=for date <- date_data do

         Repo.all(
          from(
            v in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,on: s.salesid == v.salesid,
            left_join: g in BoatNoodle.BN.Branch,on: g.branchid == ^payload["branch_id"],
            where: s.branchid == ^payload["branch_id"] and s.salesdate ==^date,
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              branchname: g.branchname,
              pax: s.pax,
              type: s.type,
              totalprice: v.grand_total
             
            }
          )
        )
      
    end|>List.flatten|>Enum.filter(fn x -> x.salesdatetime != nil && x.salesdatetime.hour >= 0 && x.salesdatetime.hour <=10 end)


   total_sales=morning_sales_summary|>Enum.map(fn x -> Decimal.to_float(x.totalprice) end)|>Enum.sum
   total_pax=morning_sales_summary|>Enum.map(fn x -> x.pax end)|>Enum.sum



    broadcast(socket, "populate_table_morning_sales_summary_data", %{morning_sales_summary: morning_sales_summary,total_sales: :erlang.float_to_binary(total_sales,decimals: 2),total_pax: total_pax})
    {:noreply, socket}
  end

  def handle_in("lunch_sales_summary", payload, socket) do

    s_date=payload["s_date"]
    e_date=payload["e_date"]

    a=Date.from_iso8601!(s_date)
    b=Date.from_iso8601!(e_date)



    date_data = Date.range(a, b)|>Enum.map(fn x -> Date.to_string(x) end)

    lunch_sales_summary=for date <- date_data do

         Repo.all(
          from(
            v in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,on: s.salesid == v.salesid,
            left_join: g in BoatNoodle.BN.Branch,on: g.branchid == ^payload["branch_id"],
            where: s.branchid == ^payload["branch_id"] and s.salesdate ==^date,

            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              branchname: g.branchname,
              pax: s.pax,
              type: s.type,
              totalprice: v.grand_total
             
            }
          )
        )
      
    end|>List.flatten|>Enum.filter(fn x -> x.salesdatetime != nil && x.salesdatetime.hour >= 11 && x.salesdatetime.hour <=14 end)

   total_sales=lunch_sales_summary|>Enum.map(fn x -> Decimal.to_float(x.totalprice) end)|>Enum.sum
   total_pax=lunch_sales_summary|>Enum.map(fn x -> x.pax end)|>Enum.sum
  

    broadcast(socket, "populate_table_lunch_sales_summary_data", %{lunch_sales_summary: lunch_sales_summary,total_sales: :erlang.float_to_binary(total_sales,decimals: 2),total_pax: total_pax})
    {:noreply, socket}
  end

  def handle_in("idle_sales_summary", payload, socket) do

    s_date=payload["s_date"]
    e_date=payload["e_date"]

    a=Date.from_iso8601!(s_date)
    b=Date.from_iso8601!(e_date)



    date_data = Date.range(a, b)|>Enum.map(fn x -> Date.to_string(x) end)

    idle_sales_summary=for date <- date_data do

         Repo.all(
          from(
            v in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,on: s.salesid == v.salesid,
            left_join: g in BoatNoodle.BN.Branch,on: g.branchid == ^payload["branch_id"],
            where: s.branchid == ^payload["branch_id"] and s.salesdate ==^date,
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              branchname: g.branchname,
              pax: s.pax,
              type: s.type,
              totalprice: v.grand_total
             
            }
          )
        )
      
    end|>List.flatten|>Enum.filter(fn x -> x.salesdatetime != nil && x.salesdatetime.hour >= 15 && x.salesdatetime.hour <=17 end)

   total_sales=idle_sales_summary|>Enum.map(fn x -> Decimal.to_float(x.totalprice) end)|>Enum.sum
   total_pax=idle_sales_summary|>Enum.map(fn x -> x.pax end)|>Enum.sum
       

    broadcast(socket, "populate_table_idle_sales_summary_data", %{idle_sales_summary: idle_sales_summary,total_sales: :erlang.float_to_binary(total_sales,decimals: 2),total_pax: total_pax})
    {:noreply, socket}
  end

  def handle_in("dinner_sales_summary", payload, socket) do

    s_date=payload["s_date"]
    e_date=payload["e_date"]

    a=Date.from_iso8601!(s_date)
    b=Date.from_iso8601!(e_date)



    date_data = Date.range(a, b)|>Enum.map(fn x -> Date.to_string(x) end)

    dinner_sales_summary=for date <- date_data do

         Repo.all(
          from(
            v in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,on: s.salesid == v.salesid,
            left_join: g in BoatNoodle.BN.Branch,on: g.branchid == ^payload["branch_id"],
            where: s.branchid == ^payload["branch_id"] and s.salesdate ==^date,
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              branchname: g.branchname,
              pax: s.pax,
              type: s.type,
              totalprice: v.grand_total
             
            }
          )
        )
      
    end|>List.flatten|>Enum.filter(fn x -> x.salesdatetime != nil && x.salesdatetime.hour >= 18 && x.salesdatetime.hour <=24 end)

       total_sales=dinner_sales_summary|>Enum.map(fn x -> Decimal.to_float(x.totalprice) end)|>Enum.sum
       total_pax=dinner_sales_summary|>Enum.map(fn x -> x.pax end)|>Enum.sum

    broadcast(socket, "populate_table_dinner_sales_summary_data", %{dinner_sales_summary: dinner_sales_summary,total_sales: :erlang.float_to_binary(total_sales,decimals: 2),total_pax: total_pax})
    {:noreply, socket}
  end

  def handle_in("tax", payload, socket) do


     tax_data =
       Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,on: s.salesid == sp.salesid,
          where: s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            tax: sum(sp.gst_charge),
            afterdisc: sum(sp.grand_total),
            service_charge: sum(sp.service_charge)
            
          }
        )
      )|>Enum.map(fn x -> %{ tax: Decimal.to_float(x.tax) , grand_total: (Decimal.to_float(x.afterdisc) + Decimal.to_float(x.service_charge)- Decimal.to_float(x.tax)) }end)|>hd

       tax_details =
       Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,on: s.salesid == sp.salesid,
          where: s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            salesdatetime: s.salesdatetime,
            invoiceno: s.invoiceno,
            tax: sp.gst_charge,
            after_disc: sp.after_disc,
            rounding: sp.rounding
            
          }
        )
      ) 

      broadcast(socket, "populate_tax_data", %{tax_data: :erlang.float_to_binary(tax_data.tax,decimals: 2),tax_total: :erlang.float_to_binary(tax_data.grand_total,decimals: 2),tax_details: tax_details})
      {:noreply, socket}
  end

  def handle_in("payment_type", payload, socket) do


     payment_type_cash =
       Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,on: s.salesid == sp.salesid,
          where: sp.payment_type =="CASH" and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            cash: sum(sp.grand_total)
  
          }
        )
      )|>hd()

        payment_type_others =
       Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,on: s.salesid == sp.salesid,
          where: sp.payment_type =="CREDITCARD" and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            card: sum(sp.grand_total)
            
          }
        )
      )|>hd()

   

       payment =
       Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,on: s.salesid == sp.salesid,
          group_by: sp.payment_type,
          where: s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            payment_type: sp.payment_type,
            total: sum(sp.grand_total)
          
          }
        )
      )



         
      if payment_type_others.card == nil do
       broadcast(socket, "populate_payment", %{payment_type_cash: payment_type_cash.cash,payment_type_others: "0.00" ,payment: payment})
        {:noreply, socket} 
      end
      if payment_type_cash.cash == nil do
       broadcast(socket, "populate_payment", %{payment_type_cash: "0.00" ,payment_type_others: payment_type_cash.card ,payment: payment})
        {:noreply, socket} 
      end

      if payment_type_cash.cash == nil && payment_type_others.card == nil do
       broadcast(socket, "populate_payment", %{payment_type_cash: "0.00" ,payment_type_others: "0.00" ,payment: payment})
        {:noreply, socket} 
      end
      if payment_type_cash.cash != nil && payment_type_others.card != nil do
        broadcast(socket, "populate_payment", %{payment_type_cash: payment_type_cash.cash,payment_type_others: payment_type_others.card,payment: payment})
        {:noreply, socket}
      end
  end

  def handle_in("cash_in_out", payload, socket) do

    s_date=payload["s_date"]
    e_date=payload["e_date"]



    new_s_date = Enum.join([s_date,":00:00:00"], "")
    new_e_date = Enum.join([e_date,":00:00:00"], "")

    a=Date.from_iso8601!(s_date)
    b=Date.from_iso8601!(e_date)

    dates = Date.range(a, b)|>Enum.map(fn x -> Date.to_string(x) end) |>Poison.encode!()
    date_data = Date.range(a, b)|>Enum.map(fn x -> Date.to_string(x) end)

    cash_in_graph=for date <- date_data do

      a = Enum.join([date,":00:00:00"], "")
      b = Enum.join([date,":23:59:59"], "")

        cash_in =
         Repo.all(
          from(
            c in BoatNoodle.BN.CashInOut,
            left_join: b in BoatNoodle.BN.Branch,on: b.branchid == c.branch_id,
            where: c.cashtype == "CASHIN" and b.branchid == ^payload["branch_id"] and c.date_time >= ^a and c.date_time <= ^b,
            select: %{
              cash_in: sum(c.amount)
    
            }
          )
        )|>hd()
      
    end |>Poison.encode!()

    cash_out_graph=for date <- date_data do

      a = Enum.join([date,":00:00:00"], "")
      b = Enum.join([date,":23:59:59"], "")

        cash_in =
         Repo.all(
          from(
            c in BoatNoodle.BN.CashInOut,
            left_join: b in BoatNoodle.BN.Branch,on: b.branchid == c.branch_id,
            where: c.cashtype == "CASHOUT" and b.branchid == ^payload["branch_id"] and c.date_time >= ^a and c.date_time <= ^b,
            select: %{
              cash_in: sum(c.amount)
    
            }
          )
        )|>hd()
      
    end |>Poison.encode!()




       cash_in =
         Repo.all(
          from(
            c in BoatNoodle.BN.CashInOut,
            left_join: b in BoatNoodle.BN.Branch,on: b.branchid == c.branch_id,
            where: c.cashtype == "CASHIN" and b.branchid == ^payload["branch_id"] and c.date_time >= ^new_s_date and c.date_time <= ^new_e_date,
            select: %{
              cash_in: sum(c.amount)
    
            }
          )
        )|>hd()

          cash_out =
         Repo.all(
          from(
            c in BoatNoodle.BN.CashInOut,
            left_join: b in BoatNoodle.BN.Branch,on: b.branchid == c.branch_id,
            where: c.cashtype == "CASHOUT" and b.branchid == ^payload["branch_id"] and c.date_time >= ^new_s_date and c.date_time <= ^new_e_date,
            select: %{
              cash_out: sum(c.amount)
              
            }
          )
        )|>hd()


         cash =
         Repo.all(
          from(
            c in BoatNoodle.BN.CashInOut,
            left_join: b in BoatNoodle.BN.Branch,on: b.branchid == c.branch_id,
            group_by: c.cashtype,
            where:  b.branchid == ^payload["branch_id"] and c.date_time >= ^new_s_date and c.date_time <= ^new_e_date,
            select: %{
              branchname: b.branchname,
              amount: sum(c.amount),
              cashtype: c.cashtype,
              open: count(c.id)
            
            }
          )

        )



       
    if cash_in.cash_in == nil do
        broadcast(socket, "populate_cash_in_out", %{cash_in: "0.00",cash_out: cash_out.cash_out ,cash: cash,dates: dates,cash_in_graph: cash_in_graph,cash_out_graph: cash_out_graph})
      {:noreply, socket} 
    end
    if cash_out.cash_out == nil do
      broadcast(socket, "populate_cash_in_out", %{cash_in: cash_in.cash_in,cash_out: "0.00" ,cash: cash,dates: dates,cash_in_graph: cash_in_graph,cash_out_graph: cash_out_graph})
      {:noreply, socket} 
     end

    if cash_out.cash_out == nil && cash_in.cash_in == nil do
      broadcast(socket, "populate_cash_in_out", %{cash_in: "0.00",cash_out: "0.00" ,cash: cash,dates: dates,cash_in_graph: cash_in_graph,cash_out_graph: cash_out_graph})
      {:noreply, socket} 
     end
    if cash_out.cash_out == nil && cash_in.cash_in != nil do
      broadcast(socket, "populate_cash_in_out", %{cash_in: cash_in.cash_in,cash_out: cash_out.cash_out,cash: cash,dates: dates,cash_in_graph: cash_in_graph,cash_out_graph: cash_out_graph})
      {:noreply, socket}
    end 
  end




  defp authorized?(_payload) do
      true
    end
  end
