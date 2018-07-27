defmodule BoatNoodleWeb.ReportChannel do
  use BoatNoodleWeb, :channel
  require IEx

  def join("report_channel:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("sales_trend", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

      all =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales, on: sp.salesid==s.salesid,
            left_join: b in BoatNoodle.BN.Brand,
            where: b.id==s.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
                group_by: s.salesdate,
            select: %{
              salesdate: s.salesdate,
              grand_total: sum(sp.grand_total)
            }
          )
        )|> Enum.reject(fn x -> x.salesdate == nil end)


   year=all|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

sales_trend=for item <- year do
 
 year=%{year: item}

         sales=Enum.filter(all,fn x -> x.salesdate.year==item end)

        data=sales|>Enum.group_by(fn x -> x.salesdate.month end)
         all= for item <- data do
                 month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

             grand_total1=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.grand_total) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
             grand_total=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.grand_total) end)|>Enum.sum|>Float.round(2)
              a=%{month: month,m: month, grand_total: grand_total, grand_total1: grand_total1}

               Map.merge(year,a)
          end
  
end|>List.flatten


 st_graph=for item <- sales_trend do


     %{month: item.m, grand_total: item.grand_total}
  
end


    

    broadcast(socket, "sales_trend", %{ st_graph: Poison.encode!(st_graph),sales_trend: sales_trend})
    {:noreply, socket}
  end






  def handle_in("average_daily", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

      all =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales, on: sp.salesid==s.salesid,
            left_join: b in BoatNoodle.BN.Brand,
            where: b.id==s.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
                group_by: s.salesdate,
            select: %{
              salesdate: s.salesdate,
              grand_total: sum(sp.grand_total)
            }
          )
        )|> Enum.reject(fn x -> x.salesdate == nil end)


   year=all|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

average_daily=for item <- year do
 
 year=%{year: item}

         sales=Enum.filter(all,fn x -> x.salesdate.year==item end)

        data=sales|>Enum.group_by(fn x -> x.salesdate.month end)
         all= for item <- data do
             month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."


             count=item|>elem(1)|>Enum.count()

             grand_total=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.grand_total) end)|>Enum.sum|>Float.round(2)

             average1=grand_total/count|>Float.round(2)|>Number.Delimit.number_to_delimited()
             average=grand_total/count|>Float.round(2)

              a=%{month: month_number<>month,m: month, grand_total: average, grand_total1: average1}

               Map.merge(year,a)
          end
  
end|>List.flatten

ad_graph=for item <- average_daily do


     %{month: item.m, grand_total: item.grand_total}
  
end

       



    broadcast(socket, "average_daily", %{ad_graph: Poison.encode!(ad_graph),average_daily: average_daily})
    {:noreply, socket}
  end

    def handle_in("pax_trend", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

      all =
        Repo.all(
          from(s in BoatNoodle.BN.Sales,
            left_join: b in BoatNoodle.BN.Brand,
            where: b.id==s.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
                group_by: s.salesdate,
            select: %{
              salesdate: s.salesdate,
              pax: sum(s.pax)
            }
          )
        )|> Enum.reject(fn x -> x.salesdate == nil end)


   year=all|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

pax_trend=for item <- year do
 
 year=%{year: item}

         sales=Enum.filter(all,fn x -> x.salesdate.year==item end)

        data=sales|>Enum.group_by(fn x -> x.salesdate.month end)
         all= for item <- data do
             month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

           
             pax=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.pax) end)|>Enum.sum

              a=%{month: month,m: month, pax: pax}
          

               Map.merge(year,a)
          end
  
end|>List.flatten

pt_graph=for item <- pax_trend do


     %{month: item.m, pax: item.pax}
  
end




    broadcast(socket, "pax_trend", %{pt_graph: Poison.encode!(pt_graph),pax_trend: pax_trend})
    {:noreply, socket}
  end


  def handle_in("average_daily_pax", payload, socket) do

        branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

      all =
        Repo.all(
          from(s in BoatNoodle.BN.Sales,
            left_join: b in BoatNoodle.BN.Brand,
            where: b.id==s.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
                group_by: s.salesdate,
            select: %{
              salesdate: s.salesdate,
              pax: sum(s.pax)
            }
          )
        )|> Enum.reject(fn x -> x.salesdate == nil end)


   year=all|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

average_daily_pax=for item <- year do
 
 year=%{year: item}

         sales=Enum.filter(all,fn x -> x.salesdate.year==item end)

        data=sales|>Enum.group_by(fn x -> x.salesdate.month end)
         all= for item <- data do
            month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              count=item|>elem(1)|>Enum.count()
             pax=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.pax) end)|>Enum.sum
                 average=pax/count|>Float.round(0)
             
              a=%{month: month,m: month, pax: average}
          

               Map.merge(year,a)
          end
  
