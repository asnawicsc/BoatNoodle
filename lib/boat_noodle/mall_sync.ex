defmodule BoatNoodle.MallSync do
  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :inets
  ]

  require IEx
  alias BoatNoodle.Repo
  alias BoatNoodle.RepoGeop
  import Ecto.Query
  alias BoatNoodle.BN

  alias BoatNoodle.BN.{
    Discount,
    DiscountCatalog,
    DiscountCatalogMaster,
    DiscountCategory,
    DiscountItem,
    DiscountType,
    ItemCat,
    MenuCatalogMaster,
    Organization,
    PaymentType,
    Remark,
    Sales,
    SalesDetailCust,
    SalesMaster,
    SalesPayment,
    Staff,
    StaffType,
    Tag,
    TagCatalog,
    TagItems,
    Tax,
    User,
    UserBranchAccess,
    UserRole,
    VoidItems,
    ComboMap,
    ComboDetails,
    Category,
    MenuCatalog,
    ItemSubcat,
    Branch,
    Tag,
    Brand,
    ApiLog,
    Voucher,
    HistoryData,
    ModalLog,
    DailyTransaction
  }

  def boat_noodle, do: :boat_noodle

  def repos, do: Application.get_env(boat_noodle(), :ecto_repos, [])

  def start_sync do
    me = boat_noodle()

    IO.puts("Loading #{me}..")
    # Load the code for myapp, but don't start it
    :ok = Application.load(me)

    IO.puts("Starting dependencies..")
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo(s) for myapp
    IO.puts("Starting repos..")
    Enum.each(repos(), & &1.start_link(pool_size: 10))

    connect_to(1, "2", "MY")
    connect_to(2, "2", "MY")
    connect_to(3, "2", "MY")
    connect_to(1, "7", "MY")
    connect_to(2, "7", "MY")
    connect_to(3, "7", "MY")
    connect_to(1, "23", "MY")
    connect_to(2, "23", "MY")
    connect_to(3, "23", "MY")
    connect_to(1, "26", "MY")
    connect_to(2, "26", "MY")
    connect_to(3, "26", "MY")

    # Signal shutdown
    IO.puts("Success!")
    :init.stop()
  end

  def connect_to(days_ago, branchid_str, country) do
    case country do
      "MY" ->
        {tenant_machine_id, password} =
          case branchid_str do
            "2" ->
              {'50000078', 'e8kgjhR'}

            "7" ->
              {'53000147', '6W95xLM'}

            "26" ->
              {'51000039', '52F4A1F'}

            "23" ->
              {'52000183', '4LpAUv1'}

            "6" ->
              {'30000298', ''}
          end

        host = 'sunway.serveftp.org'

        # # connects to host and assigns pid
        {:ok, pid} = :inets.start(:ftpc, host: host)

        # # logs into host with username and password
        :ftp.user(pid, tenant_machine_id, password)

        date_str =
          Date.utc_today()
          |> Timex.shift(days: -days_ago)
          |> Date.to_string()
          |> String.split("-")
          |> Enum.join()

        date_str2 =
          Date.utc_today()
          |> Timex.shift(days: -days_ago)
          |> Date.to_string()
          |> String.split("-")
          |> Enum.reverse()
          |> Enum.join()

        no_range = 0..23
        sales_data = sales_payment_data(days_ago, branchid_str)

        data =
          for hour <- no_range do
            line(
              tenant_machine_id,
              date_str,
              date_str2,
              hour,
              sales_data
            )
          end

        :ftp.send_bin(pid, Enum.join(data), 'H#{tenant_machine_id}_#{date_str}.txt')

        :inets.stop(:ftpc, pid)

      "SG" ->
        tenant_machine_id = '0600590'

        date_str =
          Date.utc_today()
          |> Timex.shift(days: -days_ago)
          |> Date.to_string()
          |> String.split("-")
          |> Enum.join()

        date_date =
          Date.utc_today()
          |> Timex.shift(days: -days_ago)

        sales_data =
          sales_payment_data_sg(days_ago, branchid_str, date_str, tenant_machine_id, date_date)

        fsn =
          RepoGeop.all(
            from(
              d in DailyTransaction,
              where: d.transation_date == ^date_str,
              select: d.file_serial_number,
              order_by: [desc: d.id],
              limit: 10
            )
          )
          |> List.first()

        # ip = "202.79.215.178"
        # port = "2222"
        # username = "dts_pos0600590_p"
        # path = "/POS/06/0600590"

        # # # connects to host and assigns pid
        # {:ok, pid} = :inets.start(:ftpc, host: host)

        # # # logs into host with username and password
        # :ftp.user(pid, tenant_machine_id, password)

        # :ftp.send_bin(pid, sales_data, path <> 'D#{tenant_machine_id}.#{date_str}.#{fsn}')

        # :inets.stop(:ftpc, pid)

        {:ok, connection} =
          SftpEx.connect(host: '110.4.42.48', user: 'ubuntu', password: 'scmcapp')

        SFTP.TransferService.upload(
          connection,
          "/boat_noodle/D#{tenant_machine_id}#{date_str}.#{fsn}",
          sales_data
        )

        if Date.utc_today().day == 7 do
          month = (Date.utc_today().month - 1) |> Integer.to_string()
          year = Date.utc_today().year |> Integer.to_string()

          end_day =
            Timex.end_of_month(Date.utc_today().year, Date.utc_today().month - 1).day
            |> Integer.to_string()

          month_str = year <> month

          case sg_check_total_sales(
                 branchid_str,
                 "#{year}-#{month}-01",
                 "#{year}-#{month}-#{end_day}"
               ) do
            {:ok, total} ->
              true

            {:error, total} ->
              final =
                (total + 100_000_000.00) |> :erlang.float_to_binary(decimals: 2)
                |> String.replace_prefix("1", "")

              line = "T#{tenant_machine_id}#{month_str}#{final}"

              fsn =
                RepoGeop.all(
                  from(
                    d in DailyTransaction,
                    where: d.transation_date == ^month_str,
                    select: d.file_serial_number,
                    order_by: [desc: d.id],
                    limit: 10
                  )
                )
                |> List.first()

              SFTP.TransferService.upload(
                connection,
                "/boat_noodle/T#{tenant_machine_id}.#{fsn}",
                line
              )
          end
        end

        SftpEx.disconnect(connection)

      _ ->
        true
    end
  end

  def sales_payment_data_sg(days_ago, branchid_str, date_str, tenant_machine_id, date_date) do
    date = Date.utc_today() |> Timex.shift(days: -days_ago)

    sales_data =
      RepoGeop.all(
        from(
          s in Sales,
          left_join: sp in SalesPayment,
          on: sp.salesid == s.salesid,
          where: s.is_void == ^0 and s.salesdate == ^date and s.branchid == ^branchid_str,
          group_by: [s.salesdate],
          select: %{
            date: s.salesdate,
            afterdisc: sum(sp.after_disc),
            serv: sum(sp.service_charge)
          }
        )
      )

    a = sales_data |> hd()
    total = Decimal.to_float(a.afterdisc) + Decimal.to_float(a.serv) + 100_000_000.00
    final = total |> :erlang.float_to_binary(decimals: 2) |> String.replace_prefix("1", "")

    fsn =
      RepoGeop.all(from(d in DailyTransaction, order_by: [desc: d.id], limit: 10)) |> List.first()

    fsn =
      if fsn == nil do
        "000"
      else
        a = "1" <> fsn.file_serial_number
        b = String.to_integer(a)

        c = b + 1
        d = Integer.to_string(c)

        e = String.replace_prefix(d, String.first(d), "")
        e
      end

    check =
      RepoGeop.all(
        from(
          d in DailyTransaction,
          where: d.transation_date == ^date_str,
          order_by: [desc: d.id],
          limit: 10
        )
      )
      |> List.first()

    if check != nil do
      {:ok, dt} =
        BoatNoodle.BN.DailyTransaction.changeset(check, %{
          transation_date: date_str,
          sales_amount: final,
          branchid: branchid_str
        })
        |> RepoGeop.update()
    else
      {:ok, dt} =
        BoatNoodle.BN.DailyTransaction.changeset(%BoatNoodle.BN.DailyTransaction{}, %{
          file_serial_number: fsn,
          transation_date: date_str,
          sales_amount: final,
          branchid: branchid_str,
          sales_date: date_date
        })
        |> RepoGeop.insert()
    end

    "D#{tenant_machine_id}#{date_str}#{final}"
  end

  def sg_check_total_sales(branchid_str, start_date, end_date) do
    s_date = Date.from_iso8601!(start_date)
    e_date = Date.from_iso8601!(end_date)

    drange = Date.range(s_date, e_date)

    sales_data =
      RepoGeop.all(
        from(
          s in Sales,
          left_join: sp in SalesPayment,
          on: sp.salesid == s.salesid,
          where:
            s.is_void == ^0 and s.salesdate >= ^s_date and s.salesdate <= ^e_date and
              s.branchid == ^branchid_str,
          group_by: [s.branchid],
          select: %{
            branchid: s.branchid,
            date: s.salesdate,
            afterdisc: sum(sp.after_disc),
            serv: sum(sp.service_charge)
          }
        )
      )

    a = sales_data |> hd()
    total = Decimal.to_float(a.afterdisc) + Decimal.to_float(a.serv)

    data =
      RepoGeop.all(
        from(
          s in DailyTransaction,
          where: s.sales_date >= ^s_date and s.sales_date <= ^e_date,
          select: %{amount: s.sales_amount, salesdate: s.sales_date}
        )
      )
      |> Enum.reject(fn x -> String.length(x.transation_date) == 6 end)
      |> Enum.map(fn x -> String.to_float(x) end)
      |> Enum.sum()

    result =
      if data == 0 do
        false
      else
        Float.round(data, 2) == Float.round(total, 2)
      end

    if result do
      {:ok, Float.round(data, 2)}
    else
      fsn =
        RepoGeop.all(from(d in DailyTransaction, order_by: [desc: d.id], limit: 10))
        |> List.first()

      fsn =
        if fsn == nil do
          "000"
        else
          a = "1" <> fsn.file_serial_number
          b = String.to_integer(a)

          c = b + 1
          d = Integer.to_string(c)

          e = String.replace_prefix(d, String.first(d), "")
          e
        end

      month_str = Integer.to_string(s_date.year) <> Integer.to_string(s_date.month)
      final = total |> :erlang.float_to_binary(decimals: 2) |> String.replace_prefix("1", "")

      {:ok, dt} =
        BoatNoodle.BN.DailyTransaction.changeset(%BoatNoodle.BN.DailyTransaction{}, %{
          file_serial_number: fsn,
          transation_date: month_str,
          sales_amount: final,
          branchid: branchid_str
        })
        |> RepoGeop.insert()

      {:error, Float.round(total, 2)}
    end
  end

  def sales_payment_data(days_ago, branchid_str) do
    date = Date.utc_today() |> Timex.shift(days: -days_ago)

    sales_data =
      Repo.all(
        from(
          s in Sales,
          left_join: sp in SalesPayment,
          on: sp.salesid == s.salesid,
          where:
            s.brand_id == ^1 and s.is_void == ^0 and s.salesdate == ^date and
              s.branchid == ^branchid_str and sp.payment_type_id1 != ^9 and
              sp.payment_type_id1 != ^21 and sp.payment_type_id1 != ^22,
          select: %{
            datetime: s.salesdatetime,
            afterdisc: sp.after_disc,
            payment_type: sp.payment_type,
            discount_amt: sp.disc_amt,
            gst: sp.gst_charge,
            serv: sp.service_charge,
            pax: s.pax,
            sub_total: sp.sub_total
          }
        )
      )
      |> Enum.map(fn x ->
        %{
          datetime: x.datetime,
          hour: x.datetime.hour,
          after_disc: x.afterdisc,
          payment_type: x.payment_type,
          disc_amt: Decimal.to_float(x.sub_total) - Decimal.to_float(x.afterdisc),
          gst: x.gst,
          serv: x.serv,
          pax: x.pax
        }
      end)
  end

  def sales_payment_data_no_filter_delivery(days_ago, branchid_str) do
    date = Date.utc_today() |> Timex.shift(days: -days_ago)

    sales_data =
      Repo.all(
        from(
          s in Sales,
          left_join: sp in SalesPayment,
          on: sp.salesid == s.salesid,
          where:
            s.brand_id == ^1 and s.is_void == ^0 and s.salesdate == ^date and
              s.branchid == ^branchid_str,
          select: %{
            datetime: s.salesdatetime,
            afterdisc: sp.after_disc,
            payment_type: sp.payment_type,
            discount_amt: sp.disc_amt,
            gst: sp.gst_charge,
            serv: sp.service_charge,
            pax: s.pax,
            sub_total: sp.sub_total
          }
        )
      )
      |> Enum.map(fn x ->
        %{
          datetime: x.datetime,
          hour: x.datetime.hour,
          after_disc: x.afterdisc,
          payment_type: x.payment_type,
          disc_amt: Decimal.to_float(x.sub_total) - Decimal.to_float(x.afterdisc),
          gst: x.gst,
          serv: x.serv,
          pax: x.pax
        }
      end)
  end

  def line(
        tenant_machine_id,
        batch_id,
        date_str2,
        hour,
        sales_data
      ) do
    receipt_count = 0
    gto_sales = 0.00
    gst = 0.00
    discount = 0.00
    serv = 0.00
    pax = 0
    cash = 0.00
    visa = 0.00
    master = 0.00
    amex = 0.00
    voucher_amt = 0.00
    other = 0.00

    receipt_count = sales_data |> Enum.filter(fn x -> x.hour == hour end) |> Enum.count()

    gto_sales =
      sales_data
      |> Enum.filter(fn x -> x.hour == hour end)
      |> Enum.map(fn x -> Decimal.to_float(x.after_disc) end)
      |> Enum.sum()

    gto_sales =
      if gto_sales > 0 do
        gto_sales |> :erlang.float_to_binary(decimals: 2)
      else
        "0.00"
      end

    gst =
      sales_data
      |> Enum.filter(fn x -> x.hour == hour end)
      |> Enum.map(fn x -> Decimal.to_float(x.gst) end)
      |> Enum.sum()

    gst =
      if gst > 0 do
        gst |> :erlang.float_to_binary(decimals: 2)
      else
        "0.00"
      end

    discount =
      sales_data
      |> Enum.filter(fn x -> x.hour == hour end)
      |> Enum.map(fn x -> if x.disc_amt == 0, do: 0.00, else: x.disc_amt end)
      |> Enum.sum()

    discount =
      if discount > 0 do
        discount |> :erlang.float_to_binary(decimals: 2)
      else
        "0.00"
      end

    serv =
      sales_data
      |> Enum.filter(fn x -> x.hour == hour end)
      |> Enum.map(fn x -> Decimal.to_float(x.serv) end)
      |> Enum.sum()

    serv =
      if serv > 0 do
        serv |> :erlang.float_to_binary(decimals: 2)
      else
        "0.00"
      end

    pax =
      sales_data |> Enum.filter(fn x -> x.hour == hour end) |> Enum.map(fn x -> x.pax end)
      |> Enum.sum()

    cash =
      sales_data
      |> Enum.filter(fn x -> x.hour == hour end)
      |> Enum.filter(fn x -> x.payment_type == "CASH" end)
      |> Enum.map(fn x -> Decimal.to_float(x.after_disc) end)
      |> Enum.sum()

    cash =
      if cash > 0 do
        cash |> :erlang.float_to_binary(decimals: 2)
      else
        "0.00"
      end

    visa =
      sales_data
      |> Enum.filter(fn x -> x.hour == hour end)
      |> Enum.filter(fn x -> x.payment_type == "CREDITCARD" end)
      |> Enum.map(fn x -> Decimal.to_float(x.after_disc) end)
      |> Enum.sum()

    visa =
      if visa > 0 do
        visa |> :erlang.float_to_binary(decimals: 2)
      else
        "0.00"
      end

    master = "0.00"
    amex = "0.00"

    voucher_amt = "0.00"

    other =
      sales_data
      |> Enum.filter(fn x -> x.hour == hour end)
      |> Enum.filter(fn x -> x.payment_type == "Other" end)
      |> Enum.map(fn x -> Decimal.to_float(x.after_disc) end)
      |> Enum.sum()

    other =
      if other > 0 do
        other |> :erlang.float_to_binary(decimals: 2)
      else
        "0.00"
      end

    hour = 100 + hour

    hour =
      hour
      |> Integer.to_string()
      |> String.split("")
      |> Enum.reject(fn x -> x == "" end)
      |> List.delete_at(0)
      |> Enum.join("")

    "#{tenant_machine_id}|#{batch_id}|#{date_str2}|#{hour}|#{receipt_count}|#{gto_sales}|#{gst}|#{
      discount
    }|#{serv}|#{pax}|#{cash}|0.00|#{visa}|#{master}|#{amex}|#{voucher_amt}|#{other}|Y\n"
  end

  def manual_process(start_date, end_date, branchid_str) do
    s_date = Date.from_iso8601!(start_date)
    e_date = Date.from_iso8601!(end_date)

    drange = Date.range(s_date, e_date)

    for date <- drange do
      connect_to(Date.diff(Date.utc_today(), date), branchid_str, "MY")
    end
  end

  def connect_to_legacy(days_ago, branchid_str) do
    {:ok, connection} = SftpEx.connect(host: '110.4.42.48', user: 'ubuntu', password: 'scmcapp')

    # image_path = Application.app_dir(:boat_noodle, "priv/static/images")
    date_str =
      Date.utc_today() |> Timex.shift(days: -days_ago) |> Date.to_string() |> String.split("-")
      |> Enum.join()

    date_str2 =
      Date.utc_today()
      |> Timex.shift(days: -days_ago)
      |> Date.to_string()
      |> String.split("-")
      |> Enum.reverse()
      |> Enum.join()

    tenant_machine_id =
      case branchid_str do
        "2" ->
          "50000078"

        "23" ->
          "52000183"

        "7" ->
          "30000298"
      end

    # new_path = image_path <> "/H#{tenant_machine_id}-#{date_str}.txt"
    # bin = File.read!(new_path)

    # stream =
    #   File.stream!(new_path)
    #   |> Stream.into(SftpEx.stream!(conn, "/boat_noodle/sales.txt"))
    #   |> Stream.run()
    no_range = 0..23
    sales_data = sales_payment_data(days_ago, branchid_str)

    data =
      for hour <- no_range do
        line(
          tenant_machine_id,
          date_str,
          date_str2,
          hour,
          sales_data
        )
      end

    SFTP.TransferService.upload(
      connection,
      "/boat_noodle/H#{tenant_machine_id}_#{date_str}.txt",
      Enum.join(data)
    )

    SftpEx.disconnect(connection)
  end
end
