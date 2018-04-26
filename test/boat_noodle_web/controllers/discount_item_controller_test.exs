defmodule BoatNoodleWeb.DiscountItemControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{description: "some description", discount_catalog: "some discount_catalog", discount_category: "some discount_category", discount_name: "some discount_name", discount_percentage: "some discount_percentage", discount_type: "some discount_type", minimum_spend: 42, status: true}
  @update_attrs %{description: "some updated description", discount_catalog: "some updated discount_catalog", discount_category: "some updated discount_category", discount_name: "some updated discount_name", discount_percentage: "some updated discount_percentage", discount_type: "some updated discount_type", minimum_spend: 43, status: false}
  @invalid_attrs %{description: nil, discount_catalog: nil, discount_category: nil, discount_name: nil, discount_percentage: nil, discount_type: nil, minimum_spend: nil, status: nil}

  def fixture(:discount_item) do
    {:ok, discount_item} = BN.create_discount_item(@create_attrs)
    discount_item
  end

  describe "index" do
    test "lists all discount_item", %{conn: conn} do
      conn = get conn, discount_item_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Discount item"
    end
  end

  describe "new discount_item" do
    test "renders form", %{conn: conn} do
      conn = get conn, discount_item_path(conn, :new)
      assert html_response(conn, 200) =~ "New Discount item"
    end
  end

  describe "create discount_item" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, discount_item_path(conn, :create), discount_item: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == discount_item_path(conn, :show, id)

      conn = get conn, discount_item_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Discount item"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, discount_item_path(conn, :create), discount_item: @invalid_attrs
      assert html_response(conn, 200) =~ "New Discount item"
    end
  end

  describe "edit discount_item" do
    setup [:create_discount_item]

    test "renders form for editing chosen discount_item", %{conn: conn, discount_item: discount_item} do
      conn = get conn, discount_item_path(conn, :edit, discount_item)
      assert html_response(conn, 200) =~ "Edit Discount item"
    end
  end

  describe "update discount_item" do
    setup [:create_discount_item]

    test "redirects when data is valid", %{conn: conn, discount_item: discount_item} do
      conn = put conn, discount_item_path(conn, :update, discount_item), discount_item: @update_attrs
      assert redirected_to(conn) == discount_item_path(conn, :show, discount_item)

      conn = get conn, discount_item_path(conn, :show, discount_item)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, discount_item: discount_item} do
      conn = put conn, discount_item_path(conn, :update, discount_item), discount_item: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Discount item"
    end
  end

  describe "delete discount_item" do
    setup [:create_discount_item]

    test "deletes chosen discount_item", %{conn: conn, discount_item: discount_item} do
      conn = delete conn, discount_item_path(conn, :delete, discount_item)
      assert redirected_to(conn) == discount_item_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, discount_item_path(conn, :show, discount_item)
      end
    end
  end

  defp create_discount_item(_) do
    discount_item = fixture(:discount_item)
    {:ok, discount_item: discount_item}
  end
end