end|>List.flatten

adp_graph=for item <- average_daily_pax do


     %{month: item.m, pax: item.pax}
  
end



    broadcast(socket, "average_daily_pax", %{adp_graph: Poison.encode!(adp_graph),average_daily_pax: average_daily_pax})
    {:noreply, socket}
  end


  def handle_in("per_pax_spending_trend", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

      all =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales, on: sp.salesid==s.salesid,
            left_join: b in BoatNoodle.BN.Brand,
            where: b.id==s.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
                group_by: s.salesdate,
            select: %{
              pax: sum(s.pax),
              salesdate: s.salesdate,
              grand_total: sum(sp.grand_total)
            }
          )
        )|> Enum.reject(fn x -> x.salesdate == nil end)


   year=all|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

per_pax_spending_trend=for item <- year do
 
 year=%{year: item}

         sales=Enum.filter(all,fn x -> x.salesdate.year==item end)

        data=sales|>Enum.group_by(fn x -> x.salesdate.month end)
         all= for item <- data do
             month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."
              pax=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.pax) end)|>Enum.sum
              grand_total=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.grand_total) end)|>Enum.sum|>Float.round(2)
              average1=grand_total/pax|>Float.round(2)|>Number.Delimit.number_to_delimited()
              average=grand_total/pax|>Float.round(2)
              a=%{month: month,m: month, grand_total: average, grand_total1: average1}

               Map.merge(year,a)
          end
  
end|>List.flatten



pps_graph=for item <- per_pax_spending_trend do


     %{month: item.m, grand_total: item.grand_total}
  
