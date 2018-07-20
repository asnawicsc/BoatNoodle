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

             grand_total=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.grand_total) end)|>Enum.sum|>Float.round(2)
              a=%{month: month, grand_total: grand_total}

               Map.merge(year,a)
          end
  
end|>List.flatten


       



    broadcast(socket, "sales_trend", %{sales_trend: sales_trend})
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

             count=item|>elem(1)|>Enum.count()

             grand_total=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.grand_total) end)|>Enum.sum|>Float.round(2)

             average=grand_total/count|>Float.round(2)

              a=%{month: month, grand_total: average}

               Map.merge(year,a)
          end
  
end|>List.flatten


       



    broadcast(socket, "average_daily", %{average_daily: average_daily})
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

           
             pax=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.pax) end)|>Enum.sum

              a=%{month: month, pax: pax}

               Map.merge(year,a)
          end
  
end|>List.flatten





    broadcast(socket, "pax_trend", %{pax_trend: pax_trend})
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
              count=item|>elem(1)|>Enum.count()
             pax=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.pax) end)|>Enum.sum
                 average=pax/count|>Float.round(0)
              a=%{month: month, pax: average}

               Map.merge(year,a)
          end
  
end|>List.flatten



    broadcast(socket, "average_daily_pax", %{average_daily_pax: average_daily_pax})
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
              pax=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.pax) end)|>Enum.sum
              grand_total=item|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.grand_total) end)|>Enum.sum|>Float.round(2)
              average=grand_total/pax|>Float.round(2)
              a=%{month: month, grand_total: average}

               Map.merge(year,a)
          end
  
end|>List.flatten

    broadcast(socket, "per_pax_spending_trend", %{per_pax_spending_trend: per_pax_spending_trend})
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


        a=pax_visit_trend|>Enum.map(fn x -> x.salesdate end)



    broadcast(socket, "pax_visit_trend", %{pax_visit_trend: pax_visit_trend})
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

              month=%{month: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
                              
                     grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)

                                     a=%{category: category,grand_total: grand_total}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten


            broadcast(socket, "category_trend", %{category_trend: category_trend})
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

              month=%{month: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

           

                    ass=for cat <- all_data do
                            category=cat|>elem(0)
                              if category=="F_Noodle"  do
                                                        
                     grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)

                                     a=%{category: category,grand_total: grand_total}
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

              month=%{month: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

           

                    ass=for cat <- all_data do
                            category=cat|>elem(0)
                              if category=="F_Rice"  do
                                                        
                     grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)

                                     a=%{category: category,grand_total: grand_total}
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

              month=%{month: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

           

                    ass=for cat <- all_data do
                            category=cat|>elem(0)
                              if category=="F_AddOn" or category=="Toppings"  do
                                                        
                     grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)

                                     a=%{category: category,grand_total: grand_total}
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

              month=%{month: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

           

                    ass=for cat <- all_data do
                            category=cat|>elem(0)
                              if category=="F_SideDish"  do
                                                        
                     grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)

                                     a=%{category: category,grand_total: grand_total}
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

              month=%{month: month}

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

           

                    ass=for cat <- all_data do
                            category=cat|>elem(0)
                              if category=="F_Beverages"  do
                                                        
                     grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)

                                     a=%{category: category,grand_total: grand_total}
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

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                  grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten


            broadcast(socket, "category_contribute_trend", %{category_contribute_trend: category_contribute_trend})
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




            broadcast(socket, "top_10_items_qty", %{top_10_items_qty: top_10_items_qty,top_10_items_value: top_10_items_value})
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

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,grand_total: grand_total}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten



    

            broadcast(socket, "sales_trend_by_qty", %{sales_trend_by_qty: sales_trend_by_qty})
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

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,grand_total: grand_total}
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

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,grand_total: grand_total}
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

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,grand_total: grand_total}
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

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.itemcatname end)

                    ass=for cat <- all_data do

                                  itemname=cat|>elem(0)
  
                                  grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float( x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{itemname: itemname,percentage: percentage,grand_total: grand_total}
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

    

            broadcast(socket, "sales_trend_by_rm", %{sales_trend_by_rm: sales_trend_by_rm})
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

            broadcast(socket, "compare_sales_trend_rm", %{compare_sales_trend_rm: compare_sales_trend_rm})
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

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                  grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float(x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total}
                               b= Map.merge(year,a)

                               c=Map.merge(month,b)
                   
                    end
               
            end

        end|>List.flatten

            broadcast(socket, "compare_sales_trend_qty", %{compare_sales_trend_qty: compare_sales_trend_qty})
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

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                  grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float(x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total}
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

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                  grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float(x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total}
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

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                  grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float(x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total}
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

              month=%{month: month}

              count1=item|>elem(1)|>Enum.count() 

              all_data=item|>elem(1)|>Enum.group_by(fn x -> x.category end)

                    ass=for cat <- all_data do

                                  category=cat|>elem(0)
  
                                  grand_total=cat|>elem(1)|>Enum.map(fn x ->Decimal.to_float(x.afterdisc) end)|>Enum.sum|>Float.round(2)
                                        count=cat|>elem(1)|>Enum.count() 
                                       a=count/count1
                                       percentage=a*100|>Float.round(2)

                                     a=%{category: category,percentage: percentage,grand_total: grand_total}
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
