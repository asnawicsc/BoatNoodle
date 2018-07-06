defmodule BoatNoodleWeb.UserChannel do
  use BoatNoodleWeb, :channel
  require IEx
  alias BoatNoodle.Images
  alias BoatNoodle.Images.{Gallery, Picture}

  def join("user:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("find_organization", %{"name" => name}, socket) do
    name = name |> String.replace("#", "")

    organization = Repo.get_by(Organization, organisationname: name)

    name = organization.organisationname
    address = organization.address
    phone = organization.phone
    country = organization.country
    registernumber = organization.orgregid
    gstregisternumber = organization.gst_reg_id
    organizationid = organization.organisationid

    broadcast(socket, "display_organization_details", %{
      name: name,
      address: address,
      phone: phone,
      country: country,
      registernumber: registernumber,
      gstregisternumber: gstregisternumber,
      organizationid: organizationid
    })

    {:noreply, socket}
  end

  def handle_in("load_user_sidebar", %{"userid" => userid}, socket) do
    user = Repo.get(User, userid)

    map =
      if user.gall_id != 1 do
        gallery = Repo.get(Gallery, user.gall_id)
        picture = Repo.get_by(Picture, file_type: "profile_picture", gallery_id: gallery.id)
        %{name: user.username, bin: picture.bin}
      else
        path = File.cwd!() <> "/media/demo.png"
        {:ok, bin} = File.read(path)
        bin = Base.encode64(bin)
        %{name: user.username, bin: bin}
      end

    broadcast(socket, "save_user_local_storage", %{map: Poison.encode!(map)})
    {:noreply, socket}
  end

  def handle_in("generate_all_branch_sales_data", payload, socket) do
    branches =
      Repo.all(
        from(
          b in BoatNoodle.BN.Branch,
          where: b.brand_id == ^payload["brand_id"],
          select: %{name: b.branchname, id: b.branchid}
        )
      )

    map =
      for branch <- branches do
        sales_data(branch.name, Integer.to_string(branch.id))
      end
      |> Enum.sort_by(fn x -> x.grand_total end)
      |> Enum.reverse()
      |> Enum.reject(fn x -> x.grand_total == 0.00 end)

    broadcast(socket, "save_local_storage", %{map: Poison.encode!(map)})
    {:noreply, socket}
  end

  defp sales_data(branch_name, branch_id) do
    s_date = Timex.beginning_of_month(Date.utc_today())
    e_date = Timex.end_of_month(Date.utc_today())

    total_transaction =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: sp.salesid == s.salesid,
          where: s.branchid == ^branch_id and s.salesdate >= ^s_date and s.salesdate <= ^e_date,
          select: %{
            gst_charge: sp.gst_charge,
            grand_total: sp.grand_total,
            salesid: s.salesid,
            pax: s.pax
          }
        )
      )

    res = total_transaction |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

    if res == 0 do
      res = 0.00
    else
      res = res |> Float.round(2)
    end

    %{branch_name: branch_name, grand_total: res}
  end

  def handle_in("dashboard", payload, socket) do
    branchid = payload["branch_id"]

    if branchid == "0" do
      total_order =
        Repo.all(
          from(
            sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sm.salesid,
            where: s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
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
            select: %{
              gst_charge: sp.gst_charge,
              grand_total: sp.grand_total,
              salesid: s.salesid,
              pax: s.pax
            }
          )
        )
    else
      total_order =
        Repo.all(
          from(
            sm in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sm.salesid,
            where:
              s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"],
            select: %{orderid: sm.orderid}
          )
        )

      total_transaction =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            where:
              s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"],
            select: %{
              gst_charge: sp.gst_charge,
              grand_total: sp.grand_total,
              salesid: s.salesid,
              pax: s.pax
            }
          )
        )
    end

    order = Enum.map(total_order, fn x -> x.orderid end) |> Enum.count()
    pax = Enum.map(total_transaction, fn x -> x.pax end) |> Enum.sum()
    transaction = Enum.map(total_transaction, fn x -> x.salesid end) |> Enum.count()

    tax =
      :erlang.float_to_binary(
        Enum.map(total_transaction, fn x -> Decimal.to_float(x.gst_charge) end) |> Enum.sum(),
        decimals: 2
      )

    total1 =
      Enum.map(total_transaction, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

    total2 = Enum.map(total_transaction, fn x -> Decimal.to_float(x.gst_charge) end) |> Enum.sum()
    grand_total = :erlang.float_to_binary(total1 - total2, decimals: 2)

    if branchid == "0" do
      outlet_sales =
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
      outlet_sales =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: s.branchid == b.branchid,
            where:
              s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"],
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

    broadcast(socket, "populate_dashboard", %{
      outlet_sales: outlet_sales,
      grand_total: grand_total,
      tax: tax,
      order: order,
      pax: pax,
      transaction: transaction
    })

    {:noreply, socket}
  end

  def handle_in("open_login_modal", payload, socket) do
    broadcast(socket, "open_login_modal", payload)
    {:noreply, socket}
  end

  def handle_in("sales_transaction", payload, socket) do
    branchid = payload["branch_id"]

    if branchid == "0" do
      sales_data =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            where:
              s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                s.brand_id == ^payload["brand_id"],
            select: %{
              salesdate: s.salesdate,
              invoiceno: s.invoiceno,
              payment_type: sp.payment_type,
              grand_total: sp.grand_total,
              tbl_no: s.tbl_no,
              pax: s.pax
            }
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
            where:
              s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"],
            select: %{
              salesdate: s.salesdate,
              invoiceno: s.invoiceno,
              payment_type: sp.payment_type,
              grand_total: sp.grand_total,
              tbl_no: s.tbl_no,
              pax: s.pax,
              staff_name: st.staff_name,
              branchid: s.branchid
            }
          )
        )
    end

    broadcast(socket, "populate_table_sales_transaction", %{sales_data: sales_data})
    {:noreply, socket}
  end

  def handle_in("hourly_sales_summary", payload, socket) do
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    luck =
      for date <- date_data do
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

        pax = test |> Enum.map(fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()
        grand_total = test |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

        if grand_total == 0 do
          grand_total = 0
        else
          grand_total = :erlang.float_to_binary(grand_total, decimals: 2)
        end

        h1 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 1 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h2 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 2 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h3 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 3 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h4 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 4 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h5 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 5 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h6 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 6 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h7 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 7 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h8 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 8 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h9 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 9 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h10 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 10 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h11 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 11 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h12 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 12 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h13 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 13 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h14 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 14 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h15 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 15 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h16 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 16 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h17 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 17 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h18 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 18 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h19 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 19 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h20 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 20 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h21 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 21 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h22 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 22 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h23 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 23 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        h24 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 24 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        if h1 == 0 do
          h1 = 0.0
        else
          h1 = :erlang.float_to_binary(h1, decimals: 2)
        end

        if h2 == 0 do
          h2 = 0.0
        else
          h1 = :erlang.float_to_binary(h2, decimals: 2)
        end

        if h3 == 0 do
          h1 = 0.0
        else
          h3 = :erlang.float_to_binary(h3, decimals: 2)
        end

        if h4 == 0 do
          h4 = 0.0
        else
          h4 = :erlang.float_to_binary(h4, decimals: 2)
        end

        if h5 == 0 do
          h5 = 0.0
        else
          h5 = :erlang.float_to_binary(h5, decimals: 2)
        end

        if h6 == 0 do
          h6 = 0.0
        else
          h6 = :erlang.float_to_binary(h6, decimals: 2)
        end

        if h7 == 0 do
          h7 = 0.0
        else
          h1 = :erlang.float_to_binary(h7, decimals: 2)
        end

        if h8 == 0 do
          h8 = 0.0
        else
          h8 = :erlang.float_to_binary(h8, decimals: 2)
        end

        if h9 == 0 do
          h9 = 0.0
        else
          h9 = :erlang.float_to_binary(h9, decimals: 2)
        end

        if h10 == 0 do
          h1 = 0.0
        else
          h10 = :erlang.float_to_binary(h10, decimals: 2)
        end

        if h11 == 0 do
          h11 = 0.0
        else
          h11 = :erlang.float_to_binary(h11, decimals: 2)
        end

        if h12 == 0 do
          h12 = 0.0
        else
          h12 = :erlang.float_to_binary(h12, decimals: 2)
        end

        if h13 == 0 do
          h13 = 0.0
        else
          h13 = :erlang.float_to_binary(h13, decimals: 2)
        end

        if h14 == 0 do
          h14 = 0.0
        else
          h14 = :erlang.float_to_binary(h14, decimals: 2)
        end

        if h15 == 0 do
          h15 = 0.0
        else
          h15 = :erlang.float_to_binary(h15, decimals: 2)
        end

        if h16 == 0 do
          h16 = 0.0
        else
          h16 = :erlang.float_to_binary(h16, decimals: 2)
        end

        if h17 == 0 do
          h17 = 0.0
        else
          h17 = :erlang.float_to_binary(h17, decimals: 2)
        end

        if h18 == 0 do
          h18 = 0.0
        else
          h18 = :erlang.float_to_binary(h18, decimals: 2)
        end

        if h19 == 0 do
          h19 = 0.0
        else
          h19 = :erlang.float_to_binary(h19, decimals: 2)
        end

        if h20 == 0 do
          h20 = 0.0
        else
          h20 = :erlang.float_to_binary(h20, decimals: 2)
        end

        if h21 == 0 do
          h1 = 0.0
        else
          h21 = :erlang.float_to_binary(h21, decimals: 2)
        end

        if h22 == 0 do
          h22 = 0.0
        else
          h22 = :erlang.float_to_binary(h22, decimals: 2)
        end

        if h23 == 0 do
          h23 = 0.0
        else
          h23 = :erlang.float_to_binary(h23, decimals: 2)
        end

        if h24 == 0 do
          h24 = 0.0
        else
          h24 = :erlang.float_to_binary(h24, decimals: 2)
        end

        %{
          date: date,
          pax: pax,
          grand_total: grand_total,
          h1: h1,
          h2: h2,
          h3: h3,
          h4: h4,
          h5: h5,
          h6: h6,
          h7: h7,
          h8: h8,
          h9: h9,
          h10: h10,
          h11: h11,
          h12: h12,
          h13: h13,
          h14: h14,
          h15: h15,
          h16: h16,
          h17: h17,
          h18: h18,
          h19: h19,
          h20: h20,
          h21: h21,
          h22: h22,
          h23: h23,
          h24: h24
        }
      end

    broadcast(socket, "populate_table_hourly_sales_summary", %{luck: luck})
    {:noreply, socket}
  end

  def handle_in("hourly_pax_summary", payload, socket) do
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    luck =
      for date <- date_data do
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

        pax = test |> Enum.map(fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()
        grand_total = test |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

        if grand_total == 0 do
          grand_total = 0
        else
          grand_total = :erlang.float_to_binary(grand_total, decimals: 2)
        end

        h1 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 1 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h2 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 2 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h3 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 3 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h4 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 4 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h5 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 5 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h6 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 6 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h7 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 7 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h8 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 8 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h9 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 9 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h10 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 10 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h11 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 11 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h12 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 12 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h13 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 13 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h14 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 14 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h15 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 15 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h16 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 16 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h17 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 17 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h18 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 18 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h19 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 19 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h20 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 20 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h21 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 21 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h22 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 22 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h23 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 23 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        h24 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 24 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        %{
          date: date,
          pax: pax,
          grand_total: grand_total,
          h1: h1,
          h2: h2,
          h3: h3,
          h4: h4,
          h5: h5,
          h6: h6,
          h7: h7,
          h8: h8,
          h9: h9,
          h10: h10,
          h11: h11,
          h12: h12,
          h13: h13,
          h14: h14,
          h15: h15,
          h16: h16,
          h17: h17,
          h18: h18,
          h19: h19,
          h20: h20,
          h21: h21,
          h22: h22,
          h23: h23,
          h24: h24
        }
      end

    broadcast(socket, "populate_table_hourly_pax_summary", %{luck: luck})
    {:noreply, socket}
  end

  def handle_in("hourly_transaction_summary", payload, socket) do
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    luck =
      for date <- date_data do
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

        pax = test |> Enum.map(fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()
        grand_total = test |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

        if grand_total == 0 do
          grand_total = 0
        else
          grand_total = :erlang.float_to_binary(grand_total, decimals: 2)
        end

        h1 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 1 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h2 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 2 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h3 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 3 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h4 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 4 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h5 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 5 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h6 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 6 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h7 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 7 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h8 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 8 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h9 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 9 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h10 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 10 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h11 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 11 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h12 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 12 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h13 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 13 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h14 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 14 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h15 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 15 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h16 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 16 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h17 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 17 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h18 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 18 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h19 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 19 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h20 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 20 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h21 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 21 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h22 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 22 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h23 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 23 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        h24 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == 24 end)
          |> Enum.map(fn x -> x.salesid end)
          |> Enum.count()

        %{
          date: date,
          pax: pax,
          grand_total: grand_total,
          h1: h1,
          h2: h2,
          h3: h3,
          h4: h4,
          h5: h5,
          h6: h6,
          h7: h7,
          h8: h8,
          h9: h9,
          h10: h10,
          h11: h11,
          h12: h12,
          h13: h13,
          h14: h14,
          h15: h15,
          h16: h16,
          h17: h17,
          h18: h18,
          h19: h19,
          h20: h20,
          h21: h21,
          h22: h22,
          h23: h23,
          h24: h24
        }
      end

    broadcast(socket, "populate_table_hourly_transaction_summary", %{luck: luck})
    {:noreply, socket}
  end

  def handle_in("item_sold", payload, socket) do
    branchid = payload["branch_id"]

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
            where:
              sd.afterdisc != 0.00 and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"],
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
            where:
              sd.afterdisc != 0.00 and s.branchid == ^payload["branch_id"] and
                s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
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
    branchid = payload["branch_id"]

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
            where:
              s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"],
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

    broadcast(socket, "populate_table_item_sales_detail", %{
      item_sales_detail_data: item_sales_detail_data
    })

    {:noreply, socket}
  end

  def handle_in("discount_receipt", payload, socket) do
    discount_receipt_data =
      Repo.all(
        from(
          sd in BoatNoodle.BN.SalesMaster,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sd.salesid,
          left_join: i in BoatNoodle.BN.DiscountItem,
          on: sd.discountid == i.discountitemsid,
          group_by: [s.invoiceno],
          where:
            sd.discountid == i.discountitemsid and s.branchid == ^payload["branch_id"] and
              s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            salesdate: s.salesdate,
            invoiceno: s.invoiceno,
            after_disc: sum(sd.afterdisc),
            order_price: sum(sd.order_price),
            discitemsname: i.discitemsname,
            branchid: s.branchid
          }
        )
      )
      |> Enum.map(fn x ->
        %{
          salesdate: x.salesdate,
          invoiceno: x.invoiceno,
          branchid: x.branchid,
          after_disc:
            :erlang.float_to_binary(
              Decimal.to_float(x.after_disc) - Decimal.to_float(x.order_price),
              decimals: 2
            ),
          discitemsname: x.discitemsname
        }
      end)

    broadcast(socket, "populate_table_discount_receipt", %{
      discount_receipt_data: discount_receipt_data
    })

    {:noreply, socket}
  end

  def handle_in("discount_summary", payload, socket) do
    discount_summary_data =
      Repo.all(
        from(
          sd in BoatNoodle.BN.SalesMaster,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sd.salesid,
          left_join: di in BoatNoodle.BN.DiscountItem,
          on: sd.discountid == di.discountitemsid,
          left_join: d in BoatNoodle.BN.Discount,
          on: d.discountid == di.discountid,
          group_by: [d.discountid],
          where:
            sd.discountid == di.discountitemsid and s.branchid == ^payload["branch_id"] and
              s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            discname: d.discname,
            after_disc: sum(sd.afterdisc),
            order_price: sum(sd.order_price),
            total: count(sd.sales_details)
          }
        )
      )
      |> Enum.map(fn x ->
        %{
          discname: x.discname,
          total: x.total,
          after_disc:
            :erlang.float_to_binary(
              Decimal.to_float(x.after_disc) - Decimal.to_float(x.order_price),
              decimals: 2
            )
        }
      end)

    broadcast(socket, "populate_table_discount_summary", %{
      discount_summary_data: discount_summary_data
    })

    {:noreply, socket}
  end

  def handle_in("voided_receipt", payload, socket) do
    voided_receipt_data =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          left_join: f in BoatNoodle.BN.Staff,
          on: s.staffid == f.staff_id,
          group_by: [s.invoiceno],
          where:
            s.is_void != 0 and s.branchid == ^payload["branch_id"] and
              s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
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

    broadcast(socket, "populate_table_voided_receipt_data", %{
      voided_receipt_data: voided_receipt_data
    })

    {:noreply, socket}
  end

  def handle_in("voided_order", payload, socket) do
    voided_order_data =
      Repo.all(
        from(
          v in BoatNoodle.BN.VoidItems,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == v.orderid,
          left_join: g in BoatNoodle.BN.ItemSubcat,
          on: g.subcatid == v.itemid,
          left_join: f in BoatNoodle.BN.Staff,
          on: s.staffid == f.staff_id,
          where:
            s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
              s.salesdate <= ^payload["e_date"],
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

  def handle_in("sales_summary", payload, socket) do
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    luck =
      for date <- date_data do
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
                grand_total: sum(sp.grand_total)
              }
            )
          )

        grand_total = test |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

        if grand_total == 0 do
          grand_total = 0.00
        else
          grand_total = :erlang.float_to_binary(grand_total, decimals: 2)
        end

        morning =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour >= 1 && x.salesdatetime.hour <= 10 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        lunch =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour >= 11 && x.salesdatetime.hour <= 14 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        idle =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour >= 15 && x.salesdatetime.hour <= 17 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        dinner =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour >= 18 && x.salesdatetime.hour <= 24 end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        if morning == 0 do
          morning = 0.0
        else
          morning = :erlang.float_to_binary(morning, decimals: 2)
        end

        if lunch == 0 do
          lunch = 0.0
        else
          lunch = :erlang.float_to_binary(lunch, decimals: 2)
        end

        if idle == 0 do
          idle = 0.0
        else
          idle = :erlang.float_to_binary(idle, decimals: 2)
        end

        if dinner == 0 do
          dinner = 0.0
        else
          dinner = :erlang.float_to_binary(dinner, decimals: 2)
        end

        %{
          date: date,
          grand_total: grand_total,
          morning: morning,
          lunch: lunch,
          idle: idle,
          dinner: dinner
        }
      end

    broadcast(socket, "populate_table_sales_summary", %{luck: luck})
    {:noreply, socket}
  end

  def handle_in("pax_summary", payload, socket) do
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    luck =
      for date <- date_data do
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
                pax: sum(s.pax)
              }
            )
          )

        pax = test |> Enum.map(fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()

        morning =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour >= 1 && x.salesdatetime.hour <= 10 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        lunch =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour >= 11 && x.salesdatetime.hour <= 14 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        idle =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour >= 15 && x.salesdatetime.hour <= 17 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        dinner =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour >= 18 && x.salesdatetime.hour <= 24 end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        %{
          date: date,
          pax: pax,
          morning: morning,
          lunch: lunch,
          idle: idle,
          dinner: dinner
        }
      end

    broadcast(socket, "populate_table_pax_summary", %{luck: luck})
    {:noreply, socket}
  end

  def handle_in("tax", payload, socket) do
    tax_data =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where:
            s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
              s.salesdate <= ^payload["e_date"],
          select: %{
            tax: sum(sp.gst_charge),
            afterdisc: sum(sp.grand_total),
            service_charge: sum(sp.service_charge)
          }
        )
      )
      |> Enum.map(fn x ->
        %{
          tax: Decimal.to_float(x.tax),
          grand_total:
            Decimal.to_float(x.afterdisc) + Decimal.to_float(x.service_charge) -
              Decimal.to_float(x.tax)
        }
      end)
      |> hd

    tax_details =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where:
            s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
              s.salesdate <= ^payload["e_date"],
          select: %{
            salesdatetime: s.salesdatetime,
            invoiceno: s.invoiceno,
            tax: sp.gst_charge,
            after_disc: sp.after_disc,
            rounding: sp.rounding
          }
        )
      )

    branches = payload["branch_id"]
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    map = taxes_data(branches, s_date, e_date)

    broadcast(socket, "populate_tax_data", %{
      tax_data: :erlang.float_to_binary(tax_data.tax, decimals: 2),
      tax_total: :erlang.float_to_binary(tax_data.grand_total, decimals: 2),
      tax_details: tax_details,
      map: Poison.encode!(map)
    })

    {:noreply, socket}
  end

  defp taxes_data(branches, s_date, e_date) do
    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    for item <- date_data do
      total_transaction =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            where: s.branchid == ^branches and s.salesdate == ^item,
            select: %{
              salesdate: s.salesdate,
              gst_charge: sp.gst_charge,
              grand_total: sp.grand_total
            }
          )
        )

      res =
        total_transaction |> Enum.map(fn x -> Decimal.to_float(x.gst_charge) end) |> Enum.sum()

      grand_total =
        total_transaction |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

      aat = grand_total - res

      if res == 0 do
        res = 0.00
      else
        res = res |> Float.round(2)
      end

      if aat == 0 do
        aat = 0.00
      else
        aat = aat |> Float.round(2)
      end

      %{salesdate: item, tax: res, aat: aat}
    end
  end

  def handle_in("payment_type", payload, socket) do
    payment_type_cash =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where:
            sp.payment_type == "CASH" and s.branchid == ^payload["branch_id"] and
              s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            cash: sum(sp.grand_total)
          }
        )
      )
      |> hd()

    payment_type_others =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where:
            sp.payment_type == "CREDITCARD" and s.branchid == ^payload["branch_id"] and
              s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"],
          select: %{
            card: sum(sp.grand_total)
          }
        )
      )
      |> hd()

    payment =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          group_by: sp.payment_type,
          where:
            s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
              s.salesdate <= ^payload["e_date"],
          select: %{
            payment_type: sp.payment_type,
            total: sum(sp.grand_total)
          }
        )
      )

    branches = payload["branch_id"]
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    map = payment_data(branches, s_date, e_date)

    payment_type_others = payment_type_others.card
    payment_type_cash = payment_type_cash.cash

    if payment_type_others == nil do
      payment_type_others = "0.00"
    end

    if payment_type_cash == nil do
      payment_type_cash = "0.00"
    end

    payment = payment
    map = Poison.encode!(map)

    broadcast(socket, "populate_payment", %{
      payment_type_cash: payment_type_cash,
      payment_type_others: payment_type_others,
      payment: payment,
      map: map
    })

    {:noreply, socket}
  end

  defp payment_data(branches, s_date, e_date) do
    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    for item <- date_data do
      total_transaction =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            where: s.branchid == ^branches and s.salesdate == ^item,
            select: %{
              salesdate: s.salesdate,
              grand_total: sp.grand_total,
              payment_type: sp.payment_type
            }
          )
        )

      if total_transaction != [] do
        cash =
          Enum.filter(total_transaction, fn x -> x.payment_type == "CASH" end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        card =
          Enum.filter(total_transaction, fn x -> x.payment_type == "CREDITCARD" end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()
      else
        cash = 0
        card = 0
      end

      if cash == 0 do
        cash = 0.00
      else
        cash = cash |> Float.round(2)
      end

      if card == 0 do
        card = 0.00
      else
        card = card |> Float.round(2)
      end

      %{salesdate: item, cash: cash, card: card}
    end
  end

  def handle_in("cash_in_out", payload, socket) do
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    new_s_date =
      Enum.join([s_date, " 00:00:00"], "")
      |> NaiveDateTime.from_iso8601()
      |> elem(1)
      |> DateTime.from_naive("Etc/UTC")
      |> elem(1)

    new_e_date =
      Enum.join([e_date, " 00:00:00"], "")
      |> NaiveDateTime.from_iso8601()
      |> elem(1)
      |> DateTime.from_naive("Etc/UTC")
      |> elem(1)

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    dates = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end) |> Poison.encode!()
    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    new_s_date

    cash_in =
      Repo.all(
        from(
          c in BoatNoodle.BN.CashInOut,
          left_join: b in BoatNoodle.BN.Branch,
          on: b.branchid == c.branch_id,
          where:
            c.cashtype == "CASHIN" and b.branchid == ^payload["branch_id"] and
              c.date_time >= ^new_s_date and c.date_time <= ^new_e_date,
          select: %{
            cash_in: sum(c.amount)
          }
        )
      )
      |> hd()

    cash_out =
      Repo.all(
        from(
          c in BoatNoodle.BN.CashInOut,
          left_join: b in BoatNoodle.BN.Branch,
          on: b.branchid == c.branch_id,
          where:
            c.cashtype == "CASHOUT" and b.branchid == ^payload["branch_id"] and
              c.date_time >= ^new_s_date and c.date_time <= ^new_e_date,
          select: %{
            cash_out: sum(c.amount)
          }
        )
      )
      |> hd()

    cash =
      Repo.all(
        from(
          c in BoatNoodle.BN.CashInOut,
          left_join: b in BoatNoodle.BN.Branch,
          on: b.branchid == c.branch_id,
          group_by: c.cashtype,
          where:
            b.branchid == ^payload["branch_id"] and c.date_time >= ^new_s_date and
              c.date_time <= ^new_e_date,
          select: %{
            branchname: b.branchname,
            amount: sum(c.amount),
            cashtype: c.cashtype,
            open: count(c.id)
          }
        )
      )

    branches = payload["branch_id"]
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    map = cashinout(branches, s_date, e_date)

    cash_in = cash_in.cash_in
    cash_out = cash_out.cash_out

    if cash_in == nil do
      cash_in = "0.00"
    end

    if cash_out == nil do
      cash_out = "0.00"
    end

    broadcast(socket, "populate_cash_in_out", %{
      cash_in: cash_in,
      cash_out: cash_out,
      cash: cash,
      dates: dates,
      map: Poison.encode!(map)
    })

    {:noreply, socket}
  end

  defp cashinout(branches, s_date, e_date) do
    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    for item <- date_data do
      new_s_date =
        Enum.join([item, " 00:00:00"], "")
        |> NaiveDateTime.from_iso8601()
        |> elem(1)
        |> DateTime.from_naive("Etc/UTC")
        |> elem(1)

      new_e_date =
        Enum.join([item, " 23:59:59"], "")
        |> NaiveDateTime.from_iso8601()
        |> elem(1)
        |> DateTime.from_naive("Etc/UTC")
        |> elem(1)

      total_transaction =
        Repo.all(
          from(
            c in BoatNoodle.BN.CashInOut,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == c.branch_id,
            where:
              b.branchid == ^branches and c.date_time >= ^new_s_date and
                c.date_time <= ^new_e_date,
            select: %{
              amount: sum(c.amount),
              cashtype: c.cashtype
            }
          )
        )

      cash_in =
        Enum.filter(total_transaction, fn x -> x.cashtype == "CASHIN" end)
        |> Enum.map(fn x -> Decimal.to_float(x.amount) end)
        |> Enum.sum()

      cash_out =
        Enum.filter(total_transaction, fn x -> x.cashtype == "CASHOUT" end)
        |> Enum.map(fn x -> Decimal.to_float(x.amount) end)
        |> Enum.sum()

      open_drawer = Enum.count(total_transaction)

      if cash_in == 0 do
        cash_in = 0.00
      else
        cash_in = cash_in |> Float.round(2)
      end

      if cash_out == 0 do
        cash_out = 0.00
      else
        cash_out = cash_out |> Float.round(2)
      end

      %{salesdate: item, cash_in: cash_in, cash_out: cash_out, open_drawer: open_drawer}
    end
  end

  def handle_in("chart_btn", payload, socket) do
    s_date = payload["s_date"]
    e_date = payload["e_date"]
    branches = payload["branch_id"]

    map0 = bar_chart_sales_data(branches, s_date)
    map = chart_data(branches, s_date, e_date)
    map2 = hourly_sales_chart_data(branches, s_date)
    map3 = hourly_pax_chart_data(branches, s_date)

    broadcast(socket, "populate_chart", %{
      map0: Poison.encode!(map0),
      map: Poison.encode!(map),
      map2: Poison.encode!(map2),
      map3: Poison.encode!(map3)
    })

    {:noreply, socket}
  end

  defp bar_chart_sales_data(branches, s_date) do
    a = Date.from_iso8601!(s_date)
    year = a.year

    total_transaction =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: sp.salesid == s.salesid,
          where: s.branchid == ^branches,
          select: %{
            salesdate: s.salesdate,
            grand_total: sp.grand_total,
            tax: sp.gst_charge,
            service_charge: sp.service_charge
          }
        )
      )

    total =
      total_transaction
      |> Enum.reject(fn x -> x.salesdate == nil end)
      |> Enum.filter(fn x -> x.salesdate.year == year end)

    ranges = 1..12

    month =
      for range <- ranges do
        bulan = range |> Timex.month_name()

        all1 =
          total
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdate.month == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        all2 =
          total
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdate.month == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.tax) end)
          |> Enum.sum()

        all3 =
          total
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdate.month == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.service_charge) end)
          |> Enum.sum()

        if all1 == 0 do
          all1 = 0.0
        else
          all1 = all1 |> Float.round(2)
        end

        if all2 == 0 do
          all2 = 0.0
        else
          all2 = all2 |> Float.round(2)
        end

        if all3 == 0 do
          all3 = 0.0
        else
          all3 = all3 |> Float.round(2)
        end

        %{bulan: bulan, sales: all1, tax: all2, service_charge: all3}
      end
  end

  defp chart_data(branches, s_date, e_date) do
    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    for item <- date_data do
      total_transaction =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            where: s.branchid == ^branches and s.salesdate == ^item,
            select: %{
              salesdate: s.salesdate,
              grand_total: sp.grand_total,
              tax: sp.gst_charge,
              service_charge: sp.service_charge
            }
          )
        )

      grand_total =
        total_transaction |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

      tax = total_transaction |> Enum.map(fn x -> Decimal.to_float(x.tax) end) |> Enum.sum()

      service_charge =
        total_transaction
        |> Enum.map(fn x -> Decimal.to_float(x.service_charge) end)
        |> Enum.sum()

      if grand_total == 0 do
        grand_total = 0.00
      else
        grand_total = grand_total |> Float.round(2)
      end

      if tax == 0 do
        tax = 0.00
      else
        tax = tax |> Float.round(2)
      end

      if service_charge == 0 do
        service_charge = 0.00
      else
        service_charge = service_charge |> Float.round(2)
      end

      %{salesdate: item, grand_total: grand_total, tax: tax, service_charge: service_charge}
    end
  end

  defp hourly_sales_chart_data(branches, s_date) do
    date = s_date

    test =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where: s.branchid == ^branches and s.salesdate == ^date,
          group_by: [s.salesdatetime, s.salesdate],
          select: %{
            salesdatetime: s.salesdatetime,
            salesdate: s.salesdate,
            gst_charge: sum(sp.gst_charge),
            service_charge: sum(sp.service_charge),
            grand_total: sum(sp.grand_total)
          }
        )
      )

    ranges = 1..24

    hour =
      for range <- ranges do
        if range == 1 do
          time = "1AM"
        end

        if range == 2 do
          time = "2AM"
        end

        if range == 3 do
          time = "3AM"
        end

        if range == 4 do
          time = "4AM"
        end

        if range == 5 do
          time = "5AM"
        end

        if range == 6 do
          time = "6AM"
        end

        if range == 7 do
          time = "7AM"
        end

        if range == 8 do
          time = "8AM"
        end

        if range == 9 do
          time = "9AM"
        end

        if range == 10 do
          time = "10AM"
        end

        if range == 11 do
          time = "11AM"
        end

        if range == 12 do
          time = "12PM"
        end

        if range == 13 do
          time = "1PM"
        end

        if range == 14 do
          time = "2PM"
        end

        if range == 15 do
          time = "3PM"
        end

        if range == 16 do
          time = "4PM"
        end

        if range == 17 do
          time = "5PM"
        end

        if range == 18 do
          time = "6PM"
        end

        if range == 19 do
          time = "7PM"
        end

        if range == 20 do
          time = "8PM"
        end

        if range == 21 do
          time = "9PM"
        end

        if range == 22 do
          time = "10PM"
        end

        if range == 23 do
          time = "11PM"
        end

        if range == 24 do
          time = "12PM"
        end

        all1 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
          |> Enum.sum()

        all2 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.gst_charge) end)
          |> Enum.sum()

        all3 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.service_charge) end)
          |> Enum.sum()

        if all1 == 0 do
          all1 = 0.0
        else
          all1 = all1 |> Float.round(2)
        end

        if all2 == 0 do
          all2 = 0.0
        else
          all2 = all2 |> Float.round(2)
        end

        if all3 == 0 do
          all3 = 0.0
        else
          all3 = all3 |> Float.round(2)
        end

        %{sales: all1, tax: all2, service_charge: all3, time: time}
      end
  end

  defp hourly_pax_chart_data(branches, s_date) do
    date = s_date

    test =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          where: s.branchid == ^branches and s.salesdate == ^date,
          group_by: [s.salesdatetime, s.salesdate],
          select: %{
            salesdatetime: s.salesdatetime,
            salesdate: s.salesdate,
            pax: sum(s.pax),
            transaction: count(sp.salespay_id)
          }
        )
      )

    ranges = 1..24

    hour =
      for range <- ranges do
        if range == 1 do
          time = "1AM"
        end

        if range == 2 do
          time = "2AM"
        end

        if range == 3 do
          time = "3AM"
        end

        if range == 4 do
          time = "4AM"
        end

        if range == 5 do
          time = "5AM"
        end

        if range == 6 do
          time = "6AM"
        end

        if range == 7 do
          time = "7AM"
        end

        if range == 8 do
          time = "8AM"
        end

        if range == 9 do
          time = "9AM"
        end

        if range == 10 do
          time = "10AM"
        end

        if range == 11 do
          time = "11AM"
        end

        if range == 12 do
          time = "12PM"
        end

        if range == 13 do
          time = "1PM"
        end

        if range == 14 do
          time = "2PM"
        end

        if range == 15 do
          time = "3PM"
        end

        if range == 16 do
          time = "4PM"
        end

        if range == 17 do
          time = "5PM"
        end

        if range == 18 do
          time = "6PM"
        end

        if range == 19 do
          time = "7PM"
        end

        if range == 20 do
          time = "8PM"
        end

        if range == 21 do
          time = "9PM"
        end

        if range == 22 do
          time = "10PM"
        end

        if range == 23 do
          time = "11PM"
        end

        if range == 24 do
          time = "12PM"
        end

        all1 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == range end)
          |> Enum.map(fn x -> Decimal.to_float(x.pax) end)
          |> Enum.sum()

        all2 =
          test
          |> List.flatten()
          |> Enum.filter(fn x -> x.salesdatetime.hour == range end)
          |> Enum.map(fn x -> x.transaction end)
          |> Enum.sum()

        %{pax: all1, transaction: all2, time: time}
      end
  end

  def handle_in("generate_discount_items", %{"disc" => disc}, socket) do
    id = disc

    if id == "0" do
      discount = Repo.all(from(s in BoatNoodle.BN.DiscountItem))
    else
      discount = Repo.all(from(s in BoatNoodle.BN.DiscountItem, where: s.discountid == ^id))
    end

    broadcast(socket, "generate_discount_item2", %{discount: discount})

    {:noreply, socket}
  end

  def handle_in("combo_edit", payload, socket) do
    id1 = payload["subcat_id"]
    id = payload["subcat_id"] |> String.to_integer()
    price_code = payload["price_code"]

    subcat = Repo.get_by(BoatNoodle.BN.ItemSubcat, subcatid: id, price_code: price_code)

    combo = Repo.all(from(s in BoatNoodle.BN.ComboDetails, where: s.combo_id == ^id1))

    html =
      Phoenix.View.render_to_string(
        BoatNoodleWeb.ItemSubcatView,
        "edit_combo_modal.html",
        subcatid: subcat.subcatid,
        name: subcat.itemname,
        price: subcat.itemprice,
        combo: combo,
        subcat: subcat
      )

    broadcast(socket, "show_combo_modal", %{
      html: html
    })

    {:noreply, socket}
  end

  def handle_in("update_combo_price", payload, socket) do
    map =
      payload["map"]
      |> Enum.map(fn x -> %{x["name"] => x["value"]} end)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})
      |> Enum.sort()

    a =
      for item <- map do
        id = elem(item, 0) |> String.split_at(9) |> elem(0)
        c = elem(item, 0) |> String.split_at(9) |> elem(1)
        price = item |> elem(1)

        %{id: id, item: c, price: price}
      end
      |> Enum.group_by(fn x -> x.id end)

    t = a["id"] |> hd
    id = t.price |> String.to_integer()
    r = a["name"] |> hd
    name = r.price

    s = a["price"] |> hd
    price = s.price

    if a["include_s"] != nil do
      p = a["include_s"] |> hd
      included_spend = p.price
    else
      included_spend = ""
    end

    if a["is_activa"] != nil do
      p = a["is_activa"] |> hd
      is_activate = p.price
    else
      is_activate = ""
    end

    if a["is_defaul"] != nil do
      p = a["is_defaul"] |> hd
      is_default_combo = p.price
    else
      is_default_combo = ""
    end

    if a["enable_di"] != nil do
      p = a["enable_di"] |> hd
      enable_disc = p.price
    else
      enable_disc = ""
    end

    if included_spend == "on" do
      included_spend = 1
    else
      included_spend = 0
    end

    if is_activate == "on" do
      is_activate = 1
    else
      is_activate = 0
    end

    if is_default_combo == "on" do
      is_default_combo = 1
    else
      is_default_combo = 0
    end

    if enable_disc == "on" do
      enable_disc = 1
    else
      enable_disc = 0
    end

    brand_id = payload["brand_id"] |> String.to_integer()

    subcat = Repo.get_by(BoatNoodle.BN.ItemSubcat, subcatid: id, brand_id: brand_id)

    BN.update_item_subcat(subcat, %{
      itemname: name,
      itemprice: price,
      enable_disc: enable_disc,
      is_default_combo: is_default_combo,
      is_activate: is_activate,
      include_spend: included_spend
    })

    for insert <- a do
      if elem(insert, 0) != "name" && elem(insert, 0) != "price" && elem(insert, 0) != "is_defaul" &&
           elem(insert, 0) != "is_activa" && elem(insert, 0) != "include_s" &&
           elem(insert, 0) != "enable_di" && elem(insert, 0) != "id" &&
           elem(insert, 0) != "include_spend" && elem(insert, 0) != "is_activate" &&
           elem(insert, 0) != "is_default_combo" && elem(insert, 0) != "enable_disc" do
        id = elem(insert, 0) |> String.to_integer()

        combo =
          Repo.all(from(s in BoatNoodle.BN.ComboDetails, where: s.combo_item_id == ^id)) |> hd

        a =
          for item <- elem(insert, 1) do
            if item.item == "[cost_price]" do
              %{item: item.item, price: item.price}
            end
          end
          |> Enum.filter(fn x -> x != nil end)
          |> hd

        b =
          for item <- elem(insert, 1) do
            if item.item == "[top_up]" do
              %{item: item.item, price: item.price}
            end
          end
          |> Enum.filter(fn x -> x != nil end)
          |> hd

        unit_price = a.price
        top_up = b.price

        BN.update_combo_details(combo, %{top_up: top_up, unit_price: unit_price})
      else
      end
    end

    broadcast(socket, "updated_combo_price", %{})

    {:noreply, socket}
  end

  def handle_in("upload_voucher", payload, socket) do
    brand = BN.get_brand!(String.to_integer(payload["brand_id"]))

    brand_name = brand.domain_name

    discount =
      Repo.all(from(s in Discount, select: %{discountid: s.discountid, discname: s.discname}))

    html =
      Phoenix.View.render_to_string(
        BoatNoodleWeb.ItemSubcatView,
        "show_voucher.html",
        discount: discount,
        brand_name: brand_name
      )

    broadcast(socket, "show_voucher", %{
      html: html
    })

    {:noreply, socket}
  end

  def handle_in("update_voucher_code", payload, socket) do
    map =
      payload["map"]
      |> Enum.map(fn x -> %{x["name"] => x["value"]} end)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})
      |> Enum.sort()

    broadcast(socket, "upload_all_code", %{})

    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