end


    broadcast(socket, "per_pax_spending_trend", %{pps_graph: Poison.encode!(pps_graph),per_pax_spending_trend: per_pax_spending_trend})
    {:noreply, socket}
  end


  def handle_in("pax_visit_trend", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     pax_visit_trend =
        Repo.all(
          from(s in BoatNoodle.BN.Sales,
            left_join: b in BoatNoodle.BN.Brand,
            where: b.id==s.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
                group_by: s.salesdate,
            select: %{
              salesdate: s.salesdate,
              pax: sum(s.pax)
            }
          )
        )|> Enum.reject(fn x -> x.salesdate == nil end)




     pvt_graph=for item <- pax_visit_trend do
    
     %{day: item.salesdate, pax: Decimal.to_float(item.pax)|>Float.round(0)}
  
        end

    broadcast(socket, "pax_visit_trend", %{pvt_graph: Poison.encode!(pvt_graph),pax_visit_trend: pax_visit_trend})
    {:noreply, socket}
  end

   def handle_in("category_trend", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(sm.afterdisc)
 
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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(i.unit_price)
 
            }
          )
        )



        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        category_trend=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

              month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month,m: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
                              
                     grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                      grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                     a=%{category: category,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten



  month_keys=Enum.group_by(category_trend,fn x -> x.m end)|>Map.keys

ct_graph=for month <- month_keys do

        item=Enum.filter(category_trend,fn x -> x.m==month end)

  add_on=item|>Enum.filter(fn x -> x.category=="F_AddOn" end)
  beverages=item|>Enum.filter(fn x -> x.category=="F_Beverages" end)
  noodle=item|>Enum.filter(fn x -> x.category=="F_Noodle" end)
  rice=item|>Enum.filter(fn x -> x.category=="F_Rice" end)
  sidedish=item|>Enum.filter(fn x -> x.category=="F_SideDish" end)
  toppings=item|>Enum.filter(fn x -> x.category=="Toppings" end)
  if add_on == [] do

    add_on==0.0
  else
    add_on=add_on|>hd
    add_on=add_on.grand_total
    
  end
    if beverages == [] do

    beverages==0.0
  else
    beverages=beverages|>hd
    beverages=beverages.grand_total
    
  end

  if noodle == [] do

    noodle==0.0
  else
    noodle=noodle|>hd
    noodle=noodle.grand_total
    
  end

  if rice == [] do

    rice==0.0
  else
    rice=rice|>hd
    rice=rice.grand_total
    
  end

  if sidedish == [] do

    sidedish==0.0
  else
    sidedish=sidedish|>hd
    sidedish=sidedish.grand_total
    
  end

  if toppings == [] do

    toppings==0.0
  else
    toppings=toppings|>hd
    toppings=toppings.grand_total
    
  end


%{month: month,toppings: toppings, add_on: add_on,beverages: beverages,noodle: noodle,
rice: rice,sidedish: sidedish}
  


end



            broadcast(socket, "category_trend", %{ct_graph: Poison.encode!(ct_graph),category_trend: category_trend})
    {:noreply, socket}

  
  end

   def handle_in("category_trend_noodle", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(sm.afterdisc)
 
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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(i.unit_price)
 
            }
          )
        )

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        category_trend_noodle=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

           

                    ass=for cat <- all_data do
                            category=cat|>elem(0)
                              if category=="F_Noodle"  do
                                                        
                     grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                     grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                     a=%{category: category,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                              end
                    end
               
            end

        end|>List.flatten|>Enum.reject(fn x -> x == nil end)


            broadcast(socket, "category_trend_noodle", %{category_trend_noodle: category_trend_noodle})
    {:noreply, socket}

  
  end

     def handle_in("category_trend_rice", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(sm.afterdisc)
 
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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(i.unit_price)
 
            }
          )
        )

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        category_trend_rice=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do
              month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

           

                    ass=for cat <- all_data do
                            category=cat|>elem(0)
                              if category=="F_Rice"  do
                                                        
                     grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                     grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                     a=%{category: category,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                              end
                    end
               
            end

        end|>List.flatten|>Enum.reject(fn x -> x == nil end)


            broadcast(socket, "category_trend_rice", %{category_trend_rice: category_trend_rice})
    {:noreply, socket}

  
  end


  def handle_in("category_trend_others", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(sm.afterdisc)
 
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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(i.unit_price)
 
            }
          )
        )

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        category_trend_others=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

           

                    ass=for cat <- all_data do
                            category=cat|>elem(0)
                              if category=="F_AddOn" or category=="Toppings"  do
                                                        
                     grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                     grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                     a=%{category: category,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                              end
                    end
               
            end

        end|>List.flatten|>Enum.reject(fn x -> x == nil end)


            broadcast(socket, "category_trend_others", %{category_trend_others: category_trend_others})
    {:noreply, socket}

  
  end


  def handle_in("category_trend_dessert", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(sm.afterdisc)
 
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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(i.unit_price)
 
            }
          )
        )

        new_one=all++combo_detail




          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        category_trend_dessert=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

           

                    ass=for cat <- all_data do
                            category=cat|>elem(0)
                              if category=="F_SideDish"  do
                                                        
                     grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                     grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                     a=%{category: category,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                              end
                    end
               
            end

        end|>List.flatten|>Enum.reject(fn x -> x == nil end)


            broadcast(socket, "category_trend_dessert", %{category_trend_dessert: category_trend_dessert})
    {:noreply, socket}

  
  end

  def handle_in("category_trend_beverage", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(sm.afterdisc)
 
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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(i.unit_price)
 
            }
          )
        )

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        category_trend_beverage=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

           

                    ass=for cat <- all_data do
                            category=cat|>elem(0)
                              if category=="F_Beverages"  do
                                                        
                      grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                     grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                     a=%{category: category,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                              end
                    end
               
            end

        end|>List.flatten|>Enum.reject(fn x -> x == nil end)


            broadcast(socket, "category_trend_beverage", %{category_trend_beverage: category_trend_beverage})
    {:noreply, socket}

  
  end

 def handle_in("category_contribute_trend", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(sm.afterdisc)
 
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
              salesdate: s.salesdate,
              itemcatname: c.itemcatname,
              afterdisc: sum(i.unit_price)
 
            }
          )
        )

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        category_contribute_trend=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do


                month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month,m: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                   grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                                grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                  

                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten



  month_keys=Enum.group_by(category_contribute_trend,fn x -> x.m end)|>Map.keys

cct_graph=for month <- month_keys do

        item=Enum.filter(category_contribute_trend,fn x -> x.m==month end)

  add_on=item|>Enum.filter(fn x -> x.category=="F_AddOn" end)
  beverages=item|>Enum.filter(fn x -> x.category=="F_Beverages" end)
  noodle=item|>Enum.filter(fn x -> x.category=="F_Noodle" end)
  rice=item|>Enum.filter(fn x -> x.category=="F_Rice" end)
  sidedish=item|>Enum.filter(fn x -> x.category=="F_SideDish" end)
  toppings=item|>Enum.filter(fn x -> x.category=="Toppings" end)
  if add_on == [] do

    add_on==0.0
  else
    add_on=add_on|>hd
    add_on=add_on.percentage
    
  end
    if beverages == [] do

    beverages==0.0
  else
    beverages=beverages|>hd
    beverages=beverages.percentage
    
  end

  if noodle == [] do

    noodle==0.0
  else
    noodle=noodle|>hd
    noodle=noodle.percentage
    
  end

  if rice == [] do

    rice==0.0
  else
    rice=rice|>hd
    rice=rice.percentage
    
  end

  if sidedish == [] do

    sidedish==0.0
  else
    sidedish=sidedish|>hd
    sidedish=sidedish.percentage
    
  end

  if toppings == [] do

    toppings==0.0
  else
    toppings=toppings|>hd
    toppings=toppings.percentage
    
  end


