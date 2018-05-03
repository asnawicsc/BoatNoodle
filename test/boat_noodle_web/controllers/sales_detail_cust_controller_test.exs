defmodule BoatNoodleWeb.SalesDetailCustControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{created_at: "2010-04-17 14:00:00.000000Z", custom_name: "some custom_name", customer_price: "120.5", orderid: "some orderid", salescustid: 42, updated_at: "2010-04-17 14:00:00.000000Z"}
  @update_attrs %{created_at: "2011-05-18 15:01:01.000000Z", custom_name: "some updated custom_name", customer_price: "456.7", orderid: "some updated orderid", salescustid: 43, updated_at: "2011-05-18 15:01:01.000000Z"}
  @invalid_attrs %{created_at: nil, custom_name: nil, customer_price: nil, orderid: nil, salescustid: nil, updated_at: nil}

  def fixture(:sales_detail_cust) do
    {:ok, sales_detail_cust} = BN.create_sales_detail_cust(@create_attrs)
    sales_detail_cust
  end

  describe "index" do
    test "lists all salesdetailcust", %{conn: conn} do
      conn = get conn, sales_detail_cust_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Salesdetailcust"
    end
  end

  describe "new sales_detail_cust" do
    test "renders form", %{conn: conn} do
      conn = get conn, sales_detail_cust_path(conn, :new)
      assert html_response(conn, 200) =~ "New Sales detail cust"
    end
  end

  describe "create sales_detail_cust" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, sales_detail_cust_path(conn, :create), sales_detail_cust: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == sales_detail_cust_path(conn, :show, id)

      conn = get conn, sales_detail_cust_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Sales detail cust"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, sales_detail_cust_path(conn, :create), sales_detail_cust: @invalid_attrs
      assert html_response(conn, 200) =~ "New Sales detail cust"
    end
  end

  describe "edit sales_detail_cust" do
    setup [:create_sales_detail_cust]

    test "renders form for editing chosen sales_detail_cust", %{conn: conn, sales_detail_cust: sales_detail_cust} do
      conn = get conn, sales_detail_cust_path(conn, :edit, sales_detail_cust)
      assert html_response(conn, 200) =~ "Edit Sales detail cust"
    end
  end

  describe "update sales_detail_cust" do
    setup [:create_sales_detail_cust]

    test "redirects when data is valid", %{conn: conn, sales_detail_cust: sales_detail_cust} do
      conn = put conn, sales_detail_cust_path(conn, :update, sales_detail_cust), sales_detail_cust: @update_attrs
      assert redirected_to(conn) == sales_detail_cust_path(conn, :show, sales_detail_cust)

      conn = get conn, sales_detail_cust_path(conn, :show, sales_detail_cust)
      assert html_response(conn, 200) =~ "some updated custom_name"
    end

    test "renders errors when data is invalid", %{conn: conn, sales_detail_cust: sales_detail_cust} do
      conn = put conn, sales_detail_cust_path(conn, :update, sales_detail_cust), sales_detail_cust: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Sales detail cust"
    end
  end

  describe "delete sales_detail_cust" do
    setup [:create_sales_detail_cust]

    test "deletes chosen sales_detail_cust", %{conn: conn, sales_detail_cust: sales_detail_cust} do
      conn = delete conn, sales_detail_cust_path(conn, :delete, sales_detail_cust)
      assert redirected_to(conn) == sales_detail_cust_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, sales_detail_cust_path(conn, :show, sales_detail_cust)
      end
    end
  end

  defp create_sales_detail_cust(_) do
    sales_detail_cust = fixture(:sales_detail_cust)
    {:ok, sales_detail_cust: sales_detail_cust}
  end
end
