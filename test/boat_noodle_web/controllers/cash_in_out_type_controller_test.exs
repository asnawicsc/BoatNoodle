defmodule BoatNoodleWeb.CashInOutTypeControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{cash_type_id: 42, description: "some description", name: "some name"}
  @update_attrs %{cash_type_id: 43, description: "some updated description", name: "some updated name"}
  @invalid_attrs %{cash_type_id: nil, description: nil, name: nil}

  def fixture(:cash_in_out_type) do
    {:ok, cash_in_out_type} = BN.create_cash_in_out_type(@create_attrs)
    cash_in_out_type
  end

  describe "index" do
    test "lists all cash_in_out_type", %{conn: conn} do
      conn = get conn, cash_in_out_type_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Cash in out type"
    end
  end

  describe "new cash_in_out_type" do
    test "renders form", %{conn: conn} do
      conn = get conn, cash_in_out_type_path(conn, :new)
      assert html_response(conn, 200) =~ "New Cash in out type"
    end
  end

  describe "create cash_in_out_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, cash_in_out_type_path(conn, :create), cash_in_out_type: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == cash_in_out_type_path(conn, :show, id)

      conn = get conn, cash_in_out_type_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Cash in out type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, cash_in_out_type_path(conn, :create), cash_in_out_type: @invalid_attrs
      assert html_response(conn, 200) =~ "New Cash in out type"
    end
  end

  describe "edit cash_in_out_type" do
    setup [:create_cash_in_out_type]

    test "renders form for editing chosen cash_in_out_type", %{conn: conn, cash_in_out_type: cash_in_out_type} do
      conn = get conn, cash_in_out_type_path(conn, :edit, cash_in_out_type)
      assert html_response(conn, 200) =~ "Edit Cash in out type"
    end
  end

  describe "update cash_in_out_type" do
    setup [:create_cash_in_out_type]

    test "redirects when data is valid", %{conn: conn, cash_in_out_type: cash_in_out_type} do
      conn = put conn, cash_in_out_type_path(conn, :update, cash_in_out_type), cash_in_out_type: @update_attrs
      assert redirected_to(conn) == cash_in_out_type_path(conn, :show, cash_in_out_type)

      conn = get conn, cash_in_out_type_path(conn, :show, cash_in_out_type)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, cash_in_out_type: cash_in_out_type} do
      conn = put conn, cash_in_out_type_path(conn, :update, cash_in_out_type), cash_in_out_type: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Cash in out type"
    end
  end

  describe "delete cash_in_out_type" do
    setup [:create_cash_in_out_type]

    test "deletes chosen cash_in_out_type", %{conn: conn, cash_in_out_type: cash_in_out_type} do
      conn = delete conn, cash_in_out_type_path(conn, :delete, cash_in_out_type)
      assert redirected_to(conn) == cash_in_out_type_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, cash_in_out_type_path(conn, :show, cash_in_out_type)
      end
    end
  end

  defp create_cash_in_out_type(_) do
    cash_in_out_type = fixture(:cash_in_out_type)
    {:ok, cash_in_out_type: cash_in_out_type}
  end
end