%{month: month,toppings: toppings, add_on: add_on,beverages: beverages,noodle: noodle,
rice: rice,sidedish: sidedish}
  


end



            broadcast(socket, "category_contribute_trend", %{cct_graph: Poison.encode!(cct_graph),category_contribute_trend: category_contribute_trend})
    {:noreply, socket}

  
  end


  def handle_in("top_10_items_qty", payload, socket) do

    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

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


top10_qty_chart=for item <- top_10_items_qty do

  %{names: item.itemname,qty: item.qty }
  
end


            broadcast(socket, "top_10_items_qty", %{top10_qty_chart: Poison.encode!(top10_qty_chart),top_10_items_qty: top_10_items_qty,top_10_items_value: top_10_items_value})
    {:noreply, socket}

  
  end 

   def handle_in("sales_trend_by_qty", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 1 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              afterdisc: sm.afterdisc
 
            }
          )
        )


     combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 1 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              afterdisc: i.unit_price
 
            }
          )
        )

        new_one=all++combo_detail



          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        sales_trend_by_qty=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month,m: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                                        grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten




  month_keys=Enum.group_by(sales_trend_by_qty,fn x -> x.m end)|>Map.keys

stbrn_graph=for month <- month_keys do

        item=Enum.filter(sales_trend_by_qty,fn x -> x.m==month end)


          n01=item|>Enum.filter(fn x -> x.itemname=="N01 P. Beef Thai Rice Noodle" end)
          n02=item|>Enum.filter(fn x -> x.itemname=="N02 A. Beef Thai Rice Noodle" end)
          n03=item|>Enum.filter(fn x -> x.itemname=="N03 P. Chick Thai Rice Noodle" end)
          n04=item|>Enum.filter(fn x -> x.itemname=="N04 A. Chick Thai Rice Noodle" end)
          n05=item|>Enum.filter(fn x -> x.itemname=="N05 P. Beef Thai Egg Noodle" end)
          n06=item|>Enum.filter(fn x -> x.itemname=="N06 A. Beef Thai Egg Noodle" end)
          n07=item|>Enum.filter(fn x -> x.itemname=="N07 P. Chick Thai Egg Noodle" end)
          n08=item|>Enum.filter(fn x -> x.itemname=="N08 A. Chick Thai Egg Noodle" end)
          n09=item|>Enum.filter(fn x -> x.itemname=="N09 P. Beef Springy Noodle" end)
          n10=item|>Enum.filter(fn x -> x.itemname=="N10 A. Beef Springy Noodle" end)
          n11=item|>Enum.filter(fn x -> x.itemname=="N11 P. Chick Springy  Noodle" end)
          n12=item|>Enum.filter(fn x -> x.itemname=="N12 A. Chick Springy Noodle" end)
                 
                  if n01 == [] do

                    n01=0.0
                  else
                    n01=n01|>hd
                    n01=n01.percentage
                    
                  end

                    if n02 == [] do

                    n02=0.0
                  else
                    n02=n02|>hd
                    n02=n02.percentage
                    
                  end

                  if n03 == [] do

                    n03=0.0
                  else
                    n03=n03|>hd
                    n03=n03.percentage
                    
                  end

                  if n04 == [] do

                    n04=0.0
                  else
                    n04=n04|>hd
                    n04=n04.percentage
                    
                  end

                  if n05 == [] do

                    n05=0.0
                  else
                    n05=n05|>hd
                    n05=n05.percentage
                    
                  end

                  if n06 == [] do

                    n06=0.0
                  else
                    n06=n06|>hd
                    n06=n06.percentage
                    
                  end

                    if n07 == [] do

                    n07=0.0
                  else
                    n07=n07|>hd
                    n07=n07.percentage
                    
                  end

                    if n08 == [] do

                    n08=0.0
                  else
                    n08=n08|>hd
                    n08=n08.percentage
                    
                  end

                    if n09 == [] do

                    n09=0.0
                  else
                    n09=n09|>hd
                    n09=n09.percentage
                    
                  end

                    if n10 == [] do

                    n10=0.0
                  else
                    n10=n10|>hd
                    n10=n10.percentage
                    
                  end

                    if n11 == [] do

                    n11=0.0
                  else
                    n11=n11|>hd
                    n11=n11.percentage
                    
                  end

                    if n12 == [] do

                    n12=0.0
                  else
                    n12=n12|>hd
                    n12=n12.percentage
                    
                  end


              %{month: month,
               n01: n01,
                n02: n02 ,
                n03: n03,
                n04: n04,
                n05: n05,
                n06: n06,
                n07: n07,
                n08: n08,
                n09: n09,
                n10: n10,
                n11: n11,
                n12: n12}
  


