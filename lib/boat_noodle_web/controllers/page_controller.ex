defmodule BoatNoodleWeb.PageController do
  use BoatNoodleWeb, :controller
  use Task
  import Ecto.Query
  require IEx

  def authenticate_login(conn, %{"username" => username, "password" => password}) do
    user = Repo.get_by(User, username: username)

    if user != nil do
      p2 = String.replace(user.password, "$2y", "$2b")

      if Comeonin.Bcrypt.checkpw(password, p2) do
        conn
        |> put_session(:user_id, user.id)
        |> redirect(to: page_path(conn, :report_index))
      else
        conn
        |> put_flash(:error, "Wrong password!")
        |> redirect(to: page_path(conn, :report_login))
      end
    else
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: page_path(conn, :report_login))
    end
  end

  def report_login(conn, params) do
    render(conn, "login.html")
  end

  def report_index(conn, params) do
    brands = Repo.all(from(b in Brand, select: %{name: b.domain_name, id: b.id}))

    render(conn, "index.html", brands: brands)
  end

  def get_brands(conn, _params) do
    brands = Repo.all(Brand) |> Enum.map(fn x -> %{name: x.domain_name} end) |> Poison.encode!()
    send_resp(conn, 200, brands)
  end

  def index(conn, _params) do
    brands = Repo.all(Brand) |> hd()

    conn
    |> redirect(to: user_path(conn, :login, brands.domain_name))
  end

  def index2(conn, _params) do
    render(conn, "dashboard.html")
  end

  def webhook_get(conn, params) do
    auth = conn.req_headers |> Enum.filter(fn x -> elem(x, 0) == "authorization" end)

    cond do
      auth == [] ->
        send_resp(conn, 400, "please include username password.")

      params["brand"] == nil ->
        send_resp(conn, 400, "please include brand name.")

      params["branch_id"] == nil ->
        send_resp(conn, 400, "please include branch id.")

      params["fields"] == nil ->
        send_resp(conn, 400, "please include sales id in field.")

      params["branch_id"] != nil and params["branch_id"] != nil and auth != [] ->
        branch_id = params["branch_id"]
        brand = params["brand"]
        fields = params["sales_id"]
        bb = Repo.get_by(Brand, domain_name: brand)
        branch = Repo.get_by(Branch, branchid: branch_id, brand_id: bb.id)

        if branch != nil do
          invoiceno =
            Repo.all(
              from(
                s in Sales,
                where: s.branchid == ^branch_id and s.brand_id == ^bb.id,
                select: %{
                  invoiceno: s.invoiceno
                },
                order_by: [s.invoiceno]
              )
            )
            |> Enum.map(fn x -> x.invoiceno end)
            |> Enum.map(fn x -> String.to_integer(x) end)
            |> Enum.max()

          id =
            (invoiceno + 1)
            |> Integer.to_string()

          salesid = branch.branchcode <> "" <> id
          json_map = %{salesid: salesid} |> Poison.encode!()
          send_resp(conn, 200, json_map)
        else
          send_resp(conn, 400, "branch doesnt exist.")
        end
    end
  end

  def webhook_post(conn, params) do
    a = params["details"] |> hd()

    sales_required_keys = [
      "invoiceno",
      "salesdate",
      "salesdatetime",
      "tbl_no",
      "pax",
      "branchid",
      "staffid",
      "type",
      "is_void",
      "void_by",
      "voidreason",
      "remark",
      "updated_at",
      "created_at",
      "brand_id"
    ]

    salesdetail_required_keys = [
      "orderid",
      "itemid",
      "itemname",
      "itemcode",
      "itemcustomid",
      "qty",
      "order_price",
      "is_void",
      "void_by",
      "voidreason",
      "remark",
      "combo_id",
      "discountid",
      "afterdisc",
      "remaks",
      "unit_price",
      "created_at",
      "updated_at",
      "brand_id"
    ]

    salespayment_required_keys = [
      "sub_total",
      "after_disc",
      "service_charge",
      "gst_charge",
      "rounding",
      "grand_total",
      "cash",
      "changes",
      "payment_type",
      "card_no",
      "taxcode",
      "disc_amt",
      "voucher_code",
      "discountid",
      "payment_type_id1",
      "payment_name1",
      "payment_type_amt1",
      "payment_code1",
      "payment_type_id2",
      "payment_name2",
      "payment_type_amt2",
      "payment_code2",
      "updated_at",
      "created_at",
      "brand_id"
    ]

    if Enum.all?(sales_required_keys, &Map.has_key?(params["sales"], &1)) &&
         Enum.all?(salesdetail_required_keys, &Map.has_key?(a, &1)) &&
         Enum.all?(salespayment_required_keys, &Map.has_key?(params["payment"], &1)) == true do
      sales_params = for {key, val} <- params["sales"], into: %{}, do: {String.to_atom(key), val}
      sales_master_params = for {key, val} <- a, into: %{}, do: {String.to_atom(key), val}

      sales_payment_params =
        for {key, val} <- params["payment"], into: %{}, do: {String.to_atom(key), val}

      if Map.get(sales_params, :salesid) == nil do
        invoiceno =
          Repo.all(
            from(
              s in Sales,
              where: s.branchid == ^sales_params.branchid,
              select: %{
                invoiceno: s.invoiceno
              },
              order_by: [s.invoiceno]
            )
          )
          |> Enum.map(fn x -> x.invoiceno end)
          |> Enum.map(fn x -> String.to_integer(x) end)
          |> Enum.max()

        brach_name =
          Repo.all(
            from(
              b in Branch,
              where: b.branchid == ^sales_params.branchid,
              select: %{
                branchcode: b.branchcode
              }
            )
          )
          |> hd()

        id =
          (invoiceno + 1)
          |> Integer.to_string()

        salesid = brach_name.branchcode <> "" <> id

        sales_params = Map.put(sales_params, :salesid, salesid)
        sales_params = Map.put(sales_params, :invoiceno, id)
      end

      sales_exist = Repo.get_by(Sales, salesid: sales_params.salesid)

      cond do
        sales_exist != nil ->
          send_resp(conn, 501, "Sales id exist.")

        sales_exist == nil ->
          case BN.create_sales(sales_params) do
            {:ok, sales} ->
              conn

              sales_master_params = Map.put(sales_master_params, :salesid, sales.salesid)

              case BN.create_sales_master(sales_master_params) do
                {:ok, sales_master} ->
                  conn
                  sales_payment_params = Map.put(sales_payment_params, :salesid, sales.salesid)

                  case BN.create_sales_payment(sales_payment_params) do
                    {:ok, sales_payment} ->
                      conn

                      Task.start_link(__MODULE__, :inform_sales_update, [
                        sales.brand_id,
                        sales.branchid,
                        sales.created_at
                      ])

                      send_resp(conn, 200, "Sales #{sales.salesid} create successfully.")

                    {:error, %Ecto.Changeset{} = changeset} ->
                      send_resp(conn, 504, "Sales payment failed to create.")
                  end

                {:error, %Ecto.Changeset{} = changeset} ->
                  send_resp(conn, 505, "Sales master failed to create.")
              end

            {:error, %Ecto.Changeset{} = changeset} ->
              send_resp(conn, 506, "Sales failed to create. Please use the latest sales ID")
          end
      end
    else
      send_resp(conn, 507, "API failed to transaction. Check your data and try again.")
    end
  end

  def inform_sales_update(brand_id, branchid, created_at) do
    topic = "sales:#{brand_id}_#{branchid}"
    event = "update_sales_grandtotal"

    # start_date = created_at |> DateTime.to_date()
    # end_date = created_at |> DateTime.to_date() |> Timex.shift(days: 1)
    start_date = Date.new(2018, 6, 14) |> elem(1)
    end_date = Date.new(2018, 6, 15) |> elem(1)

    outlet_sales =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: sp.salesid == s.salesid,
          left_join: b in BoatNoodle.BN.Branch,
          on: s.branchid == b.branchid,
          where:
            s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.branchid == ^branchid and
              s.brand_id == ^brand_id,
          group_by: s.branchid,
          select: %{
            brand_id: s.brand_id,
            branch_id: s.branchid,
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

    BoatNoodleWeb.Endpoint.broadcast(topic, event, hd(outlet_sales))
  end

  def no_page_found(conn, _params) do
    conn
    |> put_flash(:error, "No page found")
    |> redirect(to: page_path(conn, :index, BN.get_domain(conn)))
  end
end
