defmodule BoatNoodle.UltiMigrator do
  use Task
  require IEx
  import Ecto.Query

  def redo_insert_sd(v1sd) do
    sales_details =
      BoatNoodle.Repo.all(
        from(
          sd in BoatNoodle.BN.SalesMaster,
          select: sd.sales_details,
          limit: 1,
          order_by: [desc: sd.sales_details]
        )
      )
      |> hd()

    new_sd_id = sales_details + 1

    itemname =
      if v1sd.itemname == "" or v1sd.itemname == nil do
        is =
          BoatNoodle.Repo.get_by(
            BoatNoodle.BN.ItemSubcat,
            brand_id: 1,
            subcatid: v1sd.itemid
          )

        if is != nil do
          is.itemname
        else
          if v1sd.itemid |> Integer.to_string() |> String.length() == 9 do
            cd =
              BoatNoodle.RepoGeop.get_by(
                BoatNoodle.BN.ComboDetails_v1,
                combo_item_id: v1sd.itemid
              )

            cd.combo_item_name
          else
            IEx.pry()
          end
        end
      else
        v1sd.itemname
      end

    cg =
      BoatNoodle.BN.SalesMaster.changeset(v1sd, %{
        itemname: itemname,
        remaks: "damien insert",
        sales_details: new_sd_id
      })

    a = BoatNoodle.Repo.insert(cg)

    case a do
      {:ok, v2sd} ->
        true

      {:error, cg} ->
        if cg.errors == [sales_details: {"has already been taken", []}] do
          redo_insert_sd(v1sd)
        else
          IEx.pry()
        end
    end
  end

  def compare_sales_data() do
    branches =
      BoatNoodle.Repo.all(
        from(b in BoatNoodle.BN.Branch, where: b.brand_id == ^1 and b.branchid != ^0)
      )

    diff =
      for branch <- branches do
        # Task.start_link(__MODULE__, :checking, [
        #   branch
        # ])
        checking(branch)
      end
      |> List.flatten()

    image_path = Application.app_dir(:boat_noodle, "priv/static/images")

    new_path = image_path <> "/not_tally_sp_BN2.csv"

    for dif <- diff do
      if File.exists?(new_path) do
        data = File.read!(new_path)
        list = String.split(data, "\r\n")

        list =
          List.insert_at(list, 0, "#{dif.salesid}")
          |> Enum.map(fn x -> x <> "\r\n" end)
          |> Enum.join()

        File.write(new_path, list)
        # Enum.into(list, file)
      else
        list = []

        list =
          List.insert_at(list, 0, "#{dif.salesid}")
          |> Enum.map(fn x -> x <> "\r\n" end)
          |> Enum.join()

        File.write(new_path, list)
        # Enum.into(list, file)
      end
    end
  end

  def checking(branch) do
    data =
      BoatNoodle.RepoGeop.all(
        from(
          s in BoatNoodle.BN.Sales,
          left_join: sd in BoatNoodle.BN.SalesPayment,
          on: sd.salesid == s.salesid,
          where:
            s.branchid == ^Integer.to_string(branch.branchid) and s.salesdate >= ^"2018-09-01" and
              s.salesdate <= ^"2018-09-18",
          group_by: [s.branchid, sd.salesid],
          select: %{branchid: s.branchid, salesid: sd.salesid, count: count(sd.salesid)}
        )
      )

    data2 =
      BoatNoodle.Repo.all(
        from(
          s in BoatNoodle.BN.Sales,
          left_join: sd in BoatNoodle.BN.SalesPayment,
          on: sd.salesid == s.salesid,
          where:
            s.branchid == ^Integer.to_string(branch.branchid) and s.salesdate >= ^"2018-09-01" and
              s.salesdate <= ^"2018-09-18" and s.brand_id == ^1,
          group_by: [s.branchid, sd.salesid],
          select: %{branchid: s.branchid, salesid: sd.salesid, count: count(sd.salesid)}
        )
      )
      |> Enum.reject(fn x -> x.salesid == nil end)

    diff = (data -- data2) |> Enum.map(fn x -> Map.put(x, :count, Integer.to_string(x.count)) end)
  end

  def v2_missing_sp() do
    image_path = Application.app_dir(:boat_noodle, "priv/static/images")

    new_path = image_path <> "/not_tally_sp_BN2.csv"
    bin = File.read!(new_path)

    salesids = bin |> String.split("\n")

    for salesid <- salesids do
      # check sales exist
      v2s = BoatNoodle.Repo.get_by(BoatNoodle.BN.Sales, brand_id: 1, salesid: salesid)

      if v2s == nil do
        v1s = BoatNoodle.RepoGeop.get_by(BoatNoodle.BN.Sales, brand_id: 1, salesid: salesid)

        if v1s == nil do
          IEx.pry()
        end

        cg = BoatNoodle.BN.Sales.changeset(v1s, %{remark: "damien insert"})

        a = BoatNoodle.Repo.insert(cg)
      end

      # check sales details exist
      v2sd =
        BoatNoodle.Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            where: sd.brand_id == ^1 and sd.salesid == ^salesid
          )
        )

      if Enum.count(v2sd) == 0 do
        v1sds =
          BoatNoodle.RepoGeop.all(
            from(
              sd in BoatNoodle.BN.SalesMaster,
              where: sd.brand_id == ^1 and sd.salesid == ^salesid
            )
          )

        for v1sd <- v1sds do
          sales_details =
            BoatNoodle.Repo.all(
              from(
                sd in BoatNoodle.BN.SalesMaster,
                select: sd.sales_details,
                limit: 1,
                order_by: [desc: sd.sales_details]
              )
            )
            |> hd()

          new_sd_id = sales_details + 1

          if v1sd.itemname == "" or v1sd.itemname == nil do
            is =
              BoatNoodle.Repo.get_by(
                BoatNoodle.BN.ItemSubcat,
                brand_id: 1,
                subcatid: v1sd.itemid
              )

            itemname =
              if is != nil do
                is.itemname
              else
                if v1sd.itemid |> Integer.to_string() |> String.length() == 9 do
                  cd =
                    BoatNoodle.RepoGeop.get_by(
                      BoatNoodle.BN.ComboDetails_v1,
                      combo_item_id: v1sd.itemid
                    )

                  if cd == nil do
                    IEx.pry()
                  end

                  cd.combo_item_name
                else
                  IEx.pry()
                end
              end

            cg =
              BoatNoodle.BN.SalesMaster.changeset(v1sd, %{
                itemname: itemname,
                remaks: "damien insert",
                sales_details: new_sd_id
              })

            a = BoatNoodle.Repo.insert(cg)

            case a do
              {:ok, v2sd} ->
                true

              {:error, cg} ->
                IEx.pry()
            end
          else
            cg =
              BoatNoodle.BN.SalesMaster.changeset(v1sd, %{
                remaks: "damien insert",
                sales_details: new_sd_id
              })

            a = BoatNoodle.Repo.insert(cg)

            case a do
              {:ok, v2sd} ->
                true

              {:error, cg} ->
                if cg.errors == [sales_details: {"has already been taken", []}] do
                  redo_insert_sd(v1sd)
                else
                  IEx.pry()
                end
            end
          end

          case a do
            {:ok, v2sd} ->
              true

            {:error, cg} ->
              if cg.errors == [sales_details: {"has already been taken", []}] do
                new_cg = cg.changes |> Map.delete(:sales_details)

                new_cg = BoatNoodle.BN.SalesMaster.changeset(v1sd, new_cg)

                case BoatNoodle.Repo.insert(new_cg) do
                  {:ok, v2sd} ->
                    true

                  {:error, new_cg} ->
                    sales_details =
                      BoatNoodle.Repo.all(
                        from(
                          sd in BoatNoodle.BN.SalesMaster,
                          select: sd.sales_details,
                          limit: 1,
                          order_by: [desc: sd.sales_details]
                        )
                      )
                      |> hd()

                    new_sd_id = sales_details + 1

                    new_new_cg = new_cg.changes |> Map.put(:sales_details, new_sd_id)

                    new_new_cg = BoatNoodle.BN.SalesMaster.changeset(v1sd, new_new_cg)

                    case BoatNoodle.Repo.insert(new_new_cg) do
                      {:ok, v2sd} ->
                        true

                      {:error, new_new_cg} ->
                        IEx.pry()
                    end
                end
              else
                IEx.pry()
              end
          end
        end
      else
        v1sds =
          BoatNoodle.RepoGeop.all(
            from(
              sd in BoatNoodle.BN.SalesMaster,
              where: sd.brand_id == ^1 and sd.salesid == ^salesid
            )
          )

        if Enum.count(v1sds) != Enum.count(v2sd) do
          v2itemids = v2sd |> Enum.map(fn x -> x.itemid end) |> Enum.sort()

          v1itemids = v1sds |> Enum.map(fn x -> x.itemid end) |> Enum.sort()

          diff = v1itemids -- v2itemids

          for dif <- diff do
            v1sd = Enum.filter(v1sds, fn x -> x.itemid == dif end) |> hd()

            if v1sd.itemname == "" or v1sd.itemname == nil do
              is =
                BoatNoodle.Repo.get_by(
                  BoatNoodle.BN.ItemSubcat,
                  brand_id: 1,
                  subcatid: v1sd.itemid
                )

              itemname =
                if is != nil do
                  is.itemname
                else
                  if v1sd.itemid |> Integer.to_string() |> String.length() == 9 do
                    cd =
                      BoatNoodle.RepoGeop.get_by(
                        BoatNoodle.BN.ComboDetails_v1,
                        combo_item_id: v1sd.itemid
                      )

                    if cd == nil do
                      IEx.pry()
                    end

                    cd.combo_item_name
                  else
                    IEx.pry()
                  end
                end

              cg =
                BoatNoodle.BN.SalesMaster.changeset(v1sd, %{
                  remaks: "damien insert",
                  itemname: itemname
                })

              a = BoatNoodle.Repo.insert(cg)
            else
              cg =
                BoatNoodle.BN.SalesMaster.changeset(v1sd, %{
                  remaks: "damien insert"
                })

              case BoatNoodle.Repo.insert(cg) do
                {:ok, v2sd} ->
                  true

                {:error, cg} ->
                  if cg.errors == [sales_details: {"has already been taken", []}] do
                    new_cg = cg.changes |> Map.delete(:sales_details)

                    new_cg = BoatNoodle.BN.SalesMaster.changeset(v1sd, new_cg)

                    case BoatNoodle.Repo.insert(new_cg) do
                      {:ok, v2sd} ->
                        true

                      {:error, new_cg} ->
                        sales_details =
                          BoatNoodle.Repo.all(
                            from(
                              sd in BoatNoodle.BN.SalesMaster,
                              select: sd.sales_details,
                              limit: 1,
                              order_by: [desc: sd.sales_details]
                            )
                          )
                          |> hd()

                        new_sd_id = sales_details + 1

                        new_new_cg = new_cg.changes |> Map.put(:sales_details, new_sd_id)

                        new_new_cg = BoatNoodle.BN.SalesMaster.changeset(v1sd, new_new_cg)

                        case BoatNoodle.Repo.insert(new_new_cg) do
                          {:ok, v2sd} ->
                            true

                          {:error, new_new_cg} ->
                            redo_insert_sd(v1sd)
                        end
                    end
                  else
                    IEx.pry()
                  end
              end
            end
          end
        end
      end

      v2sp = BoatNoodle.Repo.get_by(BoatNoodle.BN.SalesPayment, brand_id: 1, salesid: salesid)

      if v2sp == nil do
        # create sales payment ...
        v1sp =
          BoatNoodle.RepoGeop.get_by(BoatNoodle.BN.SalesPayment, brand_id: 1, salesid: salesid)

        if v1sp == nil do
          IEx.pry()
        end

        salespay_id =
          BoatNoodle.Repo.all(
            from(
              sd in BoatNoodle.BN.SalesPayment,
              select: sd.salespay_id,
              limit: 1,
              order_by: [desc: sd.salespay_id]
            )
          )
          |> hd()

        new_salespay_id = salespay_id + 1

        cg =
          BoatNoodle.BN.SalesPayment.changeset(v1sp, %{
            salespay_id: new_salespay_id,
            updated_at: Timex.now()
          })

        case BoatNoodle.Repo.insert(cg) do
          {:ok, v2sp} ->
            true

          {:error, cg} ->
            if cg.errors == [salespay_id: {"has already been taken", []}] do
              salespay_id =
                BoatNoodle.Repo.all(
                  from(
                    sd in BoatNoodle.BN.SalesPayment,
                    select: sd.salespay_id,
                    limit: 1,
                    order_by: [desc: sd.salespay_id]
                  )
                )
                |> hd()

              new_salespay_id = salespay_id + 1

              new_cg =
                BoatNoodle.BN.SalesPayment.changeset(v1sp, %{
                  salespay_id: new_salespay_id,
                  updated_at: Timex.now()
                })

              case BoatNoodle.Repo.insert(new_cg) do
                {:ok, v2sp} ->
                  true

                {:error, new_cg} ->
                  IEx.pry()
              end
            else
              IEx.pry()
            end
        end
      end
    end
  end
end
