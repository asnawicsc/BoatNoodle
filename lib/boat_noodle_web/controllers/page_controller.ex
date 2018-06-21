alias BoatNoodle.BN

defmodule BoatNoodleWeb.PageController do
  use BoatNoodleWeb, :controller
  import Ecto.Query
  require IEx

  def get_brands(conn, _params) do
    brands = Repo.all(Brand) |> Enum.map(fn x -> %{name: x} end) |> Poison.encode!()
    send_resp(conn, 200, brands)
  end

  def index(conn, _params) do
    brands = Repo.all(Brand) |> hd()

    if conn.private.plug_session["brand"] == nil do
      conn
      |> redirect(to: user_path(conn, :login, brands.domain_name))
    else
      render(conn, "index.html")
    end
  end

  def webhook_get(conn, params) do
    IO.inspect(params)
    send_resp(conn, 200, "hello.")
  end

  def webhook_post(conn, params) do
    IO.inspect(params)
    a = params["details"] |> hd()

    sales_required_keys = [
      "salesid",
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
      "sales_details",
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
      "salespay_id",
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
                  send_resp(conn, 200, "Sales  create successfully.")

                {:error, %Ecto.Changeset{} = changeset} ->
                  send_resp(conn, 500, "Sales payment failed to create.")
              end

            {:error, %Ecto.Changeset{} = changeset} ->
              send_resp(conn, 500, "Sales master failed to create.")
          end

        {:error, %Ecto.Changeset{} = changeset} ->
          send_resp(conn, 500, "Sales failed to create. Please use the latest sales ID")
      end
    else
      send_resp(conn, 500, "API failed to transaction. Check your data and try again.")
    end
  end

  def no_page_found(conn, _params) do
    conn
    |> put_flash(:error, "No page found")
    |> redirect(to: page_path(conn, :index, BN.get_domain(conn)))
  end
end