end



      broadcast(socket, "sales_trend_by_qty", %{stbrn_graph: Poison.encode!(stbrn_graph),sales_trend_by_qty: sales_trend_by_qty})
    {:noreply, socket}

  
  end

  def handle_in("sales_trend_by_qty_rice", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 2 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              afterdisc: sm.afterdisc
 
            }
          )
        )


    combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 2 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              afterdisc: i.unit_price
 
            }
          )
        )

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        sales_trend_by_qty_rice=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

              month=item|>elem(0)|> Timex.month_name()

                month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                                        grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten



    

            broadcast(socket, "sales_trend_by_qty_rice", %{sales_trend_by_qty_rice: sales_trend_by_qty_rice})
    {:noreply, socket}

  
  end


  def handle_in("sales_trend_by_qty_beverage", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 4 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              afterdisc: sm.afterdisc
 
            }
          )
        )

    combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 4 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              afterdisc: i.unit_price
 
            }
          )
        )

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        sales_trend_by_qty_beverage=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

              month=item|>elem(0)|> Timex.month_name()

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                 grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                                        grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten



    

            broadcast(socket, "sales_trend_by_qty_beverage", %{sales_trend_by_qty_beverage: sales_trend_by_qty_beverage})
    {:noreply, socket}

  
  end

    def handle_in("sales_trend_by_qty_dessert", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 3 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              afterdisc: sm.afterdisc
 
            }
          )
        )

      combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 3 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              afterdisc: i.unit_price
 
            }
          )
        )

        new_one=all++combo_detail





          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        sales_trend_by_qty_dessert=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

              month=item|>elem(0)|> Timex.month_name()

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                                        grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten



    

            broadcast(socket, "sales_trend_by_qty_dessert", %{sales_trend_by_qty_dessert: sales_trend_by_qty_dessert})
    {:noreply, socket}

  
  end

    def handle_in("sales_trend_by_qty_others", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 6  and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              afterdisc: sm.afterdisc
 
            }
          )
        )


             all2 =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 10  and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              afterdisc: sm.afterdisc
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 6 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              afterdisc: i.unit_price
 
            }
          )
        )

                combo_detail2 =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 10 and i.menu_cat_id == 6 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              afterdisc: i.unit_price
 
            }
          )
        )

       
        all=all++all2
        combo=combo_detail++combo_detail2

        new_one=all++combo


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        sales_trend_by_qty_others=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

     

                month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                                        grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

    

            broadcast(socket, "sales_trend_by_qty_others", %{sales_trend_by_qty_others: sales_trend_by_qty_others})
    {:noreply, socket}

  
  end


      def handle_in("sales_trend_by_rm", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 1 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              qty: sm.qty
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 1 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              qty: sm.qty
 
            }
          )
        )

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        sales_trend_by_rm=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month,m: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  quantity=cat|>elem(1)|>Enum.map(fn x ->x.qty end)|>Enum.sum
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,qty: quantity}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten



  month_keys=Enum.group_by(sales_trend_by_rm,fn x -> x.m end)|>Map.keys

stbqn_graph=for month <- month_keys do

        item=Enum.filter(sales_trend_by_rm,fn x -> x.m==month end)


          n01=item|>Enum.filter(fn x -> x.itemname=="N01 P. Beef Thai Rice Noodle" end)
          n02=item|>Enum.filter(fn x -> x.itemname=="N02 A. Beef Thai Rice Noodle" end)
          n03=item|>Enum.filter(fn x -> x.itemname=="N03 P. Chick Thai Rice Noodle" end)
          n04=item|>Enum.filter(fn x -> x.itemname=="N04 A. Chick Thai Rice Noodle" end)
          n05=item|>Enum.filter(fn x -> x.itemname=="N05 P. Beef Thai Egg Noodle" end)
          n06=item|>Enum.filter(fn x -> x.itemname=="N06 A. Beef Thai Egg Noodle" end)
          n07=item|>Enum.filter(fn x -> x.itemname=="N07 P. Chick Thai Egg Noodle" end)
          n08=item|>Enum.filter(fn x -> x.itemname=="N08 A. Chick Thai Egg Noodle" end)
          n09=item|>Enum.filter(fn x -> x.itemname=="N09 P. Beef Springy Noodle" end)
          n10=item|>Enum.filter(fn x -> x.itemname=="N10 A. Beef Springy Noodle" end)
          n11=item|>Enum.filter(fn x -> x.itemname=="N11 P. Chick Springy  Noodle" end)
          n12=item|>Enum.filter(fn x -> x.itemname=="N12 A. Chick Springy Noodle" end)
                 
                  if n01 == [] do

                    n01=0.0
                  else
                    n01=n01|>hd
                    n01=n01.percentage
                    
                  end

                    if n02 == [] do

                    n02=0.0
                  else
                    n02=n02|>hd
                    n02=n02.percentage
                    
                  end

                  if n03 == [] do

                    n03=0.0
                  else
                    n03=n03|>hd
                    n03=n03.percentage
                    
                  end

                  if n04 == [] do

                    n04=0.0
                  else
                    n04=n04|>hd
                    n04=n04.percentage
                    
                  end

                  if n05 == [] do

                    n05=0.0
                  else
                    n05=n05|>hd
                    n05=n05.percentage
                    
                  end

                  if n06 == [] do

                    n06=0.0
                  else
                    n06=n06|>hd
                    n06=n06.percentage
                    
                  end

                    if n07 == [] do

                    n07=0.0
                  else
                    n07=n07|>hd
                    n07=n07.percentage
                    
                  end

                    if n08 == [] do

                    n08=0.0
                  else
                    n08=n08|>hd
                    n08=n08.percentage
                    
                  end

                    if n09 == [] do

                    n09=0.0
                  else
                    n09=n09|>hd
                    n09=n09.percentage
                    
                  end

                    if n10 == [] do

                    n10=0.0
                  else
                    n10=n10|>hd
                    n10=n10.percentage
                    
                  end

                    if n11 == [] do

                    n11=0.0
                  else
                    n11=n11|>hd
                    n11=n11.percentage
                    
                  end

                    if n12 == [] do

                    n12=0.0
                  else
                    n12=n12|>hd
                    n12=n12.percentage
                    
                  end


              %{month: month,
               n01: n01,
                n02: n02 ,
                n03: n03,
                n04: n04,
                n05: n05,
                n06: n06,
                n07: n07,
                n08: n08,
                n09: n09,
                n10: n10,
                n11: n11,
                n12: n12}
  


