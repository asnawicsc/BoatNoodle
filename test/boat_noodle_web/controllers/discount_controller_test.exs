defmodule BoatNoodleWeb.DiscountControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{descriptions: "some descriptions", disc_qty: 42, discamtpercentage: "120.5", discname: "some discname", discount_id: 42, disctype: "some disctype", is_categorize: 42, is_delete: 42, is_used: 42, is_visible: 42, targer_itemcode: "some targer_itemcode", target_cat: 42}
  @update_attrs %{descriptions: "some updated descriptions", disc_qty: 43, discamtpercentage: "456.7", discname: "some updated discname", discount_id: 43, disctype: "some updated disctype", is_categorize: 43, is_delete: 43, is_used: 43, is_visible: 43, targer_itemcode: "some updated targer_itemcode", target_cat: 43}
  @invalid_attrs %{descriptions: nil, disc_qty: nil, discamtpercentage: nil, discname: nil, discount_id: nil, disctype: nil, is_categorize: nil, is_delete: nil, is_used: nil, is_visible: nil, targer_itemcode: nil, target_cat: nil}

  def fixture(:discount) do
    {:ok, discount} = BN.create_discount(@create_attrs)
    discount
  end

  describe "index" do
    test "lists all discount", %{conn: conn} do
      conn = get conn, discount_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Discount"
    end
  end

  describe "new discount" do
    test "renders form", %{conn: conn} do
      conn = get conn, discount_path(conn, :new)
      assert html_response(conn, 200) =~ "New Discount"
    end
  end

  describe "create discount" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, discount_path(conn, :create), discount: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == discount_path(conn, :show, id)

      conn = get conn, discount_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Discount"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, discount_path(conn, :create), discount: @invalid_attrs
      assert html_response(conn, 200) =~ "New Discount"
    end
  end

  describe "edit discount" do
    setup [:create_discount]

    test "renders form for editing chosen discount", %{conn: conn, discount: discount} do
      conn = get conn, discount_path(conn, :edit, discount)
      assert html_response(conn, 200) =~ "Edit Discount"
    end
  end

  describe "update discount" do
    setup [:create_discount]

    test "redirects when data is valid", %{conn: conn, discount: discount} do
      conn = put conn, discount_path(conn, :update, discount), discount: @update_attrs
      assert redirected_to(conn) == discount_path(conn, :show, discount)

      conn = get conn, discount_path(conn, :show, discount)
      assert html_response(conn, 200) =~ "some updated descriptions"
    end

    test "renders errors when data is invalid", %{conn: conn, discount: discount} do
      conn = put conn, discount_path(conn, :update, discount), discount: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Discount"
    end
  end

  describe "delete discount" do
    setup [:create_discount]

    test "deletes chosen discount", %{conn: conn, discount: discount} do
      conn = delete conn, discount_path(conn, :delete, discount)
      assert redirected_to(conn) == discount_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, discount_path(conn, :show, discount)
      end
    end
  end

  defp create_discount(_) do
    discount = fixture(:discount)
    {:ok, discount: discount}
  end
end
