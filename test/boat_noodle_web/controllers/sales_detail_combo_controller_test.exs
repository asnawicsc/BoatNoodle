defmodule BoatNoodleWeb.SalesDetailComboControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{afterdisc: "120.5", brand_id: 42, created_at: ~N[2010-04-17 14:00:00.000000], is_combo_header: 42, is_void: 42, itemname: "some itemname", order_id: "some order_id", order_price: "120.5", qty: 42, remark: "some remark", sales_details_combo: 42, sales_id: "some sales_id", top_up: "120.5", unit_price: "120.5", updated_at: ~N[2010-04-17 14:00:00.000000], void_by: "some void_by", void_reason: "some void_reason"}
  @update_attrs %{afterdisc: "456.7", brand_id: 43, created_at: ~N[2011-05-18 15:01:01.000000], is_combo_header: 43, is_void: 43, itemname: "some updated itemname", order_id: "some updated order_id", order_price: "456.7", qty: 43, remark: "some updated remark", sales_details_combo: 43, sales_id: "some updated sales_id", top_up: "456.7", unit_price: "456.7", updated_at: ~N[2011-05-18 15:01:01.000000], void_by: "some updated void_by", void_reason: "some updated void_reason"}
  @invalid_attrs %{afterdisc: nil, brand_id: nil, created_at: nil, is_combo_header: nil, is_void: nil, itemname: nil, order_id: nil, order_price: nil, qty: nil, remark: nil, sales_details_combo: nil, sales_id: nil, top_up: nil, unit_price: nil, updated_at: nil, void_by: nil, void_reason: nil}

  def fixture(:sales_detail_combo) do
    {:ok, sales_detail_combo} = BN.create_sales_detail_combo(@create_attrs)
    sales_detail_combo
  end

  describe "index" do
    test "lists all sales_detail_combo", %{conn: conn} do
      conn = get conn, sales_detail_combo_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Sales detail combo"
    end
  end

  describe "new sales_detail_combo" do
    test "renders form", %{conn: conn} do
      conn = get conn, sales_detail_combo_path(conn, :new)
      assert html_response(conn, 200) =~ "New Sales detail combo"
    end
  end

  describe "create sales_detail_combo" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, sales_detail_combo_path(conn, :create), sales_detail_combo: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == sales_detail_combo_path(conn, :show, id)

      conn = get conn, sales_detail_combo_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Sales detail combo"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, sales_detail_combo_path(conn, :create), sales_detail_combo: @invalid_attrs
      assert html_response(conn, 200) =~ "New Sales detail combo"
    end
  end

  describe "edit sales_detail_combo" do
    setup [:create_sales_detail_combo]

    test "renders form for editing chosen sales_detail_combo", %{conn: conn, sales_detail_combo: sales_detail_combo} do
      conn = get conn, sales_detail_combo_path(conn, :edit, sales_detail_combo)
      assert html_response(conn, 200) =~ "Edit Sales detail combo"
    end
  end

  describe "update sales_detail_combo" do
    setup [:create_sales_detail_combo]

    test "redirects when data is valid", %{conn: conn, sales_detail_combo: sales_detail_combo} do
      conn = put conn, sales_detail_combo_path(conn, :update, sales_detail_combo), sales_detail_combo: @update_attrs
      assert redirected_to(conn) == sales_detail_combo_path(conn, :show, sales_detail_combo)

      conn = get conn, sales_detail_combo_path(conn, :show, sales_detail_combo)
      assert html_response(conn, 200) =~ "some updated itemname"
    end

    test "renders errors when data is invalid", %{conn: conn, sales_detail_combo: sales_detail_combo} do
      conn = put conn, sales_detail_combo_path(conn, :update, sales_detail_combo), sales_detail_combo: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Sales detail combo"
    end
  end

  describe "delete sales_detail_combo" do
    setup [:create_sales_detail_combo]

    test "deletes chosen sales_detail_combo", %{conn: conn, sales_detail_combo: sales_detail_combo} do
      conn = delete conn, sales_detail_combo_path(conn, :delete, sales_detail_combo)
      assert redirected_to(conn) == sales_detail_combo_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, sales_detail_combo_path(conn, :show, sales_detail_combo)
      end
    end
  end

  defp create_sales_detail_combo(_) do
    sales_detail_combo = fixture(:sales_detail_combo)
    {:ok, sales_detail_combo: sales_detail_combo}
  end
end