end



            broadcast(socket, "sales_trend_by_rm", %{stbqn_graph: Poison.encode!(stbqn_graph),sales_trend_by_rm: sales_trend_by_rm})
    {:noreply, socket}

  
  end


  def handle_in("sales_trend_by_rm_rice", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 2 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              qty: sm.qty
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 2 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              qty: sm.qty
 
            }
          )
        )

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        sales_trend_by_rm_rice=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  quantity=cat|>elem(1)|>Enum.map(fn x ->x.qty end)|>Enum.sum
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,qty: quantity}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

            broadcast(socket, "sales_trend_by_rm_rice", %{sales_trend_by_rm_rice: sales_trend_by_rm_rice})
    {:noreply, socket}

  
  end


  def handle_in("sales_trend_by_rm_beverage", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 4 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              qty: sm.qty
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 4 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              qty: sm.qty
 
            }
          )
        )

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        sales_trend_by_rm_beverage=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  quantity=cat|>elem(1)|>Enum.map(fn x ->x.qty end)|>Enum.sum
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,qty: quantity}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

            broadcast(socket, "sales_trend_by_rm_beverage", %{sales_trend_by_rm_beverage: sales_trend_by_rm_beverage})
    {:noreply, socket}

  
  end


  def handle_in("sales_trend_by_rm_dessert", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 3 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              qty: sm.qty
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 3 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              qty: sm.qty
 
            }
          )
        )

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        sales_trend_by_rm_dessert=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  quantity=cat|>elem(1)|>Enum.map(fn x ->x.qty end)|>Enum.sum
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,qty: quantity}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

            broadcast(socket, "sales_trend_by_rm_dessert", %{sales_trend_by_rm_dessert: sales_trend_by_rm_dessert})
    {:noreply, socket}

  
  end

  def handle_in("sales_trend_by_rm_others", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all1 =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 6 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              qty: sm.qty
 
            }
          )
        )

             all2 =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.itemcatid == 10 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              qty: sm.qty
 
            }
          )
        )


        combo_detail1 =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 6 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              qty: sm.qty
 
            }
          )
        )

                combo_detail2 =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 10 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              qty: sm.qty
 
            }
          )
        )

        all=all1++all2
        combo_detail=combo_detail1++combo_detail2

        new_one=all++combo_detail


          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        sales_trend_by_rm_others=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  quantity=cat|>elem(1)|>Enum.map(fn x ->x.qty end)|>Enum.sum
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,qty: quantity}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

            broadcast(socket, "sales_trend_by_rm_others", %{sales_trend_by_rm_others: sales_trend_by_rm_others})
    {:noreply, socket}

  
  end


  def handle_in("compare_sales_trend_rm", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.category_type != "COMBO" and c.itemcatcode != "empty" and c.itemcatid == 1 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              qty: sm.qty,
              category: "ALA CART"
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 1 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              qty: sm.qty,
              category: "COMBO"
 
            }
          )
        )

        new_one=all++combo_detail

          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        compare_sales_trend_rm=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month,m: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                  quantity=cat|>elem(1)|>Enum.map(fn x ->x.qty end)|>Enum.sum
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,qty: quantity}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten




  month_keys=Enum.group_by(compare_sales_trend_rm,fn x -> x.m end)|>Map.keys

