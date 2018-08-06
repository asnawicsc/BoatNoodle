defmodule BoatNoodleWeb.DashboardChannel do
  use BoatNoodleWeb, :channel
  import Number.Currency
  require IEx

  def join("dashboard_channel:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("dashboard", payload, socket) do
    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand = Repo.get_by(Brand, id: brand_id)

    if branchid != "0" do
      a =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"] and
                b.brand_id == ^brand_id and sp.brand_id == ^brand_id,
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

      # 
      grp = a |> Enum.group_by(fn x -> x.salesdate end)


        year=a|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        grp_daily=for item <- year do


                  sales=Enum.filter(a,fn x -> x.salesdate.year==item end)

                  months=sales|>Enum.group_by(fn x -> x.salesdate.month end)|>Map.keys
          

            for month <- months do

  
              sales=Enum.filter(a,fn x -> x.salesdate.month==month end)

               days=sales|>Enum.group_by(fn x -> x.salesdate end)|>Map.keys
          
           
                for day <- days do

                   data=Enum.filter(a,fn x -> x.salesdate==day end)

                  total_grand_total =
                    Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

                  total_after_disc =
                    Enum.map(data, fn x -> Decimal.to_float(x.after_disc) end) |> Enum.sum()

                  total_sub_total =
                    Enum.map(data, fn x -> Decimal.to_float(x.sub_total) end) |> Enum.sum()

                  total_sales =
                    Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()
                    |> Float.round(2)

                  total_rounding =
                    Enum.map(data, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()

                    total_taxes =
                    Enum.map(data, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum() |> Float.round(2)

                    total_service_charge =
                    Enum.map(data, fn x -> Decimal.to_float(x.service_charge) end) |> Enum.sum()
                    |> Float.round(2)


                  total_discount = (total_grand_total-(total_sub_total+total_taxes+total_service_charge+total_rounding)) |> Float.round(2)

                  total_transaction = Enum.map(data, fn x -> x.transaction end) |> Enum.sum()


                  

                  %{
                    date: day,
                    total_sales: total_sales,
                    total_taxes: total_taxes,
                    total_discount: total_discount,
                    total_service_charge: total_service_charge,
                    total_transaction: total_transaction
                  }

                  
              end

          end
      end|>List.flatten
   


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
                rounding = Enum.map(item, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()

               
                nett_sale = grand_total - gst-rounding

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

                discounts = (grand_total-(sub_total+gst+service_charge+rounding))  |> Number.Delimit.number_to_delimited()

                nett_sales =
                 (grand_total - gst-rounding)
                  |> Number.Delimit.number_to_delimited()

                roundings =
                  Enum.map(item, fn x -> Decimal.to_float(x.rounding) end)
                  |> Enum.sum()
                  |> Float.round(2)
                  |> Number.Delimit.number_to_delimited()

                total_sales =
                  (grand_total) |> Float.round(2) |> Number.Delimit.number_to_delimited()

                pax =
                  Enum.map(item, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()
                

                transaction =
                  Enum.map(item, fn x -> x.transaction end) |> Enum.sum()
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
      discount = grand_total-(sub_total+gst+service_charge+rounding)

      d_nett_sales =
        (grand_total - gst-rounding) |> Number.Delimit.number_to_delimited()

      d_taxes =
        Enum.map(a, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum()
        |> Number.Delimit.number_to_delimited()

      d_pax = Enum.map(a, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()|>Kernel.trunc() 
      |> Number.Delimit.number_to_delimited()|>String.reverse|>String.split_at(3)|>elem(1)|>String.reverse 


      d_transaction = Enum.map(a, fn x -> x.transaction end) |> Enum.sum()|>Kernel.trunc() |> Number.Delimit.number_to_delimited()|>String.reverse|>String.split_at(3)|>elem(1)|>String.reverse 

      order_query =
        Repo.all(
          from(
            sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: sm.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"] and
                b.brand_id == ^brand_id and sm.brand_id == ^brand_id,
            group_by: [s.salesdate, b.branchname],
            select: %{sales_details: sum(sm.qty)}
          )
        )



      d_order = order_query |> Enum.map(fn x -> Decimal.to_float(x.sales_details) end) |> Enum.sum()|>Kernel.trunc() |> Number.Delimit.number_to_delimited() |>String.reverse|>String.split_at(3)|>elem(1)|>String.reverse 

      top_10_items_qty =
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
              b.id == i.brand_id and s.branchid == ^payload["branch_id"] and
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

      top_10_items_value =
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
              b.id == i.brand_id and s.branchid == ^payload["branch_id"] and
                s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                s.brand_id == ^payload["brand_id"],
            group_by: [i.itemname],
            select: %{
              itemname: i.itemname,
              value: i.itemprice,
              qty: sum(sm.qty),
            }
          )
        )


      top_10_selling =
        for item <- top_10_items_qty do
          %{name: item.itemname, y: Decimal.to_float(item.qty)}
        end

      top_10_selling_revenue =
        for item <- top_10_items_value do

             total=Decimal.to_float(item.value)*Decimal.to_float(item.qty)|>Float.round(2)
          %{y: total,name: item.itemname}
        end|>Enum.sort_by(fn x -> x.y end )|>Enum.reverse|>Enum.take(10)


      all =
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
              c.category_type != "COMBO" and c.itemcatcode != "empty" and b.id == c.brand_id and
                s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
            group_by: [c.itemcatname, s.salesdate],
            select: %{
              name: c.itemcatname,
              y: sum(sm.afterdisc)
            }
          )
        )



      combo_detail =
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
              b.id == c.brand_id and s.branchid == ^payload["branch_id"] and
                s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                s.brand_id == ^payload["brand_id"],
            group_by: [c.itemcatname, s.salesdate],
            select: %{
              name: c.itemcatname,
              y: sum(i.unit_price)
            }
          )
        )

      new_one = all ++ combo_detail

      new_one = new_one |> Enum.group_by(fn x -> x.name end)

               top_10_selling_category =
        for item <- new_one do
          y =
            item |> elem(1) |> Enum.map(fn x -> Decimal.to_float(x.y) end) |> Enum.sum()
            |> Float.round(2)

          name = item |> elem(0)

          %{name: name, y: y}
        end

     
    else
      a =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                sp.brand_id == ^brand_id and b.brand_id == ^brand_id,
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

      grp = a |> Enum.group_by(fn x -> x.salesdate end)

       year=a|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        grp_daily=for item <- year do


                  sales=Enum.filter(a,fn x -> x.salesdate.year==item end)

                  months=sales|>Enum.group_by(fn x -> x.salesdate.month end)|>Map.keys
          

            for month <- months do

  
              sales=Enum.filter(a,fn x -> x.salesdate.month==month end)

               days=sales|>Enum.group_by(fn x -> x.salesdate end)|>Map.keys
          
           
                for day <- days do

                   data=Enum.filter(a,fn x -> x.salesdate==day end)

                  

                  total_after_disc =
                    Enum.map(data, fn x -> Decimal.to_float(x.after_disc) end) |> Enum.sum()

                  total_sub_total =
                    Enum.map(data, fn x -> Decimal.to_float(x.sub_total) end) |> Enum.sum()

                  total_sales =
                    Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()
                    |> Float.round(2)

                  total_taxes =
                    Enum.map(data, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum() |> Float.round(2)

                  total_discount = (total_after_disc - total_sub_total) |> Float.round(2)

                  total_service_charge =
                    Enum.map(data, fn x -> Decimal.to_float(x.service_charge) end) |> Enum.sum()
                    |> Float.round(2)

                  total_transaction = Enum.map(data, fn x -> x.transaction end) |> Enum.sum()


                  

                  %{
                    date: day,
                    total_sales: total_sales,
                    total_taxes: total_taxes,
                    total_discount: total_discount,
                    total_service_charge: total_service_charge,
                    total_transaction: total_transaction
                  }

                  
              end

          end
      end|>List.flatten

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
                rounding = Enum.map(item, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()
                discount = after_disc - sub_total
                nett_sale = sub_total + service_charge  + discount

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

                discounts = (after_disc - sub_total) |> Number.Delimit.number_to_delimited()

                nett_sales =
                  (grand_total - gst-rounding)
                  |> Number.Delimit.number_to_delimited()

                roundings =
                  Enum.map(item, fn x -> Decimal.to_float(x.rounding) end)
                  |> Enum.sum()
                  |> Float.round(2)
                  |> Number.Delimit.number_to_delimited()

                total_sales =
                  (nett_sale + rounding + gst) |> Float.round(2) |> Number.Delimit.number_to_delimited()

                pax =
                  Enum.map(item, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()
             

                transaction =
                  Enum.map(item, fn x -> x.transaction end) |> Enum.sum()
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
      discount = after_disc - sub_total

      d_nett_sales =
        (grand_total - gst-rounding) |> Number.Delimit.number_to_delimited()

      d_taxes =
        Enum.map(a, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum()
        |> Number.Delimit.number_to_delimited()

      d_pax = Enum.map(a, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()|>Kernel.trunc() |> Number.Delimit.number_to_delimited()|>String.reverse|>String.split_at(3)|>elem(1)|>String.reverse 
      d_transaction = Enum.map(a, fn x -> x.transaction end) |> Enum.sum()|>Kernel.trunc() |> Number.Delimit.number_to_delimited()|>String.reverse|>String.split_at(3)|>elem(1)|>String.reverse 

      order_query =
        Repo.all(
          from(
            sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: sm.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                s.brand_id == ^payload["brand_id"] and b.brand_id == ^brand_id and
                sm.brand_id == ^brand_id,
            group_by: [s.salesdate, b.branchname],
            select: %{sales_details: sum(sm.qty)}
          )
        )

      d_order = order_query |> Enum.map(fn x -> Decimal.to_float(x.sales_details) end) |> Enum.sum()|>Kernel.trunc() |> Number.Delimit.number_to_delimited()|>String.reverse|>String.split_at(3)|>elem(1)|>String.reverse 

      top_10_items_qty =
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
              b.id == i.brand_id and s.salesdate >= ^payload["s_date"] and
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

      top_10_items_value =
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
              b.id == i.brand_id and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
            group_by: [i.subcatid, i.itemname],
           select: %{
              itemname: i.itemname,
              value: i.itemprice,
              qty: sum(sm.qty),
            }
          )
        )




      top_10_selling =
        for item <- top_10_items_qty do
          %{name: item.itemname, y: Decimal.to_float(item.qty)}
        end

      top_10_selling_revenue =
        for item <- top_10_items_value do

             total=Decimal.to_float(item.value)*Decimal.to_float(item.qty)
          %{y: total,name: item.itemname}
        end|>Enum.sort_by(fn x -> x.y end )|>Enum.reverse|>Enum.take(10)

      all =
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
              c.category_type != "COMBO" and c.itemcatcode != "empty" and b.id == c.brand_id and
                s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                s.brand_id == ^payload["brand_id"],
            group_by: [c.itemcatname, s.salesdate],
            select: %{
              name: c.itemcatname,
              y: sum(sm.afterdisc)
            }
          )
        )

      combo_detail =
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
              b.id == c.brand_id and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
            group_by: [c.itemcatname, s.salesdate],
            select: %{
              name: c.itemcatname,
              y: sum(i.unit_price)
            }
          )
        )

      new_one = all ++ combo_detail

      new_one = new_one |> Enum.group_by(fn x -> x.name end)

      top_10_selling_category =
        for item <- new_one do
          y =
            item |> elem(1) |> Enum.map(fn x -> Decimal.to_float(x.y) end) |> Enum.sum()
            |> Float.round(2)

          name = item |> elem(0)

          %{name: name, y: y}
        end
    end

    broadcast(socket, "dashboard", %{
      nett_sales: d_nett_sales,
      taxes: d_taxes,
      order: d_order,
      pax: d_pax,
      transaction: d_transaction,
      table_branch_daily_sales_sumary: table_branch_daily_sales_sumary,
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

    if branch_id != "0" do
      all =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where: s.branchid == ^payload["branch_id"] and s.brand_id == ^payload["brand_id"],
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
      year = a |> Enum.filter(fn x -> x.salesdate.year == String.to_integer(payload["year"]) end)

      month = year |> Enum.group_by(fn x -> x.salesdate.month end)

      yearly =
        for item <- month do
          month = item |> elem(0) |> Timex.month_name()
          data = item |> elem(1)

          grand_total =
            Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()
            |> Float.round(2)

          gst =
            Enum.map(data, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum() |> Float.round(2)

          pax =
            Enum.map(data, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum() |> Float.round(2)

          %{month: month, grand_total: grand_total, gst: gst, pax: pax}
        end
    else
      all =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            where: s.brand_id == ^payload["brand_id"],
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
      year = a |> Enum.filter(fn x -> x.salesdate.year == String.to_integer(payload["year"]) end)

      month = year |> Enum.group_by(fn x -> x.salesdate.month end)

      yearly =
        for item <- month do
          month = item |> elem(0) |> Timex.month_name()
          data = item |> elem(1)

          grand_total =
            Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()
            |> Float.round(2)

          gst =
            Enum.map(data, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum() |> Float.round(2)

          pax =
            Enum.map(data, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum() |> Float.round(2)

          %{month: month, grand_total: grand_total, gst: gst, pax: pax}
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
