defmodule BoatNoodleWeb.VoidItemsControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{discount: 120.5, discountitemsid: 42, displayprice: "some displayprice", is_print: 42, is_void: 42, itemcode: "some itemcode", itemid: 42, itemname: "some itemname", itempriceperqty: "120.5", orderid: "some orderid", price: "120.5", priceafterdiscount: "120.5", qtyafterdisc: 42, quantity: 42, remark: "some remark", tableid: 42, takeawayid: "some takeawayid", void_by: 42, voidreason: "some voidreason"}
  @update_attrs %{discount: 456.7, discountitemsid: 43, displayprice: "some updated displayprice", is_print: 43, is_void: 43, itemcode: "some updated itemcode", itemid: 43, itemname: "some updated itemname", itempriceperqty: "456.7", orderid: "some updated orderid", price: "456.7", priceafterdiscount: "456.7", qtyafterdisc: 43, quantity: 43, remark: "some updated remark", tableid: 43, takeawayid: "some updated takeawayid", void_by: 43, voidreason: "some updated voidreason"}
  @invalid_attrs %{discount: nil, discountitemsid: nil, displayprice: nil, is_print: nil, is_void: nil, itemcode: nil, itemid: nil, itemname: nil, itempriceperqty: nil, orderid: nil, price: nil, priceafterdiscount: nil, qtyafterdisc: nil, quantity: nil, remark: nil, tableid: nil, takeawayid: nil, void_by: nil, voidreason: nil}

  def fixture(:void_items) do
    {:ok, void_items} = BN.create_void_items(@create_attrs)
    void_items
  end

  describe "index" do
    test "lists all voiditems", %{conn: conn} do
      conn = get conn, void_items_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Voiditems"
    end
  end

  describe "new void_items" do
    test "renders form", %{conn: conn} do
      conn = get conn, void_items_path(conn, :new)
      assert html_response(conn, 200) =~ "New Void items"
    end
  end

  describe "create void_items" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, void_items_path(conn, :create), void_items: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == void_items_path(conn, :show, id)

      conn = get conn, void_items_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Void items"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, void_items_path(conn, :create), void_items: @invalid_attrs
      assert html_response(conn, 200) =~ "New Void items"
    end
  end

  describe "edit void_items" do
    setup [:create_void_items]

    test "renders form for editing chosen void_items", %{conn: conn, void_items: void_items} do
      conn = get conn, void_items_path(conn, :edit, void_items)
      assert html_response(conn, 200) =~ "Edit Void items"
    end
  end

  describe "update void_items" do
    setup [:create_void_items]

    test "redirects when data is valid", %{conn: conn, void_items: void_items} do
      conn = put conn, void_items_path(conn, :update, void_items), void_items: @update_attrs
      assert redirected_to(conn) == void_items_path(conn, :show, void_items)

      conn = get conn, void_items_path(conn, :show, void_items)
      assert html_response(conn, 200) =~ "some updated displayprice"
    end

    test "renders errors when data is invalid", %{conn: conn, void_items: void_items} do
      conn = put conn, void_items_path(conn, :update, void_items), void_items: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Void items"
    end
  end

  describe "delete void_items" do
    setup [:create_void_items]

    test "deletes chosen void_items", %{conn: conn, void_items: void_items} do
      conn = delete conn, void_items_path(conn, :delete, void_items)
      assert redirected_to(conn) == void_items_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, void_items_path(conn, :show, void_items)
      end
    end
  end

  defp create_void_items(_) do
    void_items = fixture(:void_items)
    {:ok, void_items: void_items}
  end
end