compare_trend_rm_graph=for month <- month_keys do

        item=Enum.filter(compare_sales_trend_rm,fn x -> x.m==month end)


          alacart=item|>Enum.filter(fn x -> x.category=="ALA CART" end)
          combo=item|>Enum.filter(fn x -> x.category=="COMBO" end)
 
                 
                  if alacart == [] do

                    alacart=0.0
                  else
                    alacart=alacart|>hd
                    alacart=alacart.percentage
                    
                  end

                    if combo == [] do

                    combo=0.0
                  else
                    combo=combo|>hd
                    combo=combo.percentage
                    
                  end

                


              %{month: month,
               alacart: alacart,
                combo: combo ,
               }
  


end

            broadcast(socket, "compare_sales_trend_rm", %{compare_trend_rm_graph: Poison.encode!(compare_trend_rm_graph),compare_sales_trend_rm: compare_sales_trend_rm})
    {:noreply, socket}

  
  end

  def handle_in("compare_sales_trend_rm_rice", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.category_type != "COMBO" and c.itemcatcode != "empty" and c.itemcatid == 2 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              qty: sm.qty,
              category: "ALA CART"
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 2 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              qty: sm.qty,
              category: "COMBO"
 
            }
          )
        )

        new_one=all++combo_detail

          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        compare_sales_trend_rm_rice=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                  quantity=cat|>elem(1)|>Enum.map(fn x ->x.qty end)|>Enum.sum
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,qty: quantity}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten





            broadcast(socket, "compare_sales_trend_rm_rice", %{compare_sales_trend_rm_rice: compare_sales_trend_rm_rice})
    {:noreply, socket}

  
  end

  def handle_in("compare_sales_trend_rm_beverage", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.category_type != "COMBO" and c.itemcatcode != "empty" and c.itemcatid == 4 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              qty: sm.qty,
              category: "ALA CART"
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 4 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              qty: sm.qty,
              category: "COMBO"
 
            }
          )
        )

        new_one=all++combo_detail

          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        compare_sales_trend_rm_beverage=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                  quantity=cat|>elem(1)|>Enum.map(fn x ->x.qty end)|>Enum.sum
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,qty: quantity}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

            broadcast(socket, "compare_sales_trend_rm_beverage", %{compare_sales_trend_rm_beverage: compare_sales_trend_rm_beverage})
    {:noreply, socket}

  
  end


    def handle_in("compare_sales_trend_rm_dessert", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.category_type != "COMBO" and c.itemcatcode != "empty" and c.itemcatid == 3 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              qty: sm.qty,
              category: "ALA CART"
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 3 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              qty: sm.qty,
              category: "COMBO"
 
            }
          )
        )

        new_one=all++combo_detail

          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        compare_sales_trend_rm_dessert=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                  quantity=cat|>elem(1)|>Enum.map(fn x ->x.qty end)|>Enum.sum
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,qty: quantity}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

            broadcast(socket, "compare_sales_trend_rm_dessert", %{compare_sales_trend_rm_dessert: compare_sales_trend_rm_dessert})
    {:noreply, socket}

  
  end

  def handle_in("compare_sales_trend_rm_others", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.category_type != "COMBO" and c.itemcatcode != "empty" and c.itemcatid == 6 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              qty: sm.qty,
              category: "ALA CART"
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 6 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              qty: sm.qty,
              category: "COMBO"
 
            }
          )
        )

        new_one=all++combo_detail

          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        compare_sales_trend_rm_others=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                  quantity=cat|>elem(1)|>Enum.map(fn x ->x.qty end)|>Enum.sum
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,qty: quantity}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten



            broadcast(socket, "compare_sales_trend_rm_others", %{compare_sales_trend_rm_others: compare_sales_trend_rm_others})
    {:noreply, socket}

  
  end
              
  def handle_in("compare_sales_trend_qty", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.category_type != "COMBO" and c.itemcatcode != "empty" and c.itemcatid == 1 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              afterdisc: sm.afterdisc,
              category: "ALA CART"
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 1 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              afterdisc: i.unit_price,
              category: "COMBO"
 
            }
          )
        )

        new_one=all++combo_detail

          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        compare_sales_trend_qty=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month,m: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)

                                  grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                                        grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                    
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten




  month_keys=Enum.group_by(compare_sales_trend_qty,fn x -> x.m end)|>Map.keys

