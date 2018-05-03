defmodule BoatNoodleWeb.ComboDetailsControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{combo_id: 42, combo_item_code: "some combo_item_code", combo_item_id: 42, combo_item_name: "some combo_item_name", combo_item_qty: 42, combo_qty: 42, id: 42, menu_cat_id: 42, top_up: "120.5", unit_price: "120.5", update_qty: 42}
  @update_attrs %{combo_id: 43, combo_item_code: "some updated combo_item_code", combo_item_id: 43, combo_item_name: "some updated combo_item_name", combo_item_qty: 43, combo_qty: 43, id: 43, menu_cat_id: 43, top_up: "456.7", unit_price: "456.7", update_qty: 43}
  @invalid_attrs %{combo_id: nil, combo_item_code: nil, combo_item_id: nil, combo_item_name: nil, combo_item_qty: nil, combo_qty: nil, id: nil, menu_cat_id: nil, top_up: nil, unit_price: nil, update_qty: nil}

  def fixture(:combo_details) do
    {:ok, combo_details} = BN.create_combo_details(@create_attrs)
    combo_details
  end

  describe "index" do
    test "lists all combo_details", %{conn: conn} do
      conn = get conn, combo_details_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Combo details"
    end
  end

  describe "new combo_details" do
    test "renders form", %{conn: conn} do
      conn = get conn, combo_details_path(conn, :new)
      assert html_response(conn, 200) =~ "New Combo details"
    end
  end

  describe "create combo_details" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, combo_details_path(conn, :create), combo_details: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == combo_details_path(conn, :show, id)

      conn = get conn, combo_details_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Combo details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, combo_details_path(conn, :create), combo_details: @invalid_attrs
      assert html_response(conn, 200) =~ "New Combo details"
    end
  end

  describe "edit combo_details" do
    setup [:create_combo_details]

    test "renders form for editing chosen combo_details", %{conn: conn, combo_details: combo_details} do
      conn = get conn, combo_details_path(conn, :edit, combo_details)
      assert html_response(conn, 200) =~ "Edit Combo details"
    end
  end

  describe "update combo_details" do
    setup [:create_combo_details]

    test "redirects when data is valid", %{conn: conn, combo_details: combo_details} do
      conn = put conn, combo_details_path(conn, :update, combo_details), combo_details: @update_attrs
      assert redirected_to(conn) == combo_details_path(conn, :show, combo_details)

      conn = get conn, combo_details_path(conn, :show, combo_details)
      assert html_response(conn, 200) =~ "some updated combo_item_code"
    end

    test "renders errors when data is invalid", %{conn: conn, combo_details: combo_details} do
      conn = put conn, combo_details_path(conn, :update, combo_details), combo_details: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Combo details"
    end
  end

  describe "delete combo_details" do
    setup [:create_combo_details]

    test "deletes chosen combo_details", %{conn: conn, combo_details: combo_details} do
      conn = delete conn, combo_details_path(conn, :delete, combo_details)
      assert redirected_to(conn) == combo_details_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, combo_details_path(conn, :show, combo_details)
      end
    end
  end

  defp create_combo_details(_) do
    combo_details = fixture(:combo_details)
    {:ok, combo_details: combo_details}
  end
end
