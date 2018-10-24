defmodule BoatNoodle.MallSync do
  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto
  ]

  require IEx
  alias BoatNoodle.Repo

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
    ModalLog
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
    Enum.each(repos(), & &1.start_link(pool_size: 1))

    connect_to

    # Signal shutdown
    IO.puts("Success!")
    :init.stop()
  end

  def connect_to do
    {:ok, connection} = SftpEx.connect(host: '110.4.42.48', user: 'ubuntu', password: 'scmcapp')

    # image_path = Application.app_dir(:boat_noodle, "priv/static/images")
    date_str = Date.utc_today() |> Date.to_string() |> String.split("-") |> Enum.join()

    date_str2 =
      Date.utc_today() |> Date.to_string() |> String.split("-") |> Enum.reverse() |> Enum.join()

    tenant_machine_id = "12345678"
    # new_path = image_path <> "/H#{tenant_machine_id}-#{date_str}.txt"
    # bin = File.read!(new_path)

    # stream =
    #   File.stream!(new_path)
    #   |> Stream.into(SftpEx.stream!(conn, "/boat_noodle/sales.txt"))
    #   |> Stream.run()
    no_range = 0..23
    sales_data = sales_payment_data()

    data =
      for hour <- no_range do
        line(
          tenant_machine_id,
          1,
          date_str2,
          hour,
          sales_data
        )
      end

    SFTP.TransferService.upload(
      connection,
      "/boat_noodle/H#{tenant_machine_id}-#{date_str}.txt",
      Enum.join(data)
    )

    SftpEx.disconnect(connection)
  end

  def sales_payment_data() do
    date = Date.utc_today()

    sales_data =
      Repo.all(
        from(
          s in Sales,
          left_join: sp in SalesPayment,
          on: sp.salesid == s.salesid,
          where:
            s.brand_id == ^1 and s.is_void == ^0 and s.salesdate == ^date and s.branchid == ^"2",
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
      |> Enum.map(fn x -> if x.disc_amt == 0, do: 0.00, else: Decimal.to_float(x.disc_amt) end)
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
end
