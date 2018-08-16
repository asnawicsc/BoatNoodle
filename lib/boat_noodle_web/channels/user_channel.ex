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

  def handle_in("choose_new_brand", %{"val" => val, "name" => name, "user_id" => user_id}, socket) do
    user_id = name |> String.split("[") |> hd()
    user = Repo.get(User, user_id)

    brand = Repo.get_by(Brand, name: val)
    User.changeset(user, %{brand_id: brand.id}, user_id, "Update") |> Repo.update!()

    broadcast(socket, "notify_user_brand_changed", %{
      name: user.username,
      brand_name: brand.name
    })

    {:noreply, socket}
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

  def handle_in("load_user_sidebar", %{"userid" => userid, "brandid" => brandid}, socket) do
    user = Repo.get_by(User, %{id: String.to_integer(userid)})

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

    {total_order, total_transaction} =
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

        {total_order, total_transaction}
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

        {total_order, total_transaction}
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

    outlet_sales =
      if branchid == "0" do
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
    brand_id = payload["brand_id"]

    brand = Repo.get_by(Brand, id: brand_id)

    {sales_data, total_pages} =
      if branchid != "0" do
        sales_data =
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: s.salesid == sp.salesid,
              left_join: st in BoatNoodle.BN.Staff,
              on: s.staffid == st.staff_id,
              left_join: b in BoatNoodle.BN.Brand,
              where:
                b.id == s.brand_id and s.branchid == ^payload["branch_id"] and
                  s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                  s.brand_id == ^payload["brand_id"],
              select: %{
                salesdatetime: s.salesdatetime,
                invoiceno: s.invoiceno,
                payment_type: sp.payment_type,
                grand_total: sp.grand_total,
                tbl_no: s.tbl_no,
                pax: s.pax,
                staff_name: st.staff_name,
                branchid: s.branchid,
                domainname: b.domain_name
              }
            )
          )

        sales_data =
          for item <- sales_data do
            date =
              item.salesdatetime |> NaiveDateTime.to_string() |> String.split_at(19) |> elem(0)

            %{
              invoiceno: item.invoiceno,
              salesdatetime: date,
              payment_type: item.payment_type,
              grand_total: item.grand_total,
              tbl_no: item.tbl_no,
              pax: item.pax,
              staff_name: item.staff_name,
              domainname: item.domainname,
              branchid: item.branchid
            }
          end

        count_sales_data =
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: s.salesid == sp.salesid,
              left_join: st in BoatNoodle.BN.Staff,
              on: s.staffid == st.staff_id,
              left_join: b in BoatNoodle.BN.Brand,
              where:
                b.id == s.brand_id and s.branchid == ^payload["branch_id"] and
                  s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                  s.brand_id == ^payload["brand_id"],
              select: count(s.salesid)
            )
          )
          |> hd()

        limit = 10
        total_pages = count_sales_data / limit

        {sales_data, total_pages}
      else
        sales_data =
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: s.salesid == sp.salesid,
              left_join: st in BoatNoodle.BN.Staff,
              on: s.staffid == st.staff_id,
              left_join: b in BoatNoodle.BN.Brand,
              where:
                b.id == s.brand_id and s.salesdate >= ^payload["s_date"] and
                  s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
              select: %{
                salesdatetime: s.salesdatetime,
                invoiceno: s.invoiceno,
                payment_type: sp.payment_type,
                grand_total: sp.grand_total,
                tbl_no: s.tbl_no,
                pax: s.pax,
                staff_name: st.staff_name,
                branchid: s.branchid,
                domainname: b.domain_name
              }
            )
          )

        sales_data =
          for item <- sales_data do
            date =
              item.salesdatetime |> NaiveDateTime.to_string() |> String.split_at(19) |> elem(0)

            %{
              invoiceno: item.invoiceno,
              salesdatetime: date,
              payment_type: item.payment_type,
              grand_total: item.grand_total,
              tbl_no: item.tbl_no,
              pax: item.pax,
              staff_name: item.staff_name,
              domainname: item.domainname,
              branchid: item.branchid
            }
          end

        count_sales_data =
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: s.salesid == sp.salesid,
              left_join: st in BoatNoodle.BN.Staff,
              on: s.staffid == st.staff_id,
              left_join: b in BoatNoodle.BN.Brand,
              where:
                b.id == s.brand_id and s.branchid == ^payload["branch_id"] and
                  s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                  s.brand_id == ^payload["brand_id"],
              select: count(s.salesid)
            )
          )
          |> hd()

        limit = 10
        total_pages = count_sales_data / limit

        {sales_data, total_pages}
      end

    broadcast(socket, "populate_table_sales_transaction", %{
      sales_data: sales_data,
      total_pages: total_pages
    })

    {:noreply, socket}
  end

  defp data(branchid, brand_id, date) do
    test =
      if branchid != "0" do
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            where: s.branchid == ^branchid and s.salesdate == ^date and s.brand_id == ^brand_id,
            group_by: [s.salesdatetime, s.salesdate],
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              pax: sum(s.pax),
              grand_total: sum(sp.grand_total)
            }
          )
        )
      else
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            where: s.salesdate == ^date and s.brand_id == ^brand_id,
            group_by: [s.salesdatetime, s.salesdate],
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              pax: sum(s.pax),
              grand_total: sum(sp.grand_total)
            }
          )
        )
      end
  end

  def handle_in("hourly_sales_summary", payload, socket) do
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    luck =
      for date <- date_data do
        test = data(payload["branch_id"], payload["brand_id"], date)

        pax = test |> Enum.map(fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()
        grand_total = test |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

        grand_total =
          if grand_total == 0 do
            0
          else
            :erlang.float_to_binary(grand_total, decimals: 2)
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

        h1 =
          if h1 == 0 do
            0.0
          else
            :erlang.float_to_binary(h1, decimals: 2)
          end

        h2 =
          if h2 == 0 do
            0.0
          else
            :erlang.float_to_binary(h2, decimals: 2)
          end

        h3 =
          if h3 == 0 do
            0.0
          else
            h3 = :erlang.float_to_binary(h3, decimals: 2)
          end

        h4 =
          if h4 == 0 do
            0.0
          else
            :erlang.float_to_binary(h4, decimals: 2)
          end

        h5 =
          if h5 == 0 do
            0.0
          else
            :erlang.float_to_binary(h5, decimals: 2)
          end

        h6 =
          if h6 == 0 do
            0.0
          else
            :erlang.float_to_binary(h6, decimals: 2)
          end

        h7 =
          if h7 == 0 do
            0.0
          else
            :erlang.float_to_binary(h7, decimals: 2)
          end

        h8 =
          if h8 == 0 do
            0.0
          else
            :erlang.float_to_binary(h8, decimals: 2)
          end

        h9 =
          if h9 == 0 do
            0.0
          else
            :erlang.float_to_binary(h9, decimals: 2)
          end

        h10 =
          if h10 == 0 do
            0.0
          else
            :erlang.float_to_binary(h10, decimals: 2)
          end

        h11 =
          if h11 == 0 do
            0.0
          else
            :erlang.float_to_binary(h11, decimals: 2)
          end

        h12 =
          if h12 == 0 do
            0.0
          else
            :erlang.float_to_binary(h12, decimals: 2)
          end

        h13 =
          if h13 == 0 do
            0.0
          else
            :erlang.float_to_binary(h13, decimals: 2)
          end

        h14 =
          if h14 == 0 do
            0.0
          else
            :erlang.float_to_binary(h14, decimals: 2)
          end

        h15 =
          if h15 == 0 do
            0.0
          else
            :erlang.float_to_binary(h15, decimals: 2)
          end

        h16 =
          if h16 == 0 do
            0.0
          else
            :erlang.float_to_binary(h16, decimals: 2)
          end

        h17 =
          if h17 == 0 do
            0.0
          else
            :erlang.float_to_binary(h17, decimals: 2)
          end

        h18 =
          if h18 == 0 do
            0.0
          else
            :erlang.float_to_binary(h18, decimals: 2)
          end

        h19 =
          if h19 == 0 do
            0.0
          else
            :erlang.float_to_binary(h19, decimals: 2)
          end

        h20 =
          if h20 == 0 do
            0.0
          else
            :erlang.float_to_binary(h20, decimals: 2)
          end

        h21 =
          if h21 == 0 do
            0.0
          else
            :erlang.float_to_binary(h21, decimals: 2)
          end

        h22 =
          if h22 == 0 do
            0.0
          else
            :erlang.float_to_binary(h22, decimals: 2)
          end

        h23 =
          if h23 == 0 do
            0.0
          else
            :erlang.float_to_binary(h23, decimals: 2)
          end

        h24 =
          if h24 == 0 do
            0.0
          else
            :erlang.float_to_binary(h24, decimals: 2)
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

  defp data_pax(branchid, brand_id, date) do
    test =
      if branchid != "0" do
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            where: s.branchid == ^branchid and s.salesdate == ^date and s.brand_id == ^brand_id,
            group_by: [s.salesdatetime, s.salesdate],
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              pax: sum(s.pax),
              grand_total: sum(sp.grand_total)
            }
          )
        )
      else
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            where: s.salesdate == ^date and s.brand_id == ^brand_id,
            group_by: [s.salesdatetime, s.salesdate],
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              pax: sum(s.pax),
              grand_total: sum(sp.grand_total)
            }
          )
        )
      end
  end

  def handle_in("hourly_pax_summary", payload, socket) do
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    luck =
      for date <- date_data do
        test = data_pax(payload["branch_id"], payload["brand_id"], date)

        pax = test |> Enum.map(fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()
        grand_total = test |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

        grand_total =
          if grand_total == 0 do
            0
          else
            :erlang.float_to_binary(grand_total, decimals: 2)
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

  defp data_transaction(branchid, brand_id, date) do
    test =
      if branchid != "0" do
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            where: s.branchid == ^branchid and s.salesdate == ^date and s.brand_id == ^brand_id,
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
      else
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            where: s.salesdate == ^date and s.brand_id == ^brand_id,
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
      end
  end

  def handle_in("hourly_transaction_summary", payload, socket) do
    s_date = payload["s_date"]
    e_date = payload["e_date"]

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    luck =
      for date <- date_data do
        test = data_transaction(payload["branch_id"], payload["brand_id"], date)

        pax = test |> Enum.map(fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()
        grand_total = test |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

        grand_total =
          if grand_total == 0 do
            0
          else
            :erlang.float_to_binary(grand_total, decimals: 2)
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

    item_sold_data =
      if branchid != "0" do
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: sd.itemid == i.subcatid,
            left_join: ic in BoatNoodle.BN.ItemCat,
            on: ic.itemcatid == i.itemcatid,
            group_by: sd.itemid,
            where:
              s.is_void == 0 and s.branchid == ^payload["branch_id"] and
                s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                s.brand_id == ^payload["brand_id"],
            select: %{
              itemname: i.itemname,
              qty: sum(sd.qty),
              afterdisc: sum(sd.order_price),
              itemcatname: ic.itemcatname
            }
          )
        )
      else
        Repo.all(
          from(
            sd in BoatNoodle.BN.SalesMaster,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sd.salesid,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: sd.itemid == i.subcatid,
            left_join: ic in BoatNoodle.BN.ItemCat,
            on: ic.itemcatid == i.itemcatid,
            group_by: sd.itemid,
            where:
              s.is_void == 0 and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
            select: %{
              itemname: i.itemname,
              qty: sum(sd.qty),
              afterdisc: sum(sd.order_price),
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

    item_sales_detail_data =
      Repo.all(
        from(
          s in BoatNoodle.BN.Sales,
          left_join: sd in BoatNoodle.BN.SalesMaster,
          on: s.salesid == sd.salesid,
          left_join: f in BoatNoodle.BN.Staff,
          on: s.staffid == f.staff_id,
          left_join: br in BoatNoodle.BN.Branch,
          on: br.branchid == s.branchid,
          left_join: i in BoatNoodle.BN.ItemSubcat,
          on: sd.itemid == i.subcatid,
          left_join: ic in BoatNoodle.BN.ItemCat,
          on: ic.itemcatid == i.itemcatid,
          left_join: b in BoatNoodle.BN.Brand,
          on: b.id == s.brand_id,
          where:
            s.is_void == 0 and br.branchid == ^payload["branch_id"] and
              ic.brand_id == ^payload["brand_id"] and s.salesdate >= ^payload["s_date"] and
              s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
          select: %{
            itemcode: i.itemcode,
            itemname: i.itemname,
            itemcatname: ic.itemcatname,
            qty: sd.qty,
            invoiceno: s.invoiceno,
            tbl_no: s.tbl_no,
            staff_name: f.staff_name,
            afterdisc: sd.order_price,
            salesdate: s.salesdate,
            branchid: s.branchid,
            domainname: b.domain_name
          }
        )
      )

    broadcast(socket, "populate_table_item_sales_detail", %{
      item_sales_detail_data: item_sales_detail_data
    })

    {:noreply, socket}
  end

  def handle_in("discount_receipt", payload, socket) do
    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand = Repo.get_by(Brand, id: brand_id)

    discount_receipt_data =
      if branchid != "0" do
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: s.salesid == sp.salesid,
            left_join: i in BoatNoodle.BN.DiscountItem,
            on: sp.discountid == i.discountitemsid,
            left_join: br in BoatNoodle.BN.Branch,
            on: br.branchid == s.branchid,
            left_join: g in BoatNoodle.BN.Brand,
            on: g.id == ^brand.id,
            group_by: [s.salesid],
            where:
              s.is_void == 0 and sp.discountid != "0" and br.branchid == ^payload["branch_id"] and
                s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                s.brand_id == ^payload["brand_id"],
            select: %{
              salesdatetime: s.salesdatetime,
              grand_total: sum(sp.grand_total),
              sub_total: sum(sp.sub_total),
              service_charge: sum(sp.service_charge),
              rounding: sum(sp.rounding),
              salesid: s.salesid,
              invoiceno: s.invoiceno,
              discitemsname: i.discitemsname,
              domainname: g.domain_name,
              branchid: br.branchid,
              gst_charge: sum(sp.gst_charge)
            }
          )
        )
        |> Enum.map(fn x ->
          %{
            domainname: x.domainname,
            salesdatetime: x.salesdatetime,
            invoiceno: x.invoiceno,
            branchid: x.branchid,
            after_disc:
              (Decimal.to_float(x.grand_total) -
                 (Decimal.to_float(x.sub_total) + Decimal.to_float(x.service_charge) +
                    Decimal.to_float(x.gst_charge) + Decimal.to_float(x.rounding)))
              |> Float.round(2)
              |> Number.Delimit.number_to_delimited(),
            discitemsname: x.discitemsname
          }
        end)
      else
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: s.salesid == sp.salesid,
            left_join: i in BoatNoodle.BN.DiscountItem,
            on: sp.discountid == i.discountitemsid,
            left_join: g in BoatNoodle.BN.Brand,
            on: g.id == ^brand.id,
            group_by: [s.salesid],
            where:
              s.is_void == 0 and sp.discountid != "0" and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
            select: %{
              salesdatetime: s.salesdatetime,
              grand_total: sum(sp.grand_total),
              sub_total: sum(sp.sub_total),
              service_charge: sum(sp.service_charge),
              rounding: sum(sp.rounding),
              salesid: s.salesid,
              invoiceno: s.invoiceno,
              discitemsname: i.discitemsname,
              domainname: g.domain_name,
              branchid: s.branchid,
              gst_charge: sum(sp.gst_charge)
            }
          )
        )
        |> Enum.map(fn x ->
          %{
            domainname: x.domainname,
            salesdatetime: x.salesdatetime,
            invoiceno: x.invoiceno,
            branchid: x.branchid,
            after_disc:
              (Decimal.to_float(x.grand_total) -
                 (Decimal.to_float(x.sub_total) + Decimal.to_float(x.service_charge) +
                    Decimal.to_float(x.gst_charge) + Decimal.to_float(x.rounding)))
              |> Float.round(2)
              |> Number.Delimit.number_to_delimited(),
            discitemsname: x.discitemsname
          }
        end)
      end

    discount_receipt_data =
      for item <- discount_receipt_data do
        date = item.salesdatetime |> NaiveDateTime.to_string() |> String.split_at(19) |> elem(0)

        %{
          invoiceno: item.invoiceno,
          salesdatetime: date,
          after_disc: item.after_disc,
          discitemsname: item.discitemsname,
          domainname: item.domainname,
          branchid: item.branchid
        }
      end

    broadcast(socket, "populate_table_discount_receipt", %{
      discount_receipt_data: discount_receipt_data
    })

    {:noreply, socket}
  end

  def handle_in("discount_summary", payload, socket) do
    discount_summary_data =
      if payload["branch_id"] != "0" do
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: s.salesid == sp.salesid,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: sp.discountid == di.discountitemsid,
            left_join: d in BoatNoodle.BN.Discount,
            on: d.discountid == di.discountid,
            left_join: br in BoatNoodle.BN.Branch,
            on: br.branchid == s.branchid,
            group_by: [d.discname],
            where:
              s.is_void == 0 and sp.discountid != "0" and br.branchid == ^payload["branch_id"] and
                s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                s.brand_id == ^payload["brand_id"],
            select: %{
              grand_total: sum(sp.grand_total),
              sub_total: sum(sp.sub_total),
              service_charge: sum(sp.service_charge),
              rounding: sum(sp.rounding),
              gst_charge: sum(sp.gst_charge),
              discname: d.discname,
              total: count(sp.salesid)
            }
          )
        )
        |> Enum.map(fn x ->
          %{
            discname: x.discname,
            total: x.total,
            after_disc:
              (Decimal.to_float(x.grand_total) -
                 (Decimal.to_float(x.sub_total) + Decimal.to_float(x.service_charge) +
                    Decimal.to_float(x.gst_charge) + Decimal.to_float(x.rounding)))
              |> Float.round(2)
              |> Number.Delimit.number_to_delimited()
          }
        end)
      else
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: s.salesid == sp.salesid,
            left_join: di in BoatNoodle.BN.DiscountItem,
            on: sp.discountid == di.discountitemsid,
            left_join: d in BoatNoodle.BN.Discount,
            on: d.discountid == di.discountid,
            group_by: [d.discname],
            where:
              s.is_void == 0 and sp.discountid != "0" and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
            select: %{
              grand_total: sum(sp.grand_total),
              sub_total: sum(sp.sub_total),
              service_charge: sum(sp.service_charge),
              rounding: sum(sp.rounding),
              gst_charge: sum(sp.gst_charge),
              discname: d.discname,
              total: count(sp.salesid)
            }
          )
        )
        |> Enum.map(fn x ->
          %{
            discname: x.discname,
            total: x.total,
            after_disc:
              (Decimal.to_float(x.grand_total) -
                 (Decimal.to_float(x.sub_total) + Decimal.to_float(x.service_charge) +
                    Decimal.to_float(x.gst_charge) + Decimal.to_float(x.rounding)))
              |> Float.round(2)
              |> Number.Delimit.number_to_delimited()
          }
        end)
      end

    broadcast(socket, "populate_table_discount_summary", %{
      discount_summary_data: discount_summary_data
    })

    {:noreply, socket}
  end

  def handle_in("voided_receipt", payload, socket) do
    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand = Repo.get_by(Brand, id: brand_id)

    voided_receipt_data =
      if branchid != "0" do
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            left_join: br in BoatNoodle.BN.Branch,
            on: br.branchid == s.branchid,
            left_join: f in BoatNoodle.BN.Staff,
            on: s.staffid == f.staff_id,
            left_join: g in BoatNoodle.BN.Brand,
            on: g.id == ^brand.id,
            where:
              s.is_void == 1 and br.branchid == ^payload["branch_id"] and
                s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                s.brand_id == ^payload["brand_id"],
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              invoiceno: s.invoiceno,
              total: sp.grand_total,
              table: s.tbl_no,
              pax: s.pax,
              staff: f.staff_name,
              branchid: s.branchid,
              domainname: g.domain_name
            }
          )
        )
      else
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            left_join: f in BoatNoodle.BN.Staff,
            on: s.staffid == f.staff_id,
            left_join: g in BoatNoodle.BN.Brand,
            on: g.id == ^brand.id,
            where:
              s.is_void == 1 and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              invoiceno: s.invoiceno,
              total: sp.grand_total,
              table: s.tbl_no,
              pax: s.pax,
              staff: f.staff_name,
              branchid: s.branchid,
              domainname: g.domain_name
            }
          )
        )
      end

    voided_receipt_data =
      for item <- voided_receipt_data do
        date = item.salesdatetime |> NaiveDateTime.to_string() |> String.split_at(19) |> elem(0)

        %{
          salesdatetime: date,
          salesdate: item.salesdate,
          invoiceno: item.invoiceno,
          total: item.total,
          table: item.table,
          pax: item.pax,
          staff: item.staff,
          domainname: item.domainname,
          branchid: item.branchid
        }
      end

    broadcast(socket, "populate_table_voided_receipt_data", %{
      voided_receipt_data: voided_receipt_data
    })

    {:noreply, socket}
  end

  def handle_in("voided_order", payload, socket) do
    branchid = payload["branch_id"]
    brand_id = payload["brand_id"]

    brand = Repo.get_by(Brand, id: brand_id)
    [y, m, d] = payload["s_date"] |> String.split("-")

    {:ok, start_n} =
      NaiveDateTime.new(String.to_integer(y), String.to_integer(m), String.to_integer(d), 0, 0, 0)

    [y1, m1, d1] = payload["e_date"] |> String.split("-")

    {:ok, end_n} =
      NaiveDateTime.new(
        String.to_integer(y1),
        String.to_integer(m1),
        String.to_integer(d1),
        0,
        0,
        0
      )

    voided_order_data =
      if branchid != "0" do
        Repo.all(
          from(
            v in BoatNoodle.BN.VoidItems,
            left_join: br in BoatNoodle.BN.Branch,
            on: br.branchid == v.branch_id,
            left_join: f in BoatNoodle.BN.Staff,
            on: v.void_by == f.staff_id,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: i.subcatid == v.itemid,
            left_join: r in BoatNoodle.BN.Brand,
            on: r.id == v.brand_id,
            where:
              br.branchid == ^payload["branch_id"] and v.brand_id == ^payload["brand_id"] and
                v.void_datetime >= ^start_n and v.void_datetime <= ^end_n,
            select: %{
              void_datetime: v.void_datetime,
              itemname: v.itemname,
              invoiceno: v.orderid,
              unit_price: v.priceafterdiscount,
              quantity: v.quantity,
              totalprice: v.price,
              staff: f.staff_name,
              branchid: v.branch_id,
              domainname: r.domain_name,
              voidreason: v.voidreason
            }
          )
        )
      else
        Repo.all(
          from(
            v in BoatNoodle.BN.VoidItems,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: sp.salesid == v.orderid,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            left_join: f in BoatNoodle.BN.Staff,
            on: v.void_by == f.staff_id,
            left_join: i in BoatNoodle.BN.ItemSubcat,
            on: i.subcatid == v.itemid,
            left_join: r in BoatNoodle.BN.Brand,
            on: r.id == v.brand_id,
            where:
              s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                v.brand_id == ^payload["brand_id"],
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              itemname: v.itemname,
              invoiceno: s.invoiceno,
              unit_price: i.itemprice,
              quantity: v.quantity,
              totalprice: v.price,
              staff: f.staff_name,
              branchid: s.branchid,
              domainname: r.domain_name
            }
          )
        )
      end

    voided_order_data =
      for item <- voided_order_data do
        date = item.void_datetime |> NaiveDateTime.to_string() |> String.split_at(19) |> elem(0)

        %{
          invoiceno: item.invoiceno,
          void_datetime: date,
          itemname: item.itemname,
          unit_price: item.unit_price,
          quantity: item.quantity,
          totalprice: item.totalprice,
          staff: item.staff,
          domainname: item.domainname,
          branchid: item.branchid,
          voidreason: item.voidreason
        }
      end

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
          if payload["branch_id"] != "0" do
            Repo.all(
              from(
                sp in BoatNoodle.BN.SalesPayment,
                left_join: s in BoatNoodle.BN.Sales,
                on: s.salesid == sp.salesid,
                where:
                  s.branchid == ^payload["branch_id"] and s.salesdate == ^date and
                    s.brand_id == ^payload["brand_id"],
                group_by: [s.salesdatetime, s.salesdate],
                select: %{
                  salesdatetime: s.salesdatetime,
                  salesdate: s.salesdate,
                  grand_total: sum(sp.grand_total)
                }
              )
            )
          else
            Repo.all(
              from(
                sp in BoatNoodle.BN.SalesPayment,
                left_join: s in BoatNoodle.BN.Sales,
                on: s.salesid == sp.salesid,
                where: s.salesdate == ^date and s.brand_id == ^payload["brand_id"],
                group_by: [s.salesdatetime, s.salesdate],
                select: %{
                  salesdatetime: s.salesdatetime,
                  salesdate: s.salesdate,
                  grand_total: sum(sp.grand_total)
                }
              )
            )
          end

        grand_total = test |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

        grand_total =
          if grand_total == 0 do
            0.00
          else
            :erlang.float_to_binary(grand_total, decimals: 2)
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

        morning =
          if morning == 0 do
            0.0
          else
            :erlang.float_to_binary(morning, decimals: 2)
          end

        lunch =
          if lunch == 0 do
            0.0
          else
            :erlang.float_to_binary(lunch, decimals: 2)
          end

        idle =
          if idle == 0 do
            0.0
          else
            :erlang.float_to_binary(idle, decimals: 2)
          end

        dinner =
          if dinner == 0 do
            0.0
          else
            :erlang.float_to_binary(dinner, decimals: 2)
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
          if payload["branch_id"] != "0" do
            Repo.all(
              from(
                sp in BoatNoodle.BN.SalesPayment,
                left_join: s in BoatNoodle.BN.Sales,
                on: s.salesid == sp.salesid,
                where:
                  s.branchid == ^payload["branch_id"] and s.salesdate == ^date and
                    s.brand_id == ^payload["brand_id"],
                group_by: [s.salesdatetime, s.salesdate],
                select: %{
                  salesdatetime: s.salesdatetime,
                  salesdate: s.salesdate,
                  pax: sum(s.pax)
                }
              )
            )
          else
            Repo.all(
              from(
                sp in BoatNoodle.BN.SalesPayment,
                left_join: s in BoatNoodle.BN.Sales,
                on: s.salesid == sp.salesid,
                where: s.salesdate == ^date and s.brand_id == ^payload["brand_id"],
                group_by: [s.salesdatetime, s.salesdate],
                select: %{
                  salesdatetime: s.salesdatetime,
                  salesdate: s.salesdate,
                  pax: sum(s.pax)
                }
              )
            )
          end

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
      if payload["branch_id"] != "0" do
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: s.salesid == sp.salesid,
            left_join: br in BoatNoodle.BN.Branch,
            on: br.branchid == s.branchid,
            where:
              s.is_void == 0 and br.branchid == ^payload["branch_id"] and
                s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                s.brand_id == ^payload["brand_id"],
            select: %{
              tax: sum(sp.gst_charge),
              afterdisc: sum(sp.grand_total)
            }
          )
        )
        |> hd
      else
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: s.salesid == sp.salesid,
            left_join: br in BoatNoodle.BN.Branch,
            on: br.branchid == s.branchid,
            where:
              s.is_void == 0 and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
            select: %{
              tax: sum(sp.gst_charge),
              afterdisc: sum(sp.grand_total)
            }
          )
        )
        |> hd
      end

    tax =
      if tax_data.tax == nil do
        0.00
      else
        Decimal.to_float(tax_data.tax)
      end

    afterdisc =
      if tax_data.afterdisc == nil do
        0.00
      else
        Decimal.to_float(tax_data.afterdisc)
      end

    grand_total = afterdisc - tax

    tax_details =
      if payload["branch_id"] != "0" do
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: s.salesid == sp.salesid,
            left_join: br in BoatNoodle.BN.Branch,
            on: br.branchid == s.branchid,
            where:
              s.is_void == 0 and s.branchid == ^payload["branch_id"] and
                s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                s.brand_id == ^payload["brand_id"],
            select: %{
              salesdatetime: s.salesdatetime,
              invoiceno: s.invoiceno,
              tax: sp.gst_charge,
              after_disc: sp.after_disc,
              rounding: sp.rounding
            }
          )
        )
      else
        Repo.all(
          from(
            s in BoatNoodle.BN.Sales,
            left_join: sp in BoatNoodle.BN.SalesPayment,
            on: s.salesid == sp.salesid,
            left_join: br in BoatNoodle.BN.Branch,
            on: br.branchid == s.branchid,
            where:
              s.is_void == 0 and s.salesdate >= ^payload["s_date"] and
                s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
            select: %{
              salesdatetime: s.salesdatetime,
              invoiceno: s.invoiceno,
              tax: sp.gst_charge,
              after_disc: sp.after_disc,
              rounding: sp.rounding
            }
          )
        )
      end

    tax_details =
      for item <- tax_details do
        salesdatetime =
          DateTime.from_naive!(item.salesdatetime, "Etc/UTC")
          |> DateTime.to_string()
          |> String.split_at(19)
          |> elem(0)

        %{
          salesdatetime: salesdatetime,
          invoiceno: item.invoiceno,
          tax: item.tax,
          after_disc: item.after_disc,
          rounding: item.rounding
        }
      end

    branches = payload["branch_id"]
    s_date = payload["s_date"]
    e_date = payload["e_date"]
    brand_id = payload["brand_id"]

    map = taxes_data(branches, s_date, e_date, brand_id)

    broadcast(socket, "populate_tax_data", %{
      tax_data: :erlang.float_to_binary(tax, decimals: 2),
      tax_total: :erlang.float_to_binary(afterdisc, decimals: 2),
      tax_details: tax_details,
      map: Poison.encode!(map)
    })

    {:noreply, socket}
  end

  defp taxes_data(branches, s_date, e_date, brand_id) do
    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    for item <- date_data do
      total_transaction =
        if branches != "0" do
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: sp.salesid == s.salesid,
              where: s.branchid == ^branches and s.salesdate == ^item and s.brand_id == ^brand_id,
              select: %{
                salesdate: s.salesdate,
                gst_charge: sp.gst_charge,
                grand_total: sp.grand_total
              }
            )
          )
        else
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: sp.salesid == s.salesid,
              where: s.salesdate == ^item and s.brand_id == ^brand_id,
              select: %{
                salesdate: s.salesdate,
                gst_charge: sp.gst_charge,
                grand_total: sp.grand_total
              }
            )
          )
        end

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
    {payment_type_cash, payment_type_others, payment} =
      if payload["branch_id"] != "0" do
        payment_type_cash =
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: s.salesid == sp.salesid,
              where:
                s.is_void == 0 and sp.payment_type == "CASH" and
                  s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                  s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
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
                s.is_void == 0 and sp.payment_type == "CREDITCARD" and
                  s.branchid == ^payload["branch_id"] and s.salesdate >= ^payload["s_date"] and
                  s.salesdate <= ^payload["e_date"],
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
                s.is_void == 0 and s.branchid == ^payload["branch_id"] and
                  s.salesdate >= ^payload["s_date"] and s.salesdate <= ^payload["e_date"] and
                  s.brand_id == ^payload["brand_id"],
              select: %{
                payment_type: sp.payment_type,
                total: sum(sp.grand_total)
              }
            )
          )

        {payment_type_cash, payment_type_others, payment}
      else
        payment_type_cash =
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: s.salesid == sp.salesid,
              where:
                s.is_void == 0 and sp.payment_type == "CASH" and s.salesdate >= ^payload["s_date"] and
                  s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
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
                s.is_void == 0 and sp.payment_type == "CREDITCARD" and
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
                s.is_void == 0 and s.salesdate >= ^payload["s_date"] and
                  s.salesdate <= ^payload["e_date"] and s.brand_id == ^payload["brand_id"],
              select: %{
                payment_type: sp.payment_type,
                total: sum(sp.grand_total)
              }
            )
          )

        {payment_type_cash, payment_type_others, payment}
      end

    branches = payload["branch_id"]
    s_date = payload["s_date"]
    e_date = payload["e_date"]
    brand_id = payload["brand_id"]

    map = payment_data(branches, s_date, e_date, brand_id)

    a =
      if payment_type_others.card == nil do
        "0.00"
      else
        payment_type_others.card
      end

    b =
      if payment_type_cash.cash == nil do
        "0.00"
      else
        payment_type_cash.cash
      end

    payment = payment
    map = Poison.encode!(map)

    broadcast(socket, "populate_payment", %{
      payment_type_cash: b,
      payment_type_others: a,
      payment: payment,
      map: map
    })

    {:noreply, socket}
  end

  defp payment_data(branches, s_date, e_date, brand_id) do
    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    for item <- date_data do
      total_transaction =
        if branches != "0" do
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: sp.salesid == s.salesid,
              where:
                s.is_void == 0 and s.branchid == ^branches and s.salesdate == ^item and
                  s.brand_id == ^brand_id,
              select: %{
                salesdate: s.salesdate,
                grand_total: sp.grand_total,
                payment_type: sp.payment_type
              }
            )
          )
        else
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: sp.salesid == s.salesid,
              where: s.is_void == 0 and s.salesdate == ^item and s.brand_id == ^brand_id,
              select: %{
                salesdate: s.salesdate,
                grand_total: sp.grand_total,
                payment_type: sp.payment_type
              }
            )
          )
        end

      {cash, card} =
        if total_transaction != [] do
          cash =
            Enum.filter(total_transaction, fn x -> x.payment_type == "CASH" end)
            |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
            |> Enum.sum()

          card =
            Enum.filter(total_transaction, fn x -> x.payment_type == "CREDITCARD" end)
            |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end)
            |> Enum.sum()

          {cash, card}
        else
          cash = 0
          card = 0
          {cash, card}
        end

      cash =
        if cash == 0 do
          0.00
        else
          cash |> Float.round(2)
        end

      if card == 0 do
        0.00
      else
        card |> Float.round(2)
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
      Enum.join([e_date, " 23:59:59"], "")
      |> NaiveDateTime.from_iso8601()
      |> elem(1)
      |> DateTime.from_naive("Etc/UTC")
      |> elem(1)

    a = Date.from_iso8601!(s_date)
    b = Date.from_iso8601!(e_date)

    dates = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end) |> Poison.encode!()
    date_data = Date.range(a, b) |> Enum.map(fn x -> Date.to_string(x) end)

    {cash_in, cash_out, cash} =
      if payload["branch_id"] != "0" do
        cash_in =
          Repo.all(
            from(
              c in BoatNoodle.BN.CashInOut,
              left_join: b in BoatNoodle.BN.Branch,
              on: b.branchid == c.branch_id,
              where:
                c.cashtype == "CASHIN" and c.branch_id == ^payload["branch_id"] and
                  c.date_time >= ^new_s_date and c.date_time <= ^new_e_date and
                  c.brand_id == ^payload["brand_id"],
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
                c.cashtype == "CASHOUT" and c.branch_id == ^payload["branch_id"] and
                  c.date_time >= ^new_s_date and c.date_time <= ^new_e_date and
                  c.brand_id == ^payload["brand_id"],
              select: %{
                cash_out: sum(c.amount)
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
                c.cashtype == "CASHOUT" and c.branch_id == ^payload["branch_id"] and
                  c.date_time >= ^new_s_date and c.date_time <= ^new_e_date and
                  c.brand_id == ^payload["brand_id"],
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
                c.branch_id == ^payload["branch_id"] and c.date_time >= ^new_s_date and
                  c.date_time <= ^new_e_date and c.brand_id == ^payload["brand_id"],
              select: %{
                branchname: b.branchname,
                amount: sum(c.amount),
                cashtype: c.cashtype,
                open: count(c.id)
              }
            )
          )

        {cash_in, cash_out, cash}
      else
        cash_in =
          Repo.all(
            from(
              c in BoatNoodle.BN.CashInOut,
              where:
                c.cashtype == "CASHIN" and c.date_time >= ^new_s_date and
                  c.date_time <= ^new_e_date and c.brand_id == ^payload["brand_id"],
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
              where:
                c.cashtype == "CASHOUT" and c.date_time >= ^new_s_date and
                  c.date_time <= ^new_e_date and c.brand_id == ^payload["brand_id"],
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
              group_by: [c.cashtype, b.branchname],
              where:
                c.date_time >= ^new_s_date and b.brand_id == ^payload["brand_id"] and
                  c.date_time <= ^new_e_date and c.brand_id == ^payload["brand_id"],
              select: %{
                branchname: b.branchname,
                amount: sum(c.amount),
                cashtype: c.cashtype,
                open: count(c.id)
              }
            )
          )

        {cash_in, cash_out, cash}
      end

    branches = payload["branch_id"]
    s_date = payload["s_date"]
    e_date = payload["e_date"]
    brand_id = payload["brand_id"]

    map = cashinout(branches, s_date, e_date, brand_id)

    cash_in = cash_in.cash_in
    cash_out = cash_out.cash_out

    cash_in =
      if cash_in == nil do
        "0.00"
      else
        cash_in
      end

    cash_out =
      if cash_out == nil do
        "0.00"
      else
        cash_out
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

  defp cashinout(branches, s_date, e_date, brand_id) do
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
        if branches != "0" do
          Repo.all(
            from(
              c in BoatNoodle.BN.CashInOut,
              left_join: b in BoatNoodle.BN.Branch,
              on: b.branchid == c.branch_id,
              where:
                c.branch_id == ^branches and c.date_time >= ^new_s_date and
                  c.date_time <= ^new_e_date and c.brand_id == ^brand_id,
              select: %{
                amount: sum(c.amount),
                cashtype: c.cashtype
              }
            )
          )
        else
          Repo.all(
            from(
              c in BoatNoodle.BN.CashInOut,
              where:
                c.date_time >= ^new_s_date and c.date_time <= ^new_e_date and
                  c.brand_id == ^brand_id,
              select: %{
                amount: sum(c.amount),
                cashtype: c.cashtype
              }
            )
          )
        end

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
      if branches != "0" do
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
      else
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            select: %{
              salesdate: s.salesdate,
              grand_total: sp.grand_total,
              tax: sp.gst_charge,
              service_charge: sp.service_charge
            }
          )
        )
      end

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
        if branches != "0" do
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
        else
          Repo.all(
            from(
              sp in BoatNoodle.BN.SalesPayment,
              left_join: s in BoatNoodle.BN.Sales,
              on: sp.salesid == s.salesid,
              where: s.salesdate == ^item,
              select: %{
                salesdate: s.salesdate,
                grand_total: sp.grand_total,
                tax: sp.gst_charge,
                service_charge: sp.service_charge
              }
            )
          )
        end

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
      if branches != "0" do
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
      else
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            where: s.salesdate == ^date,
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
      end

    ranges = 1..24

    hour =
      for range <- ranges do
        time =
          if range == 1 do
            "1AM"
          end

        time =
          if range == 2 do
            "2AM"
          end

        time =
          if range == 3 do
            "3AM"
          end

        time =
          if range == 4 do
            "4AM"
          end

        time =
          if range == 5 do
            "5AM"
          end

        time =
          if range == 6 do
            "6AM"
          end

        time =
          if range == 7 do
            "7AM"
          end

        time =
          if range == 8 do
            "8AM"
          end

        time =
          if range == 9 do
            "9AM"
          end

        time =
          if range == 10 do
            "10AM"
          end

        time =
          if range == 11 do
            "11AM"
          end

        time =
          if range == 12 do
            "12PM"
          end

        time =
          if range == 13 do
            "1PM"
          end

        time =
          if range == 14 do
            "2PM"
          end

        time =
          if range == 15 do
            "3PM"
          end

        time =
          if range == 16 do
            "4PM"
          end

        time =
          if range == 17 do
            "5PM"
          end

        time =
          if range == 18 do
            "6PM"
          end

        time =
          if range == 19 do
            "7PM"
          end

        time =
          if range == 20 do
            "8PM"
          end

        time =
          if range == 21 do
            "9PM"
          end

        time =
          if range == 22 do
            "10PM"
          end

        time =
          if range == 23 do
            "11PM"
          end

        time =
          if range == 24 do
            "12PM"
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
      if branches != "0" do
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
      else
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: s.salesid == sp.salesid,
            where: s.salesdate == ^date,
            group_by: [s.salesdatetime, s.salesdate],
            select: %{
              salesdatetime: s.salesdatetime,
              salesdate: s.salesdate,
              pax: sum(s.pax),
              transaction: count(sp.salespay_id)
            }
          )
        )
      end

    ranges = 1..24

    hour =
      for range <- ranges do
        time =
          if range == 1 do
            "1AM"
          end

        time =
          if range == 2 do
            "2AM"
          end

        time =
          if range == 3 do
            "3AM"
          end

        time =
          if range == 4 do
            "4AM"
          end

        time =
          if range == 5 do
            "5AM"
          end

        time =
          if range == 6 do
            "6AM"
          end

        time =
          if range == 7 do
            "7AM"
          end

        time =
          if range == 8 do
            "8AM"
          end

        time =
          if range == 9 do
            "9AM"
          end

        time =
          if range == 10 do
            "10AM"
          end

        time =
          if range == 11 do
            "11AM"
          end

        time =
          if range == 12 do
            "12PM"
          end

        time =
          if range == 13 do
            "1PM"
          end

        time =
          if range == 14 do
            "2PM"
          end

        time =
          if range == 15 do
            "3PM"
          end

        time =
          if range == 16 do
            "4PM"
          end

        time =
          if range == 17 do
            "5PM"
          end

        time =
          if range == 18 do
            "6PM"
          end

        time =
          if range == 19 do
            "7PM"
          end

        time =
          if range == 20 do
            "8PM"
          end

        time =
          if range == 21 do
            "9PM"
          end

        time =
          if range == 22 do
            "10PM"
          end

        time =
          if range == 23 do
            "11PM"
          end

        time =
          if range == 24 do
            "12PM"
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

    discount =
      if id == "0" do
        Repo.all(from(s in BoatNoodle.BN.DiscountItem))
      else
        Repo.all(from(s in BoatNoodle.BN.DiscountItem, where: s.discountid == ^id))
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

    {p, included_spend} =
      if a["include_s"] != nil do
        p = a["include_s"] |> hd
        included_spend = p.price
        {p, included_spend}
      else
        p = ""
        included_spend = ""
        {p, included_spend}
      end

    {p, is_activate} =
      if a["is_activa"] != nil do
        p = a["is_activa"] |> hd
        is_activate = p.price
        {p, is_activate}
      else
        p = ""
        is_activate = ""
        {p, is_activate}
      end

    {p, is_default_combo} =
      if a["is_defaul"] != nil do
        p = a["is_defaul"] |> hd
        is_default_combo = p.price
        {p, is_default_combo}
      else
        p = ""
        is_default_combo = ""
        {p, is_default_combo}
      end

    {p, enable_disc} =
      if a["enable_di"] != nil do
        p = a["enable_di"] |> hd
        enable_disc = p.price
        {p, enable_disc}
      else
        p = ""
        enable_disc = ""
        {p, enable_disc}
      end

    included_spend =
      if included_spend == "on" do
        1
      else
        0
      end

    is_activate =
      if is_activate == "on" do
        1
      else
        0
      end

    if is_default_combo == "on" do
      1
    else
      0
    end

    if enable_disc == "on" do
      1
    else
      0
    end

    brand_id = payload["brand_id"] |> String.to_integer()

    user_id = payload["user_id"]

    subcat = Repo.get_by(BoatNoodle.BN.ItemSubcat, subcatid: id, brand_id: brand_id)

    update_item_subcat_params = %{
      itemname: name,
      itemprice: price,
      enable_disc: enable_disc,
      is_default_combo: is_default_combo,
      is_activate: is_activate,
      include_spend: included_spend
    }

    update_item_subcat =
      BoatNoodle.BN.ItemSubcat.changeset(
        subcat,
        update_item_subcat_params,
        user_id,
        "Update Combo ItemSubcat "
      )

    case Repo.update(update_item_subcat) do
      {:ok, item_subcat} ->
        true

      _ ->
        IO.puts("failed update item subcat")
        false
    end

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

        update_combo_details_params = %{top_up: top_up, unit_price: unit_price}

        update_combo_details =
          BoatNoodle.BN.ComboDetails.changeset(
            combo,
            update_combo_details_params,
            user_id,
            "Update Combo Details"
          )

        case Repo.update(update_combo_details) do
          {:ok, combo_details} ->
            true

          _ ->
            IO.puts("failed combo details update")
            false
        end
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
