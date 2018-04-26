defmodule BoatNoodleWeb.TaxControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{receipt_no: "some receipt_no", sales_time: ~N[2010-04-17 14:00:00.000000], standard_supply_rate: "120.5", tax: "120.5"}
  @update_attrs %{receipt_no: "some updated receipt_no", sales_time: ~N[2011-05-18 15:01:01.000000], standard_supply_rate: "456.7", tax: "456.7"}
  @invalid_attrs %{receipt_no: nil, sales_time: nil, standard_supply_rate: nil, tax: nil}

  def fixture(:tax) do
    {:ok, tax} = BN.create_tax(@create_attrs)
    tax
  end

  describe "index" do
    test "lists all tax", %{conn: conn} do
      conn = get conn, tax_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Tax"
    end
  end

  describe "new tax" do
    test "renders form", %{conn: conn} do
      conn = get conn, tax_path(conn, :new)
      assert html_response(conn, 200) =~ "New Tax"
    end
  end

  describe "create tax" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, tax_path(conn, :create), tax: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == tax_path(conn, :show, id)

      conn = get conn, tax_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Tax"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, tax_path(conn, :create), tax: @invalid_attrs
      assert html_response(conn, 200) =~ "New Tax"
    end
  end

  describe "edit tax" do
    setup [:create_tax]

    test "renders form for editing chosen tax", %{conn: conn, tax: tax} do
      conn = get conn, tax_path(conn, :edit, tax)
      assert html_response(conn, 200) =~ "Edit Tax"
    end
  end

  describe "update tax" do
    setup [:create_tax]

    test "redirects when data is valid", %{conn: conn, tax: tax} do
      conn = put conn, tax_path(conn, :update, tax), tax: @update_attrs
      assert redirected_to(conn) == tax_path(conn, :show, tax)

      conn = get conn, tax_path(conn, :show, tax)
      assert html_response(conn, 200) =~ "some updated receipt_no"
    end

    test "renders errors when data is invalid", %{conn: conn, tax: tax} do
      conn = put conn, tax_path(conn, :update, tax), tax: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Tax"
    end
  end

  describe "delete tax" do
    setup [:create_tax]

    test "deletes chosen tax", %{conn: conn, tax: tax} do
      conn = delete conn, tax_path(conn, :delete, tax)
      assert redirected_to(conn) == tax_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, tax_path(conn, :show, tax)
      end
    end
  end

  defp create_tax(_) do
    tax = fixture(:tax)
    {:ok, tax: tax}
  end
end
