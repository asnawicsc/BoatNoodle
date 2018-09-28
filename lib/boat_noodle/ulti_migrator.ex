defmodule BoatNoodle.UltiMigrator do
  use Task
  require IEx
  import Ecto.Query
  alias BoatNoodle.Repo
  alias BoatNoodle.BN.{SalesMaster, Sales, SalesPayment, VoidItems}

  def patch_void() do
    voids = Repo.all(from(v in VoidItems, where: v.brand_id == ^8 and is_nil(v.void_datetime)))

    for void <- voids do
      s = Repo.get_by(Sales, brand_id: 8, salesid: void.orderid)

      # Task.start_link(__MODULE__, :patch_void, [
      #   s,
      #   void
      # ])
      patch_void(s, void)
    end
  end

  def patch_void(s, void) do
    if s != nil do
      VoidItems.changeset(void, %{void_datetime: s.salesdatetime}) |> Repo.update()
    else
      find_next(void.orderid, void)
    end
  end

  def find_next(salesid, void) do
    bcode = salesid |> String.split("") |> Enum.reject(fn x -> x == "" end) |> Enum.take(4)
    whole = salesid |> String.split("") |> Enum.reject(fn x -> x == "" end)
    rem = (whole -- bcode) |> Enum.join() |> String.to_integer()
    new_id = (rem + 1) |> Integer.to_string()

    branchcode = bcode |> Enum.join()
    salesid = branchcode <> new_id

    s = Repo.get_by(Sales, brand_id: 8, salesid: salesid)

    if s != nil do
      VoidItems.changeset(void, %{void_datetime: s.salesdatetime}) |> Repo.update()
    else
      find_next(salesid, void)
    end
  end

  def init2() do
    start_date = Date.new(2018, 9, 24) |> elem(1)
    end_date = Date.new(2018, 9, 26) |> elem(1)

    sales_details =
      BoatNoodle.Repo.all(
        from(
          s in BoatNoodle.BN.Sales,
          left_join: sm in BoatNoodle.BN.SalesMaster,
          on: sm.salesid == s.salesid,
          where:
            s.salesdate > ^start_date and s.salesdate < ^end_date and s.is_void == ^0 and
              sm.is_void == ^0 and s.brand_id == ^1,
          select: %{
            staffid: s.staffid,
            branchid: s.branchid,
            sales_details: sm.sales_details,
            salesdate: s.salesdate,
            salesdatetime: s.salesdatetime,
            afterdisc: sm.afterdisc,
            nett_sales: sm.final_nett_sales
          }
        )
      )
      |> Enum.filter(fn x -> x.afterdisc != x.nett_sales end)

    branches = BoatNoodle.Repo.all(from(b in BoatNoodle.BN.Branch, where: b.brand_id == ^1))
    staffs = BoatNoodle.Repo.all(from(b in BoatNoodle.BN.Staff, where: b.brand_id == ^1))

    subcat_data =
      BoatNoodle.Repo.all(
        from(
          i in BoatNoodle.BN.ItemSubcat,
          left_join: ic in BoatNoodle.BN.ItemCat,
          on: ic.itemcatid == i.itemcatid,
          where: i.brand_id == ^1 and ic.brand_id == ^1,
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
      BoatNoodle.Repo.all(from(c in BoatNoodle.BN.ComboDetails, where: c.brand_id == ^1))

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

      populate_data(
        sales_detail.staffid,
        sales_detail.branchid,
        sales_detail.sales_details,
        sales_detail.salesdate,
        sales_detail.salesdatetime,
        subcat_data,
        combo_data,
        branches,
        staffs
      )
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
      BoatNoodle.Repo.get_by(BoatNoodle.BN.SalesMaster, brand_id: 1, sales_details: sales_details)

    params = %{}

    subcat = subcat_data |> Enum.filter(fn x -> x.itemid == sd.itemid end)

    subcat =
      if subcat == [] do
      else
        subcat |> hd()
      end

    staff = staffs |> Enum.filter(fn x -> x.staff_id == String.to_integer(staffid) end) |> hd()

    branch =
      branches |> Enum.filter(fn x -> x.branchid == String.to_integer(branchid) end) |> hd()

    l = Integer.to_string(sd.itemid) |> String.length()

    itemcode =
      cond do
        l > 6 ->
          combo = combo_data |> Enum.filter(fn x -> x.combo_item_id == sd.itemid end) |> hd()

          combo.combo_item_code

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
          combo = subcat_data |> Enum.filter(fn x -> x.itemid == sd.combo_id end) |> hd()

          Map.put(params, :combo_name, combo.itename)

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
            combo = combo_data |> Enum.filter(fn x -> x.combo_item_id == sd.itemid end) |> hd()

            Map.put(params, :itemname, combo.itename)

          l < 6 ->
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
            combo = combo_data |> Enum.filter(fn x -> x.combo_item_id == sd.itemid end) |> hd()
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

    params = Map.put(params, :staffname, staff.staff_name)

    params = Map.put(params, :branchname, branch.branchname)

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

    if l == 6 do
      Task.start_link(__MODULE__, :calculate_final_nett_sales, [
        sd
      ])

      # calculate_final_nett_sales(sd)
    end
  end

  def calculate_final_nett_sales(sd) do
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
    combo_total_topup_qty =
      sales_details
      |> Enum.filter(fn x -> x.order_price > Decimal.new(0.00) end)
      |> Enum.map(fn x -> Decimal.to_float(x.order_price) end)
      |> Enum.sum()

    # calculate total_combo_sub_item_qty
    total_combo_sub_item_qty = sales_details |> Enum.map(fn x -> x.qty end) |> Enum.sum()
    # calculate final_nett_sales

    final_nett_sales =
      sales_details
      |> Enum.map(fn x ->
        x.qty * (Decimal.to_float(x.order_price) + Decimal.to_float(x.unit_price))
      end)
      |> Enum.sum()

    BoatNoodle.BN.SalesMaster.changeset(sd, %{
      combo_total_topup_qty: combo_total_topup_qty,
      total_combo_sub_item_qty: total_combo_sub_item_qty,
      final_nett_sales: final_nett_sales
    })
    |> BoatNoodle.Repo.update()
  end

  # def compare_sales_data() do
  #   branches =
  #     BoatNoodle.Repo.all(
  #       from(b in BoatNoodle.BN.Branch, where: b.brand_id == ^1 and b.branchid != ^0)
  #     )

  #   # diff =
  #   #   for branch <- branches do
  #   #     # Task.start_link(__MODULE__, :checking, [
  #   #     #   branch
  #   #     # ])
  #   #     checking(branch)
  #   #   end
  #   #   |> List.flatten()

  #   image_path = Application.app_dir(:boat_noodle, "priv/static/images")

  #   new_path = image_path <> "/not_tally_is_void_my.csv"

  #   # for dif <- diff do
  #   #   if File.exists?(new_path) do
  #   #     data = File.read!(new_path)
  #   #     list = String.split(data, "\r\n")

  #   #     list =
  #   #       List.insert_at(list, 0, "#{dif}")
  #   #       |> Enum.map(fn x -> x <> "\r\n" end)
  #   #       |> Enum.join()

  #   #     File.write(new_path, list)
  #   #     # Enum.into(list, file)
  #   #   else
  #   #     list = []

  #   #     list =
  #   #       List.insert_at(list, 0, "#{dif}")
  #   #       |> Enum.map(fn x -> x <> "\r\n" end)
  #   #       |> Enum.join()

  #   #     File.write(new_path, list)
  #   #     # Enum.into(list, file)
  #   #   end
  #   # end

  #   bin = File.read!(new_path)

  #   salesids = bin |> String.split("\r\n")

  #   for salesid <- salesids do
  #     v1s = BoatNoodle.RepoGeop.get_by(BoatNoodle.BN.Sales_v1, salesid: salesid)
  #     v2s = BoatNoodle.Repo.get_by(BoatNoodle.BN.Sales, brand_id: 1, salesid: salesid)

  #     cg =
  #       BoatNoodle.BN.Sales.changeset(v2s, %{
  #         is_void: 1,
  #         voidreason: v1s.voidreason,
  #         void_by: v1s.void_by
  #       })

  #     case BoatNoodle.Repo.update(cg) do
  #       {:ok, v2s} ->
  #         true

  #       {:error, cg} ->
  #         IEx.pry()
  #     end
  #   end
  # end

  # def checking(branch) do
  #   s_d = NaiveDateTime.from_iso8601!("2018-08-01T00:00:01")
  #   e_d = NaiveDateTime.from_iso8601!("2018-09-18T23:59:59")

  #   data =
  #     BoatNoodle.RepoGeop.all(
  #       from(
  #         s in BoatNoodle.BN.Sales_v1,
  #         # left_join: sd in BoatNoodle.BN.SalesPayment,
  #         # on: sd.salesid == s.salesid,
  #         where:
  #           s.branchid == ^Integer.to_string(branch.branchid) and s.salesdatetime >= ^s_d and
  #             s.salesdatetime <= ^e_d and s.is_void == ^1,
  #         select: s.salesid
  #       )
  #     )

  #   data2 =
  #     BoatNoodle.Repo.all(
  #       from(
  #         s in BoatNoodle.BN.Sales,
  #         # left_join: sd in BoatNoodle.BN.SalesPayment,
  #         # on: sd.salesid == s.salesid,
  #         where:
  #           s.branchid == ^Integer.to_string(branch.branchid) and s.salesdatetime >= ^s_d and
  #             s.salesdatetime <= ^e_d and s.brand_id == ^1 and s.is_void == ^1,
  #         select: s.salesid
  #       )
  #     )

  #   diff = data -- data2
  # end
end