compare_trend_qty_graph=for month <- month_keys do

        item=Enum.filter(compare_sales_trend_qty,fn x -> x.m==month end)


          alacart=item|>Enum.filter(fn x -> x.category=="ALA CART" end)
          combo=item|>Enum.filter(fn x -> x.category=="COMBO" end)
 
                 
                  if alacart == [] do

                    alacart=0.0
                  else
                    alacart=alacart|>hd
                    alacart=alacart.percentage
                    
                  end

                    if combo == [] do

                    combo=0.0
                  else
                    combo=combo|>hd
                    combo=combo.percentage
                    
                  end

                


              %{month: month,
               alacart: alacart,
                combo: combo ,
               }
  


end


            broadcast(socket, "compare_sales_trend_qty", %{compare_trend_qty_graph: Poison.encode!(compare_trend_qty_graph),compare_sales_trend_qty: compare_sales_trend_qty})
    {:noreply, socket}

  
  end 

    def handle_in("compare_sales_trend_qty_rice", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.category_type != "COMBO" and c.itemcatcode != "empty" and c.itemcatid == 2 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              afterdisc: sm.afterdisc,
              category: "ALA CART"
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 2 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              afterdisc: i.unit_price,
              category: "COMBO"
 
            }
          )
        )

        new_one=all++combo_detail

          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        compare_sales_trend_qty_rice=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month_number<>month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                               grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                                        grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                    
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

            broadcast(socket, "compare_sales_trend_qty_rice", %{compare_sales_trend_qty_rice: compare_sales_trend_qty_rice})
    {:noreply, socket}

  
  end 


  def handle_in("compare_sales_trend_qty_beverage", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.category_type != "COMBO" and c.itemcatcode != "empty" and c.itemcatid == 4 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              afterdisc: sm.afterdisc,
              category: "ALA CART"
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 4 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              afterdisc: i.unit_price,
              category: "COMBO"
 
            }
          )
        )

        new_one=all++combo_detail

          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        compare_sales_trend_qty_beverage=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month_number<>month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                      grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                                        grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                    
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

            broadcast(socket, "compare_sales_trend_qty_beverage", %{compare_sales_trend_qty_beverage: compare_sales_trend_qty_beverage})
    {:noreply, socket}

  
  end

    def handle_in("compare_sales_trend_qty_dessert", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.category_type != "COMBO" and c.itemcatcode != "empty" and c.itemcatid == 3 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              afterdisc: sm.afterdisc,
              category: "ALA CART"
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 3 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              afterdisc: i.unit_price,
              category: "COMBO"
 
            }
          )
        )

        new_one=all++combo_detail

          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        compare_sales_trend_qty_dessert=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month_number<>month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                   grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                                        grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                    
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

            broadcast(socket, "compare_sales_trend_qty_dessert", %{compare_sales_trend_qty_dessert: compare_sales_trend_qty_dessert})
    {:noreply, socket}

  
  end


      def handle_in("compare_sales_trend_qty_others", payload, socket) do

     branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand=Repo.get_by(Brand,id: brand_id)

     all =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat, on: sm.itemid==i.subcatid,
            left_join: c in BoatNoodle.BN.ItemCat, on: i.itemcatid==c.itemcatid,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: c.category_type != "COMBO" and c.itemcatcode != "empty" and c.itemcatid == 6 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.itemname,
              subcatid: i.subcatid,
              afterdisc: sm.afterdisc,
              category: "ALA CART"
 
            }
          )
        )


        combo_detail =
        Repo.all(
          from(sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,  on: sm.salesid==s.salesid,
            left_join: i in BoatNoodle.BN.ComboDetails, on: sm.itemid==i.combo_item_id,
            left_join: b in BoatNoodle.BN.Brand, on: b.id==^brand.id,     
            where: i.menu_cat_id == 6 and b.id==i.brand_id and s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id==^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              itemcatname: i.combo_item_name,
              afterdisc: i.unit_price,
              category: "COMBO"
 
            }
          )
        )

        new_one=all++combo_detail

          year=new_one|> Enum.group_by(fn x -> x.salesdate.year end)|>Map.keys

        


        compare_sales_trend_qty_others=for item <- year do

                  year=%{year: item}

                  sales=Enum.filter(new_one,fn x -> x.salesdate.year==item end)

                  pax_visit_trend=sales|>Enum.group_by(fn x -> x.salesdate.month end)
          

            for item <- pax_visit_trend do

                 month=item|>elem(0)|> Timex.month_name()
              month=item|>elem(0)|> Timex.month_name()
             month_number=item|>elem(0)|>Integer.to_string
             month_number=month_number<>"."

              month=%{month: month_number<>month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                    grand_total1=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)|>Number.Delimit.number_to_delimited()
                                        grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                    
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total,grand_total1: grand_total1}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

            broadcast(socket, "compare_sales_trend_qty_others", %{compare_sales_trend_qty_others: compare_sales_trend_qty_others})
    {:noreply, socket}

  
  end             
              
       


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
