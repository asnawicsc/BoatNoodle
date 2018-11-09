defmodule BoatNoodle.UltiMigrator do
  use Task
  require IEx
  import Ecto.Query
  alias BoatNoodle.Repo
  alias BoatNoodle.BN.{SalesMaster, Sales, SalesPayment, VoidItems}

  # def patch_void() do
  #   voids = Repo.all(from(v in VoidItems, where: v.brand_id == ^8 and is_nil(v.void_datetime)))

  #   for void <- voids do
  #     s = Repo.get_by(Sales, brand_id: 8, salesid: void.orderid)

  #     # Task.start_link(__MODULE__, :patch_void, [
  #     #   s,
  #     #   void
  #     # ])
  #     patch_void(s, void)
  #   end
  # end

  # def patch_void(s, void) do
  #   if s != nil do
  #     VoidItems.changeset(void, %{void_datetime: s.salesdatetime}) |> Repo.update()
  #   else
  #     find_next(void.orderid, void)
  #   end
  # end

  # def find_next(salesid, void) do
  #   bcode = salesid |> String.split("") |> Enum.reject(fn x -> x == "" end) |> Enum.take(4)
  #   whole = salesid |> String.split("") |> Enum.reject(fn x -> x == "" end)
  #   rem = (whole -- bcode) |> Enum.join() |> String.to_integer()
  #   new_id = (rem + 1) |> Integer.to_string()

  #   branchcode = bcode |> Enum.join()
  #   salesid = branchcode <> new_id

  #   s = Repo.get_by(Sales, brand_id: 8, salesid: salesid)

  #   if s != nil do
  #     VoidItems.changeset(void, %{void_datetime: s.salesdatetime}) |> Repo.update()
  #   else
  #     find_next(salesid, void)
  #   end
  # end

  def init() do
    start_date = Date.new(2018, 8, 31) |> elem(1)
    end_date = Date.new(2018, 10, 1) |> elem(1)

    sales_details =
      BoatNoodle.Repo.all(
        from(
          s in BoatNoodle.BN.Sales,
          left_join: sm in BoatNoodle.BN.SalesMaster,
          on: sm.salesid == s.salesid,
          where:
            s.salesdate > ^start_date and s.salesdate < ^end_date and s.is_void == ^0 and
              sm.is_void == ^0 and s.brand_id == ^2 and sm.combo_name == ^"Combo" and
              sm.salesid == ^"ONEU57755",
          select: %{
            staffid: s.staffid,
            branchid: s.branchid,
            sales_details: sm.sales_details,
            salesdate: s.salesdate,
            salesdatetime: s.salesdatetime,
            afterdisc: sm.afterdisc,
            nett_sales: sm.final_nett_sales,
            order_price: sm.order_price
          }
        )
      )

    branches = BoatNoodle.Repo.all(from(b in BoatNoodle.BN.Branch, where: b.brand_id == ^2))
    staffs = BoatNoodle.Repo.all(from(b in BoatNoodle.BN.Staff, where: b.brand_id == ^2))

    subcat_data =
      BoatNoodle.Repo.all(
        from(
          i in BoatNoodle.BN.ItemSubcat,
          left_join: ic in BoatNoodle.BN.ItemCat,
          on: ic.itemcatid == i.itemcatid,
          where: i.brand_id == ^2 and ic.brand_id == ^2,
          select: %{
            itename: i.itemname,
            catname: ic.itemcatname,
            cat_type: ic.category_type,
            itemid: i.subcatid,
            itemcode: i.itemcode
          }
        )
      )

    combo_data =
      BoatNoodle.Repo.all(from(c in BoatNoodle.BN.ComboDetails, where: c.brand_id == ^2))

    for sales_detail <- sales_details do
      # Task.start_link(__MODULE__, :populate_data, [
      #   sales_detail.staffid,
      #   sales_detail.branchid,
      #   sales_detail.sales_details,
      #   sales_detail.salesdate,
      #   sales_detail.salesdatetime,
      #   subcat_data,
      #   combo_data,
      #   branches,
      #   staffs
      # ])

      # populate_data(
      #   sales_detail.staffid,
      #   sales_detail.branchid,
      #   sales_detail.sales_details,
      #   sales_detail.salesdate,
      #   sales_detail.salesdatetime,
      #   subcat_data,
      #   combo_data,
      #   branches,
      #   staffs
      # )
    end
  end

  def populate_data(
        staffid,
        branchid,
        sales_details,
        salesdate,
        salesdatetime,
        subcat_data,
        combo_data,
        branches,
        staffs
      ) do
    sd =
      BoatNoodle.Repo.get_by(BoatNoodle.BN.SalesMaster, brand_id: 2, sales_details: sales_details)

    params = %{}

    subcat = subcat_data |> Enum.filter(fn x -> x.itemid == sd.itemid end)

    subcat =
      if subcat == [] do
      else
        subcat |> hd()
      end

    branch =
      branches |> Enum.filter(fn x -> x.branchid == String.to_integer(branchid) end) |> hd()

    l = Integer.to_string(sd.itemid) |> String.length()

    itemcode =
      cond do
        l > 6 ->
          combo = combo_data |> Enum.filter(fn x -> x.combo_item_id == sd.itemid end)

          if combo != [] do
            combo = combo |> hd()

            combo.combo_item_code
          else
            "UK-#{sd.salesid}"
          end

        l < 6 ->
          subcat.itemcode

        true ->
          combo = subcat_data |> Enum.filter(fn x -> x.itemid == sd.itemid end) |> hd()
          combo.itemcode
      end

    params = %{}

    params =
      cond do
        l == 6 ->
          Map.put(params, :combo_name, "Combo")

        l > 6 ->
          combo = subcat_data |> Enum.filter(fn x -> x.itemid == sd.combo_id end)

          if combo == [] do
            Map.put(params, :combo_name, "#{sd.itemid}")
          else
            combo = combo |> hd()
            Map.put(params, :combo_name, combo.itename)
          end

        l < 6 ->
          Map.put(params, :combo_name, "Ala Carte")

        true ->
          params
      end

    params =
      if sd.itemcode == nil or sd.itemcode == "" do
        cond do
          l > 6 ->
            combo = combo_data |> Enum.filter(fn x -> x.combo_item_id == sd.itemid end) |> hd()

            Map.put(params, :itemcode, combo.combo_item_code)

          l < 6 ->
            Map.put(params, :itemcode, subcat.itemcode)

          true ->
            params
        end
      else
        params
      end

    params =
      if sd.itemname == nil or sd.itemname == "" do
        cond do
          l > 6 ->
            combo = combo_data |> Enum.filter(fn x -> x.combo_item_id == sd.itemid end)

            if combo == [] do
              params
            else
              combo = combo |> hd()
              Map.put(params, :itemname, combo.combo_item_name)
            end

          l < 6 ->
            Map.put(params, :itemname, subcat.itename)

          l == 6 ->
            Map.put(params, :itemname, subcat.itename)

          true ->
            params
        end
      else
        params
      end

    params =
      cond do
        l > 6 ->
          if Decimal.to_float(sd.unit_price) == 0.0 do
            combo = combo_data |> Enum.filter(fn x -> x.combo_item_id == sd.itemid end)

            if combo != [] do
              combo = combo |> hd()
              topup = Decimal.to_float(combo.top_up) * sd.qty

              if Decimal.to_float(combo.top_up) > 0 do
                if sd.order_price |> Decimal.to_float() == topup do
                  Map.put(params, :unit_price, combo.unit_price)
                else
                  IEx.pry()
                  Map.put(params, :unit_price, combo.unit_price, order_price: topup)
                end
              else
                Map.put(params, :unit_price, combo.unit_price)
              end
            else
              IEx.pry()
              params
            end
          else
            params
          end

        l < 6 ->
          params

        true ->
          params
      end

    params =
      if sd.cat_type == nil or sd.cat_type == "" do
        subcat2 = subcat_data |> Enum.filter(fn x -> x.itemcode == itemcode end) |> hd()

        Map.put(params, :cat_type, subcat2.cat_type)
      else
        params
      end

    params =
      if sd.cat_name == nil or sd.cat_name == "" do
        subcat2 = subcat_data |> Enum.filter(fn x -> x.itemcode == itemcode end) |> hd()
        Map.put(params, :cat_name, subcat2.catname)
      else
        params
      end

    params = Map.put(params, :branchname, branch.branchname)

    staff = staffs |> Enum.filter(fn x -> x.staff_id == String.to_integer(staffid) end)

    params =
      if staff == [] do
        params
      else
        staff = staff |> hd()
        Map.put(params, :staffname, staff.staff_name)
      end

    params =
      if sd.salesdatetime == nil or sd.salesdatetime == "" do
        Map.put(params, :salesdatetime, salesdatetime)
      else
        params
      end

    params =
      if sd.salesdate == nil or sd.salesdate == "" do
        Map.put(params, :salesdate, salesdate)
      else
        params
      end

    case BoatNoodle.BN.SalesMaster.changeset(sd, params) |> BoatNoodle.Repo.update() do
      {:ok, sd} ->
        true

      {:error, params} ->
        IEx.pry()
    end

    cond do
      l == 6 ->
        # Task.start_link(__MODULE__, :calculate_final_nett_sales, [
        #   sd
        # ])

        calculate_final_nett_sales(sd)

      l < 6 ->
        Task.start_link(__MODULE__, :calculate_final_nett_sales_ala_carte, [
          sd
        ])

      # calculate_final_nett_sales_ala_carte(sd)

      l > 6 ->
        Task.start_link(__MODULE__, :calculate_final_nett_sales_combo_item, [
          sd
        ])

      true ->
        IEx.pry()
    end
  end

  def calculate_final_nett_sales_combo_item(sd) do
    sales_details =
      BoatNoodle.Repo.all(
        from(
          sm in BoatNoodle.BN.SalesMaster,
          where:
            sm.salesid == ^sd.salesid and sm.combo_id == ^sd.itemid and sm.cat_type == ^"COMBO"
        )
      )
      |> Enum.map(fn x ->
        %{
          itemid: x.itemid,
          qty: x.qty,
          order_price: x.order_price,
          unit_price: x.unit_price,
          afterdisc: x.afterdisc
        }
      end)

    # calculate combo_total_topup_qty
    combo_total_topup_qty = 0

    # calculate total_combo_sub_item_qty
    total_combo_sub_item_qty = 0
    # calculate final_nett_sales

    final_nett_sales = sd.order_price
    # sales_details
    # |> Enum.map(fn x ->
    #   x.qty * (Decimal.to_float(x.order_price) + Decimal.to_float(x.unit_price))
    # end)
    # |> Enum.sum()
    serv_charge = ((final_nett_sales |> Decimal.to_float()) * 0.1) |> Float.round(2)

    discount_value = Decimal.to_float(sd.order_price) - Decimal.to_float(sd.afterdisc)

    foc_qty =
      if discount_value == 0 do
        0
      else
        (discount_value / Decimal.to_float(sd.unit_price)) |> :erlang.trunc()
      end

    a =
      BoatNoodle.BN.SalesMaster.changeset(sd, %{
        combo_total_topup_qty: combo_total_topup_qty,
        total_combo_sub_item_qty: total_combo_sub_item_qty,
        final_nett_sales: 0,
        service_charge: serv_charge,
        discount_value: discount_value,
        foc_qty: foc_qty
      })
      |> BoatNoodle.Repo.update()

    case a do
      {:ok, sm} ->
        true

      {:error, a} ->
        IEx.pry()
    end
  end

  def calculate_final_nett_sales_ala_carte(sd) do
    sales_details =
      BoatNoodle.Repo.all(
        from(
          sm in BoatNoodle.BN.SalesMaster,
          where:
            sm.salesid == ^sd.salesid and sm.combo_id == ^sd.itemid and sm.cat_type != ^"COMBO"
        )
      )
      |> Enum.map(fn x ->
        %{
          itemid: x.itemid,
          qty: x.qty,
          order_price: x.order_price,
          unit_price: x.unit_price,
          afterdisc: x.afterdisc
        }
      end)

    # calculate combo_total_topup_qty
    combo_total_topup_qty = 0

    # calculate total_combo_sub_item_qty
    total_combo_sub_item_qty = 0
    # calculate final_nett_sales

    final_nett_sales = sd.order_price
    # sales_details
    # |> Enum.map(fn x ->
    #   x.qty * (Decimal.to_float(x.order_price) + Decimal.to_float(x.unit_price))
    # end)
    # |> Enum.sum()
    serv_charge = ((final_nett_sales |> Decimal.to_float()) * 0.1) |> Float.round(2)

    discount_value = Decimal.to_float(sd.order_price) - Decimal.to_float(sd.afterdisc)

    foc_qty =
      if discount_value == 0 do
        0
      else
        (discount_value / Decimal.to_float(sd.unit_price)) |> :erlang.trunc()
      end

    a =
      BoatNoodle.BN.SalesMaster.changeset(sd, %{
        combo_total_topup_qty: combo_total_topup_qty,
        total_combo_sub_item_qty: total_combo_sub_item_qty,
        final_nett_sales: final_nett_sales,
        service_charge: serv_charge,
        discount_value: discount_value,
        foc_qty: foc_qty
      })
      |> BoatNoodle.Repo.update()

    case a do
      {:ok, sm} ->
        true

      {:error, a} ->
        IEx.pry()
    end
  end

  def calculate_final_nett_sales(sd) do
    image_path = Application.app_dir(:boat_noodle, "priv/static/images")

    new_path = image_path <> "/not_tally_final_nett_sales_my.csv"

    sales_details =
      BoatNoodle.Repo.all(
        from(
          sm in BoatNoodle.BN.SalesMaster,
          where:
            sm.salesid == ^sd.salesid and sm.combo_id == ^sd.itemid and sm.cat_type != ^"COMBO"
        )
      )
      |> Enum.map(fn x ->
        %{
          itemid: x.itemid,
          qty: x.qty,
          order_price: x.order_price,
          unit_price: x.unit_price,
          afterdisc: x.afterdisc
        }
      end)

    sp = Repo.get_by(SalesPayment, brand_id: 2, salesid: sd.salesid)

    # calculate combo_total_topup_qty
    combo_total_topup_qty =
      sales_details
      |> Enum.uniq()
      |> Enum.filter(fn x -> x.order_price > Decimal.new(0.00) end)
      |> Enum.map(fn x -> Decimal.to_float(x.order_price) end)
      |> Enum.sum()

    # calculate total_combo_sub_item_qty
    total_combo_sub_item_qty = sales_details |> Enum.map(fn x -> x.qty end) |> Enum.sum()
    # calculate final_nett_sales

    final_nett_sales =
      sales_details
      |> Enum.uniq()
      |> Enum.map(fn x ->
        x.qty * Decimal.to_float(x.order_price)

        # x.qty * (Decimal.to_float(x.order_price) + Decimal.to_float(x.unit_price)) chiilll no need
      end)
      |> Enum.sum()

    IEx.pry()

    if Decimal.to_float(sd.order_price) > final_nett_sales do
      final_nett_sales = (sd.order_price |> Decimal.to_float()) + final_nett_sales

      serv_charge = (final_nett_sales * 0.1) |> Float.round(2)

      discount_value = Decimal.to_float(sd.order_price) - Decimal.to_float(sd.afterdisc)

      foc_qty =
        if discount_value == 0 do
          0
        else
          (discount_value / Decimal.to_float(sd.unit_price)) |> :erlang.trunc()
        end

      a =
        BoatNoodle.BN.SalesMaster.changeset(sd, %{
          combo_total_topup_qty: combo_total_topup_qty,
          total_combo_sub_item_qty: total_combo_sub_item_qty,
          final_nett_sales: final_nett_sales,
          service_charge: serv_charge,
          discount_value: discount_value,
          foc_qty: foc_qty
        })
        |> BoatNoodle.Repo.update()

      case a do
        {:ok, sm} ->
          tt =
            Repo.all(
              from(
                sm in SalesMaster,
                where:
                  sm.brand_id == ^2 and sm.salesid == ^sd.salesid and
                    sm.sales_details != ^sd.sales_details and sm.is_void == ^0,
                select: sm.final_nett_sales
              )
            )

          fin =
            if tt == [] do
              sd.order_price |> Decimal.to_float()
            else
              z =
                tt
                |> Enum.map(fn x -> Decimal.to_float(x) end)
                |> Enum.sum()

              if z != 0 do
                final_nett_sales + z
              else
                final_nett_sales
              end
            end

          if Float.round(fin, 2) != Decimal.to_float(sp.sub_total) do
            IO.inspect(sd)
            IO.inspect(final_nett_sales)
            IO.inspect(Decimal.to_float(sp.sub_total))

            if File.exists?(new_path) do
              data = File.read!(new_path)
              list = String.split(data, "\r\n")

              list =
                List.insert_at(list, 0, "#{sd.salesid}")
                |> Enum.map(fn x -> x <> "\r\n" end)
                |> Enum.join()

              File.write(new_path, list)
              # Enum.into(list, file)
            else
              list = []

              list =
                List.insert_at(list, 0, "#{sd.salesid}")
                |> Enum.map(fn x -> x <> "\r\n" end)
                |> Enum.join()

              File.write(new_path, list)
              # Enum.into(list, file)
            end
          end

          true

        {:error, a} ->
          IEx.pry()
      end
    else
      serv_charge = (final_nett_sales * 0.1) |> Float.round(2)

      discount_value = Decimal.to_float(sd.order_price) - Decimal.to_float(sd.afterdisc)

      foc_qty =
        if discount_value == 0 do
          0
        else
          (discount_value / Decimal.to_float(sd.unit_price)) |> :erlang.trunc()
        end

      a =
        BoatNoodle.BN.SalesMaster.changeset(sd, %{
          combo_total_topup_qty: combo_total_topup_qty,
          total_combo_sub_item_qty: total_combo_sub_item_qty,
          final_nett_sales: final_nett_sales,
          service_charge: serv_charge,
          discount_value: discount_value,
          foc_qty: foc_qty
        })
        |> BoatNoodle.Repo.update()

      case a do
        {:ok, sm} ->
          true

        {:error, a} ->
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
        checking_sales(branch)
      end
      |> List.flatten()

    image_path = Application.app_dir(:boat_noodle, "priv/static/images")

    new_path = image_path <> "/v1_missing_salespayment_my.csv"

    for dif <- diff do
      if File.exists?(new_path) do
        data = File.read!(new_path)
        list = String.split(data, "\r\n")

        list =
          List.insert_at(list, 0, "#{dif}")
          |> Enum.map(fn x -> x <> "\r\n" end)
          |> Enum.join()

        File.write(new_path, list)
        # Enum.into(list, file)
      else
        list = []

        list =
          List.insert_at(list, 0, "#{dif}")
          |> Enum.map(fn x -> x <> "\r\n" end)
          |> Enum.join()

        File.write(new_path, list)
        # Enum.into(list, file)
      end
    end

    # bin = File.read!(new_path)

    # salesids = bin |> String.split("\r\n")

    # for salesid <- salesids do
    #   v1s = BoatNoodle.RepoGeop.get_by(BoatNoodle.BN.Sales_v1, salesid: salesid)
    #   v2s = BoatNoodle.Repo.get_by(BoatNoodle.BN.Sales, brand_id: 1, salesid: salesid)

    #   cg =
    #     BoatNoodle.BN.Sales.changeset(v2s, %{
    #       is_void: 1,
    #       voidreason: v1s.voidreason,
    #       void_by: v1s.void_by
    #     })

    #   case BoatNoodle.Repo.update(cg) do
    #     {:ok, v2s} ->
    #       true

    #     {:error, cg} ->
    #       IEx.pry()
    #   end
    # end
  end

  def checking_sales(branch) do
    s_d = NaiveDateTime.from_iso8601!("2018-10-01T00:00:01")
    e_d = NaiveDateTime.from_iso8601!("2018-10-31T23:59:59")

    data =
      BoatNoodle.RepoGeop.all(
        from(
          s in BoatNoodle.BN.Sales_v1,
          left_join: sd in BoatNoodle.BN.SalesPayment,
          on: sd.salesid == s.salesid,
          where:
            s.branchid == ^Integer.to_string(branch.branchid) and s.salesdatetime >= ^s_d and
              s.salesdatetime <= ^e_d,
          select: sd.salesid
        )
      )

    data2 =
      BoatNoodle.Repo.all(
        from(
          s in BoatNoodle.BN.Sales,
          left_join: sd in BoatNoodle.BN.SalesPayment,
          on: sd.salesid == s.salesid,
          where:
            s.branchid == ^Integer.to_string(branch.branchid) and s.salesdatetime >= ^s_d and
              s.salesdatetime <= ^e_d and s.brand_id == ^1,
          select: sd.salesid
        )
      )

    diff = data2 -- data
  end

  def checking_sales_details(branch) do
    data =
      BoatNoodle.RepoGeop.all(
        from(
          s in BoatNoodle.BN.Sales,
          left_join: sd in BoatNoodle.BN.SalesMaster_v1,
          on: sd.salesid == s.salesid,
          where:
            s.branchid == ^Integer.to_string(branch.branchid) and s.salesdate >= ^"2018-09-01" and
              s.salesdate <= ^"2018-09-30",
          group_by: [s.branchid, sd.salesid],
          select: %{branchid: s.branchid, salesid: sd.salesid, count: count(sd.salesid)}
        )
      )

    data2 =
      BoatNoodle.Repo.all(
        from(
          s in BoatNoodle.BN.Sales,
          left_join: sd in BoatNoodle.BN.SalesMaster_v1,
          on: sd.salesid == s.salesid,
          where:
            s.branchid == ^Integer.to_string(branch.branchid) and s.salesdate >= ^"2018-09-01" and
              s.salesdate <= ^"2018-09-30" and s.brand_id == ^1,
          group_by: [s.branchid, sd.salesid],
          select: %{branchid: s.branchid, salesid: sd.salesid, count: count(sd.salesid)}
        )
      )
      |> Enum.reject(fn x -> x.salesid == nil end)

    diff = (data -- data2) |> Enum.map(fn x -> Map.put(x, :count, Integer.to_string(x.count)) end)
  end

  def v2_missing_sp() do
    image_path = Application.app_dir(:boat_noodle, "priv/static/images")

    new_path = image_path <> "/not_tally_salesid_my.csv"
    bin = File.read!(new_path)

    salesids = bin |> String.split("\n") |> Enum.reject(fn x -> x == "" end)

    for salesid <- salesids do
      # check sales exist
      v2s = BoatNoodle.Repo.get_by(BoatNoodle.BN.Sales, brand_id: 2, salesid: salesid)

      if v2s == nil do
        v1s = BoatNoodle.RepoGeop.get_by(BoatNoodle.BN.Sales, salesid: salesid)
        cg = BoatNoodle.BN.Sales.changeset(v1s, %{remark: "damien insert"})

        a = BoatNoodle.Repo.insert(cg)
      end

      v2sp = BoatNoodle.Repo.get_by(BoatNoodle.BN.SalesPayment, brand_id: 2, salesid: salesid)

      if v2sp == nil do
        # create sales payment ...
        v1sp = BoatNoodle.RepoGeop.get_by(BoatNoodle.BN.SalesPayment, salesid: salesid)

        salespay_id =
          BoatNoodle.Repo.all(
            from(
              sd in BoatNoodle.BN.SalesPayment,
              where: sd.brand_id == 2,
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

        # IEx.pry()

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

      # check sales details exist
      v2sd =
        BoatNoodle.Repo.all(
          from(sd in BoatNoodle.BN.SalesMaster,
            where: sd.brand_id == ^2 and sd.salesid == ^salesid
          )
        )

      a =
        if Enum.count(v2sd) == 0 do
          v1sds =
            BoatNoodle.RepoGeop.all(
              from(
                sd in BoatNoodle.BN.SalesMaster_v1,
                where: sd.salesid == ^salesid
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

            new_sd_id = sales_details + 101

            a =
              if v1sd.itemname == "" or v1sd.itemname == nil do
                itemname = ""

                if v1sd.itemname == "" or v1sd.itemname == nil do
                  if String.length(Integer.to_string(v1sd.itemid)) == 9 do
                    is =
                      BoatNoodle.Repo.get_by(
                        BoatNoodle.BN.ComboDetails_v1,
                        combo_item_id: v1sd.itemid
                      )

                    itemname =
                      if is != nil do
                        is.combo_item_name
                      else
                        IEx.pry()
                        ""
                      end
                  else
                    is =
                      BoatNoodle.Repo.get_by(
                        BoatNoodle.BN.ItemSubcat,
                        brand_id: 2,
                        subcatid: v1sd.itemid
                      )

                    itemname =
                      if is != nil do
                        is.itemname
                      else
                        IEx.pry()
                        ""
                      end
                  end
                end

                cg =
                  BoatNoodle.BN.SalesMaster_v1.changeset(v1sd, %{
                    itemname: itemname,
                    remark: "damien insert",
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
                  BoatNoodle.BN.SalesMaster_v1.changeset(v1sd, %{
                    remark: "damien insert",
                    sales_details: new_sd_id
                  })

                a = BoatNoodle.Repo.insert(cg)

                case a do
                  {:ok, v2sd} ->
                    true

                  {:error, cg} ->
                    IEx.pry()
                end
              end

            IEx.pry()

            # case a do
            #   {:ok, v2sd} ->
            #     true

            #   {:error, cg} ->
            #     if cg.errors == [sales_details: {"has already been taken", []}] do
            #       new_cg = cg.changes |> Map.delete(:sales_details)

            #       new_cg = BoatNoodle.BN.SalesMaster_v1.changeset(v1sd, new_cg)

            #       case BoatNoodle.Repo.insert(new_cg) do
            #         {:ok, v2sd} ->
            #           true

            #         {:error, new_cg} ->
            #           sales_details =
            #             BoatNoodle.Repo.all(
            #               from(
            #                 sd in BoatNoodle.BN.SalesMaster,
            #                 select: sd.sales_details,
            #                 limit: 1,
            #                 order_by: [desc: sd.sales_details]
            #               )
            #             )
            #             |> hd()

            #           new_sd_id = sales_details + 101

            #           new_new_cg = new_cg.changes |> Map.put(:sales_details, new_sd_id)

            #           new_new_cg = BoatNoodle.BN.SalesMaster_v1.changeset(v1sd, new_new_cg)

            #           case BoatNoodle.Repo.insert(new_new_cg) do
            #             {:ok, v2sd} ->
            #               true

            #             {:error, new_new_cg} ->
            #               IEx.pry()
            #           end
            #       end
            #     else
            #       IEx.pry()
            #     end
            # end
          end
        else
          v1sds =
            BoatNoodle.RepoGeop.all(
              from(
                sd in BoatNoodle.BN.SalesMaster_v1,
                where: sd.salesid == ^salesid
              )
            )

          if Enum.count(v1sds) != Enum.count(v2sd) do
            v2itemids = v2sd |> Enum.map(fn x -> x.itemid end) |> Enum.sort()

            v1itemids = v1sds |> Enum.map(fn x -> x.itemid end) |> Enum.sort()

            diff = v1itemids -- v2itemids

            for dif <- diff do
              v1sd = Enum.filter(v1sds, fn x -> x.itemid == dif end) |> hd()
              itemname = ""

              if v1sd.itemname == "" or v1sd.itemname == nil do
                if String.length(Integer.to_string(v1sd.itemid)) == 9 do
                  is =
                    BoatNoodle.Repo.get_by(
                      BoatNoodle.BN.ComboDetails_v1,
                      combo_item_id: v1sd.itemid
                    )

                  itemname =
                    if is != nil do
                      is.combo_item_name
                    else
                      IEx.pry()
                      ""
                    end
                else
                  is =
                    BoatNoodle.Repo.get_by(
                      BoatNoodle.BN.ItemSubcat,
                      brand_id: 2,
                      subcatid: v1sd.itemid
                    )

                  itemname =
                    if is != nil do
                      is.itemname
                    else
                      IEx.pry()
                      ""
                    end
                end

                cg =
                  BoatNoodle.BN.SalesMaster_v1.changeset(v1sd, %{
                    remark: "damien insert",
                    itemname: itemname
                  })

                a = BoatNoodle.Repo.insert(cg)
              else
                cg =
                  BoatNoodle.BN.SalesMaster_v1.changeset(v1sd, %{
                    remark: "damien insert"
                  })

                case BoatNoodle.Repo.insert(cg) do
                  {:ok, v2sd} ->
                    true

                  {:error, cg} ->
                    if cg.errors == [sales_details: {"has already been taken", []}] do
                      new_cg = cg.changes |> Map.delete(:sales_details)

                      new_cg = BoatNoodle.BN.SalesMaster_v1.changeset(v1sd, new_cg)

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

                          new_sd_id = sales_details + 101

                          new_new_cg = new_cg.changes |> Map.put(:sales_details, new_sd_id)

                          new_new_cg = BoatNoodle.BN.SalesMaster_v1.changeset(v1sd, new_new_cg)

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
            end
          end
        end
    end
  end

  def v1_missing_sp() do
    image_path = Application.app_dir(:boat_noodle, "priv/static/images")

    new_path = image_path <> "/v1_missing_salespayment_my.csv"
    bin = File.read!(new_path)

    salesids =
      bin |> String.replace("\r", "") |> String.split("\n") |> Enum.reject(fn x -> x == "" end)

    for salesid <- salesids do
      # check sales exist
      v1s = BoatNoodle.RepoGeop.get_by(BoatNoodle.BN.Sales, brand_id: 1, salesid: salesid)

      if v1s == nil do
        v2s = BoatNoodle.Repo.get_by(BoatNoodle.BN.Sales, brand_id: 1, salesid: salesid)
        cg = BoatNoodle.BN.Sales.changeset(v2s, %{remark: "damien insert"})

        a = BoatNoodle.RepoGeop.insert(cg)
      end

      v1sp = BoatNoodle.RepoGeop.get_by(BoatNoodle.BN.SalesPayment, brand_id: 1, salesid: salesid)

      if v1sp == nil do
        # create sales payment ...
        v2sp = BoatNoodle.Repo.get_by(BoatNoodle.BN.SalesPayment, brand_id: 1, salesid: salesid)

        salespay_id =
          BoatNoodle.RepoGeop.all(
            from(
              sd in BoatNoodle.BN.SalesPayment,
              where: sd.brand_id == 1,
              select: sd.salespay_id,
              limit: 1,
              order_by: [desc: sd.salespay_id]
            )
          )
          |> hd()

        new_salespay_id = salespay_id + 1

        cg =
          BoatNoodle.BN.SalesPayment.changeset(v2sp, %{
            salespay_id: new_salespay_id,
            updated_at: Timex.now()
          })

        # IEx.pry()

        case BoatNoodle.RepoGeop.insert(cg) do
          {:ok, v2sp} ->
            true

          {:error, cg} ->
            if cg.errors == [salespay_id: {"has already been taken", []}] do
              salespay_id =
                BoatNoodle.RepoGeop.all(
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
                BoatNoodle.BN.SalesPayment.changeset(v2sp, %{
                  salespay_id: new_salespay_id,
                  updated_at: Timex.now()
                })

              case BoatNoodle.RepoGeop.insert(new_cg) do
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

      # check sales details exist
      v1sd =
        BoatNoodle.RepoGeop.all(
          from(
            sd in BoatNoodle.BN.SalesMaster_v1,
            where: sd.brand_id == ^1 and sd.salesid == ^salesid
          )
        )

      a =
        if Enum.count(v1sd) == 0 do
          v2sds =
            BoatNoodle.Repo.all(
              from(
                sd in BoatNoodle.BN.SalesMaster_v1,
                where: sd.brand_id == ^1 and sd.salesid == ^salesid
              )
            )

          for v2sd <- v2sds do
            sales_details =
              BoatNoodle.RepoGeop.all(
                from(
                  sd in BoatNoodle.BN.SalesMaster_v1,
                  select: sd.sales_details,
                  limit: 1,
                  order_by: [desc: sd.sales_details]
                )
              )
              |> hd()

            new_sd_id = sales_details + 101

            a =
              if v2sd.itemname == "" or v2sd.itemname == nil do
                itemname = ""

                if v2sd.itemname == "" or v2sd.itemname == nil do
                  if String.length(Integer.to_string(v2sd.itemid)) == 9 do
                    is =
                      BoatNoodle.Repo.get_by(
                        BoatNoodle.BN.ComboDetails_v1,
                        combo_item_id: v2sd.itemid
                      )

                    itemname =
                      if is != nil do
                        is.combo_item_name
                      else
                        IEx.pry()
                        ""
                      end
                  else
                    is =
                      BoatNoodle.Repo.get_by(
                        BoatNoodle.BN.ItemSubcat,
                        brand_id: 1,
                        subcatid: v2sd.itemid
                      )

                    itemname =
                      if is != nil do
                        is.itemname
                      else
                        IEx.pry()
                        ""
                      end
                  end
                end

                cg =
                  BoatNoodle.BN.SalesMaster_v1.changeset(v2sd, %{
                    itemname: itemname,
                    remaks: "damien insert",
                    sales_details: new_sd_id
                  })

                a = BoatNoodle.RepoGeop.insert(cg)

                case a do
                  {:ok, v1sd} ->
                    true

                  {:error, cg} ->
                    IEx.pry()
                end
              else
                cg =
                  BoatNoodle.BN.SalesMaster_v1.changeset(v2sd, %{
                    remaks: "damien insert",
                    sales_details: new_sd_id
                  })

                a = BoatNoodle.RepoGeop.insert(cg)

                case a do
                  {:ok, v2sd} ->
                    true

                  {:error, cg} ->
                    IEx.pry()
                end
              end

            # case a do
            #   {:ok, v2sd} ->
            #     true

            #   {:error, cg} ->
            #     if cg.errors == [sales_details: {"has already been taken", []}] do
            #       new_cg = cg.changes |> Map.delete(:sales_details)

            #       new_cg = BoatNoodle.BN.SalesMaster_v1.changeset(v1sd, new_cg)

            #       case BoatNoodle.Repo.insert(new_cg) do
            #         {:ok, v2sd} ->
            #           true

            #         {:error, new_cg} ->
            #           sales_details =
            #             BoatNoodle.Repo.all(
            #               from(
            #                 sd in BoatNoodle.BN.SalesMaster,
            #                 select: sd.sales_details,
            #                 limit: 1,
            #                 order_by: [desc: sd.sales_details]
            #               )
            #             )
            #             |> hd()

            #           new_sd_id = sales_details + 101

            #           new_new_cg = new_cg.changes |> Map.put(:sales_details, new_sd_id)

            #           new_new_cg = BoatNoodle.BN.SalesMaster_v1.changeset(v1sd, new_new_cg)

            #           case BoatNoodle.Repo.insert(new_new_cg) do
            #             {:ok, v2sd} ->
            #               true

            #             {:error, new_new_cg} ->
            #               IEx.pry()
            #           end
            #       end
            #     else
            #       IEx.pry()
            #     end
            # end
          end
        else
          v2sds =
            BoatNoodle.Repo.all(
              from(
                sd in BoatNoodle.BN.SalesMaster_v1,
                where: sd.brand_id == ^1 and sd.salesid == ^salesid
              )
            )

          if Enum.count(v2sds) != Enum.count(v1sd) do
            v1itemids = v1sd |> Enum.map(fn x -> x.itemid end) |> Enum.sort()

            v2itemids = v2sds |> Enum.map(fn x -> x.itemid end) |> Enum.sort()

            diff = v2itemids -- v1itemids

            for dif <- diff do
              v2sd = Enum.filter(v2sds, fn x -> x.itemid == dif end) |> hd()
              itemname = ""

              if v2sd.itemname == "" or v2sd.itemname == nil do
                if String.length(Integer.to_string(v2sd.itemid)) == 9 do
                  is =
                    BoatNoodle.Repo.get_by(
                      BoatNoodle.BN.ComboDetails_v1,
                      combo_item_id: v2sd.itemid
                    )

                  itemname =
                    if is != nil do
                      is.combo_item_name
                    else
                      IEx.pry()
                      ""
                    end
                else
                  is =
                    BoatNoodle.Repo.get_by(
                      BoatNoodle.BN.ItemSubcat,
                      brand_id: 1,
                      subcatid: v2sd.itemid
                    )

                  itemname =
                    if is != nil do
                      is.itemname
                    else
                      IEx.pry()
                      ""
                    end
                end

                cg =
                  BoatNoodle.BN.SalesMaster_v1.changeset(v2sd, %{
                    remaks: "damien insert",
                    itemname: itemname
                  })

                a = BoatNoodle.Repo.insert(cg)
              else
                cg =
                  BoatNoodle.BN.SalesMaster_v1.changeset(v2sd, %{
                    remaks: "damien insert"
                  })

                case BoatNoodle.RepoGeop.insert(cg) do
                  {:ok, v1sd} ->
                    true

                  {:error, cg} ->
                    if cg.errors == [sales_details: {"has already been taken", []}] do
                      new_cg = cg.changes |> Map.delete(:sales_details)

                      new_cg = BoatNoodle.BN.SalesMaster_v1.changeset(v2sd, new_cg)

                      case BoatNoodle.RepoGeop.insert(new_cg) do
                        {:ok, v1sd} ->
                          true

                        {:error, new_cg} ->
                          sales_details =
                            BoatNoodle.RepoGeop.all(
                              from(
                                sd in BoatNoodle.BN.SalesMaster_v1,
                                select: sd.sales_details,
                                limit: 1,
                                order_by: [desc: sd.sales_details]
                              )
                            )
                            |> hd()

                          new_sd_id = sales_details + 101

                          new_new_cg = new_cg.changes |> Map.put(:sales_details, new_sd_id)

                          new_new_cg = BoatNoodle.BN.SalesMaster_v1.changeset(v2sd, new_new_cg)

                          case BoatNoodle.Repo.insert(new_new_cg) do
                            {:ok, v1sd} ->
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
            end
          end
        end
    end
  end

  def v2_missing_fp_data() do
    # image_path = Application.app_dir(:boat_noodle, "priv/static/images")

    # new_path = image_path <> "/not_tally_sp_BN2.csv"
    # bin = File.read!(new_path)

    # salesids = bin |> String.split("\n") |> Enum.reject(fn x -> x == "" end)
    start_date = Date.new(2018, 10, 1) |> elem(1)
    end_date = Date.new(2018, 11, 6) |> elem(1)

    salesids =
      BoatNoodle.RepoGeop.all(
        from(
          sm in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales_v1,
          on: s.salesid == sm.salesid,
          where:
            s.salesdate > ^start_date and s.salesdate < ^end_date and sm.payment_type_amt1 > 0,
          select: s.salesid
        )
      )

    salesids2 =
      BoatNoodle.Repo.all(
        from(
          sm in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sm.salesid,
          where:
            s.brand_id == 1 and s.salesdate > ^start_date and s.salesdate < ^end_date and
              sm.payment_type_amt1 > 0,
          select: s.salesid
        )
      )

    c = salesids -- salesids2

    for salesid <- c do
      update_payment(salesid)
    end
  end

  def update_payment(salesid) do
    # check sales exist
    v1sp = BoatNoodle.RepoGeop.get_by(BoatNoodle.BN.SalesPayment, brand_id: 1, salesid: salesid)

    v2sp = BoatNoodle.Repo.get_by(BoatNoodle.BN.SalesPayment, brand_id: 1, salesid: salesid)

    if v1sp != nil and v2sp != nil do
      cg =
        BoatNoodle.BN.SalesPayment.changeset(v2sp, %{
          payment_name1: v1sp.payment_name1,
          payment_type_amt1: v1sp.payment_type_amt1,
          payment_type_id1: v1sp.payment_type_id1,
          payment_code1: v1sp.payment_code1,
          payment_code2: v1sp.payment_code2,
          payment_type_amt2: v1sp.payment_type_amt2,
          payment_name2: v1sp.payment_name2,
          payment_type_id2: v1sp.payment_type_id2,
          voucher_code: v1sp.voucher_code
        })

      case BoatNoodle.Repo.update(cg) do
        {:ok, v2sp} ->
          true

        {:error, cg} ->
          IEx.pry()
      end
    end
  end
end
