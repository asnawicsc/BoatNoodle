defmodule BoatNoodleWeb.SalesMasterControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{casher: "some casher", pax: 42, payment: "some payment", receipt_no: 42, table: 42, total_amount: "120.5"}
  @update_attrs %{casher: "some updated casher", pax: 43, payment: "some updated payment", receipt_no: 43, table: 43, total_amount: "456.7"}
  @invalid_attrs %{casher: nil, pax: nil, payment: nil, receipt_no: nil, table: nil, total_amount: nil}

  def fixture(:sales_master) do
    {:ok, sales_master} = BN.create_sales_master(@create_attrs)
    sales_master
  end

  describe "index" do
    test "lists all sales_master", %{conn: conn} do
      conn = get conn, sales_master_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Sales master"
    end
  end

  describe "new sales_master" do
    test "renders form", %{conn: conn} do
      conn = get conn, sales_master_path(conn, :new)
      assert html_response(conn, 200) =~ "New Sales master"
    end
  end

  describe "create sales_master" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, sales_master_path(conn, :create), sales_master: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == sales_master_path(conn, :show, id)

      conn = get conn, sales_master_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Sales master"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, sales_master_path(conn, :create), sales_master: @invalid_attrs
      assert html_response(conn, 200) =~ "New Sales master"
    end
  end

  describe "edit sales_master" do
    setup [:create_sales_master]

    test "renders form for editing chosen sales_master", %{conn: conn, sales_master: sales_master} do
      conn = get conn, sales_master_path(conn, :edit, sales_master)
      assert html_response(conn, 200) =~ "Edit Sales master"
    end
  end

  describe "update sales_master" do
    setup [:create_sales_master]

    test "redirects when data is valid", %{conn: conn, sales_master: sales_master} do
      conn = put conn, sales_master_path(conn, :update, sales_master), sales_master: @update_attrs
      assert redirected_to(conn) == sales_master_path(conn, :show, sales_master)

      conn = get conn, sales_master_path(conn, :show, sales_master)
      assert html_response(conn, 200) =~ "some updated casher"
    end

    test "renders errors when data is invalid", %{conn: conn, sales_master: sales_master} do
      conn = put conn, sales_master_path(conn, :update, sales_master), sales_master: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Sales master"
    end
  end

  describe "delete sales_master" do
    setup [:create_sales_master]

    test "deletes chosen sales_master", %{conn: conn, sales_master: sales_master} do
      conn = delete conn, sales_master_path(conn, :delete, sales_master)
      assert redirected_to(conn) == sales_master_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, sales_master_path(conn, :show, sales_master)
      end
    end
  end

  defp create_sales_master(_) do
    sales_master = fixture(:sales_master)
    {:ok, sales_master: sales_master}
  end
end
