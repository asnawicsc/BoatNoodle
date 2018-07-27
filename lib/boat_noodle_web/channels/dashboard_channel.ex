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

    brand=Repo.get_by(Brand,id: brand_id)


    all=Repo.all(from sp in BoatNoodle.BN.SalesPayment,
    left_join: s in BoatNoodle.BN.Sales,on: sp.salesid==s.salesid,
    left_join: b in BoatNoodle.BN.Branch, on: b.branchid== s.branchid,
    left_join: sm in BoatNoodle.BN.SalesMaster, on: sm.salesid== s.salesid,
    where:  s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
    s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
    group_by: [s.salesdate],
    select: %{salesdate: s.salesdate,
              order: count(sm.sales_details),
              pax: sum(s.pax),
              branchname: b.branchname,
              grand_total: sum(sp.grand_total),
              service_charge: sum(sp.service_charge),
              gst: sum(sp.gst_charge),
              after_disc: sum(sp.after_disc),
              transaction: count(s.salesid),
              sub_total: sum(sp.sub_total),
              rounding: sum(sp.rounding)})

     branch_daily_sales_sumary=
     for item <- all do
      order=item.order
      transaction=item.transaction
      after_disc=Decimal.to_float(item.after_disc)
      sub_total=Decimal.to_float(item.sub_total)
      service_charge= Decimal.to_float(item.service_charge)
      gst= Decimal.to_float(item.gst)
      roundings= Decimal.to_float(item.rounding)
      pax= Decimal.to_float(item.pax)
      discount=after_disc-sub_total|>Float.round(2)
      nett_sales=sub_total+service_charge+gst-discount|>Float.round(2)
      total_sales= nett_sales+roundings|>Float.round(2)
      %{salesdate: item.salesdate,
        branchname: item.branchname,
        sub_total: sub_total,
        service_charge: service_charge,
        gst: gst,
        discount: discount,
        nett_sales: nett_sales,
        roundings: roundings,
        total_sales: total_sales,
        pax: pax,
        order: order,
        transaction: transaction
        }
       
   end

   IEx.pry


     branchname=Enum.map(branch_daily_sales_sumary,fn x -> x.branchname end)|>Enum.uniq|>hd
     gross_sales=Enum.map(branch_daily_sales_sumary,fn x -> x.sub_total end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
     service_charge=Enum.map(branch_daily_sales_sumary,fn x -> x.service_charge end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
     taxes=Enum.map(branch_daily_sales_sumary,fn x -> x.gst end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
     discount=Enum.map(branch_daily_sales_sumary,fn x -> x.discount end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
     nett_sales=Enum.map(branch_daily_sales_sumary,fn x -> x.nett_sales end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
     roundings=Enum.map(branch_daily_sales_sumary,fn x -> x.roundings end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
     total_sales=Enum.map(branch_daily_sales_sumary,fn x -> x.total_sales end)|>Enum.sum|>Float.round(2)
     order=Enum.map(branch_daily_sales_sumary,fn x -> x.order end)|>Enum.sum

     pax=Enum.map(branch_daily_sales_sumary,fn x -> x.pax end)|>Enum.sum

     transaction=Enum.map(branch_daily_sales_sumary,fn x -> x.transaction end)|>Enum.sum

     table=[%{branchname: branchname,gross_sales: gross_sales ,service_charge: service_charge,
     taxes: taxes,discount: discount,nett_sales: nett_sales,roundings: roundings,total_sales: total_sales,pax: pax}]


     top_10_items_qty =
        Repo.all(
          from sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales, on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,
            where: b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
                group_by: [i.subcatid,i.itemname],
            select: %{
              id: i.subcatid,
              itemname: i.itemname,
              qty: sum(sm.qty)
             
            },
             order_by: [desc: sum(sm.qty)],limit: 10)



        top_10_items_value =
        Repo.all(
          from sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales, on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
           left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,
            where: b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
                group_by: [i.subcatid,i.itemname],
            select: %{
              id: i.subcatid,
              itemname: i.itemname,
              value: sum(sm.afterdisc)
             
            },
             order_by: [desc: sum(sm.afterdisc)],limit: 10)


top_10_selling=for item <- top_10_items_qty do

  %{name: item.itemname,y: Decimal.to_float(item.qty)}
  
        end

        top_10_selling_revenue=for item <- top_10_items_value do

  %{name: item.itemname,y: Decimal.to_float(item.value)}
  
        end



             all =
        Repo.all(
           from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
             left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,      
            where: c.category_type != "COMBO" and c.itemcatcode != "empty" and b.id==c.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
                group_by: [c.itemcatname,s.salesdate],
            select: %{
             
              name: c.itemcatname,
              y: sum(sm.afterdisc)
 
            }
          )
        )




             combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.menu_cat_id==c.itemcatid, 
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where:  b.id==c.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
                  group_by: [c.itemcatname,s.salesdate],
            select: %{
           
              name: c.itemcatname,
              y: sum(i.unit_price)
 
            }
          )
        )



        new_one=all++combo_detail

        new_one=new_one|>Enum.group_by(fn x -> x.name end)

        top_10_selling_category=for item <- new_one do

          y=item|>elem(1)|>Enum.map(fn x -> Decimal.to_float(x.y) end)|>Enum.sum|>Float.round(2)
          name=item|>elem(0)


          %{name: name, y: y}

       
        end


 broadcast(socket, "dashboard", %{table: table,nett_sales: nett_sales,taxes: taxes, order: order,
  pax: pax,transaction: transaction,branch_daily_sales_sumary: Poison.encode!(branch_daily_sales_sumary),
  top_10_selling: Poison.encode!(top_10_selling),top_10_selling_revenue: Poison.encode!(top_10_selling_revenue),
  top_10_selling_category: Poison.encode!(top_10_selling_category)})
    {:noreply, socket}
  end


 def handle_in("year", payload, socket) do

  year=payload["year"]

   all=Repo.all(from sp in BoatNoodle.BN.SalesPayment,
                                        left_join: s in BoatNoodle.BN.Sales,on: sp.salesid==s.salesid,
                                        left_join: b in BoatNoodle.BN.Branch, on: b.branchid== s.branchid,
                                        where:  s.branchid == ^payload["branch_id"]  and s.brand_id==^payload["brand_id"],
                                        group_by: [s.salesdate],
                                        select: %{salesdate: s.salesdate,
                                                  pax: sum(s.pax),
                                                  grand_total: sum(sp.grand_total),
                                                  gst: sum(sp.gst_charge),
                                                 })
a=all|>Enum.reject(fn x -> x.salesdate == nil end)
year=a|>Enum.filter(fn x -> x.salesdate.year == String.to_integer(payload["year"]) end)

 month=year|>Enum.group_by(fn x -> x.salesdate.month end)


  yearly=for item <- month do

    month=item|>elem(0)|>Timex.month_name()
    data=item|>elem(1)
  
  grand_total=Enum.map(data,fn x -> Decimal.to_float(x.grand_total) end)|>Enum.sum|>Float.round(2)
  gst=Enum.map(data,fn x -> Decimal.to_float(x.gst) end)|>Enum.sum|>Float.round(2)
  pax=Enum.map(data,fn x -> Decimal.to_float(x.pax) end)|>Enum.sum|>Float.round(2)

  %{month: month,grand_total: grand_total,gst: gst,pax: pax}



end



 broadcast(socket, "yearly", %{yearly: Poison.encode!(yearly)})
    {:noreply, socket}

  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
