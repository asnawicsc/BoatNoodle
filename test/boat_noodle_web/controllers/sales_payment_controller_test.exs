defmodule BoatNoodleWeb.SalesPaymentControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{after_disc: "120.5", card_no: 42, cash: "120.5", changes: "120.5", created_at: "2010-04-17 14:00:00.000000Z", disc_amt: "120.5", discountid: "some discountid", grand_total: "120.5", gst_charge: "120.5", payment_code1: "some payment_code1", payment_code2: "some payment_code2", payment_type: "some payment_type", payment_type_am1: "120.5", payment_type_am2: "120.5", payment_type_id1: 42, payment_type_id2: 42, rounding: "120.5", salesid: "some salesid", salespay_id: 42, service_charge: "120.5", sub_total: "120.5", taxcode: "some taxcode", updated_at: "2010-04-17 14:00:00.000000Z", voucher_code: "some voucher_code"}
  @update_attrs %{after_disc: "456.7", card_no: 43, cash: "456.7", changes: "456.7", created_at: "2011-05-18 15:01:01.000000Z", disc_amt: "456.7", discountid: "some updated discountid", grand_total: "456.7", gst_charge: "456.7", payment_code1: "some updated payment_code1", payment_code2: "some updated payment_code2", payment_type: "some updated payment_type", payment_type_am1: "456.7", payment_type_am2: "456.7", payment_type_id1: 43, payment_type_id2: 43, rounding: "456.7", salesid: "some updated salesid", salespay_id: 43, service_charge: "456.7", sub_total: "456.7", taxcode: "some updated taxcode", updated_at: "2011-05-18 15:01:01.000000Z", voucher_code: "some updated voucher_code"}
  @invalid_attrs %{after_disc: nil, card_no: nil, cash: nil, changes: nil, created_at: nil, disc_amt: nil, discountid: nil, grand_total: nil, gst_charge: nil, payment_code1: nil, payment_code2: nil, payment_type: nil, payment_type_am1: nil, payment_type_am2: nil, payment_type_id1: nil, payment_type_id2: nil, rounding: nil, salesid: nil, salespay_id: nil, service_charge: nil, sub_total: nil, taxcode: nil, updated_at: nil, voucher_code: nil}

  def fixture(:sales_payment) do
    {:ok, sales_payment} = BN.create_sales_payment(@create_attrs)
    sales_payment
  end

  describe "index" do
    test "lists all salespayment", %{conn: conn} do
      conn = get conn, sales_payment_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Salespayment"
    end
  end

  describe "new sales_payment" do
    test "renders form", %{conn: conn} do
      conn = get conn, sales_payment_path(conn, :new)
      assert html_response(conn, 200) =~ "New Sales payment"
    end
  end

  describe "create sales_payment" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, sales_payment_path(conn, :create), sales_payment: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == sales_payment_path(conn, :show, id)

      conn = get conn, sales_payment_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Sales payment"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, sales_payment_path(conn, :create), sales_payment: @invalid_attrs
      assert html_response(conn, 200) =~ "New Sales payment"
    end
  end

  describe "edit sales_payment" do
    setup [:create_sales_payment]

    test "renders form for editing chosen sales_payment", %{conn: conn, sales_payment: sales_payment} do
      conn = get conn, sales_payment_path(conn, :edit, sales_payment)
      assert html_response(conn, 200) =~ "Edit Sales payment"
    end
  end

  describe "update sales_payment" do
    setup [:create_sales_payment]

    test "redirects when data is valid", %{conn: conn, sales_payment: sales_payment} do
      conn = put conn, sales_payment_path(conn, :update, sales_payment), sales_payment: @update_attrs
      assert redirected_to(conn) == sales_payment_path(conn, :show, sales_payment)

      conn = get conn, sales_payment_path(conn, :show, sales_payment)
      assert html_response(conn, 200) =~ "some updated discountid"
    end

    test "renders errors when data is invalid", %{conn: conn, sales_payment: sales_payment} do
      conn = put conn, sales_payment_path(conn, :update, sales_payment), sales_payment: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Sales payment"
    end
  end

  describe "delete sales_payment" do
    setup [:create_sales_payment]

    test "deletes chosen sales_payment", %{conn: conn, sales_payment: sales_payment} do
      conn = delete conn, sales_payment_path(conn, :delete, sales_payment)
      assert redirected_to(conn) == sales_payment_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, sales_payment_path(conn, :show, sales_payment)
      end
    end
  end

  defp create_sales_payment(_) do
    sales_payment = fixture(:sales_payment)
    {:ok, sales_payment: sales_payment}
  end
end
