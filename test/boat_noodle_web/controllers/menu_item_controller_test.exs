defmodule BoatNoodleWeb.MenuItemControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{active: true, category: "some category", enable_discount: true, is_included_in_minimum_spend: true, item: "some item", item_code: "some item_code", item_description: "some item_description", item_image: "some item_image", item_name: "some item_name", menu_catalogs: "some menu_catalogs", part_code: "some part_code", price: "120.5", price_code: "some price_code", tags: "some tags"}
  @update_attrs %{active: false, category: "some updated category", enable_discount: false, is_included_in_minimum_spend: false, item: "some updated item", item_code: "some updated item_code", item_description: "some updated item_description", item_image: "some updated item_image", item_name: "some updated item_name", menu_catalogs: "some updated menu_catalogs", part_code: "some updated part_code", price: "456.7", price_code: "some updated price_code", tags: "some updated tags"}
  @invalid_attrs %{active: nil, category: nil, enable_discount: nil, is_included_in_minimum_spend: nil, item: nil, item_code: nil, item_description: nil, item_image: nil, item_name: nil, menu_catalogs: nil, part_code: nil, price: nil, price_code: nil, tags: nil}

  def fixture(:menu_item) do
    {:ok, menu_item} = BN.create_menu_item(@create_attrs)
    menu_item
  end

  describe "index" do
    test "lists all menu_item", %{conn: conn} do
      conn = get conn, menu_item_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Menu item"
    end
  end

  describe "new menu_item" do
    test "renders form", %{conn: conn} do
      conn = get conn, menu_item_path(conn, :new)
      assert html_response(conn, 200) =~ "New Menu item"
    end
  end

  describe "create menu_item" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, menu_item_path(conn, :create), menu_item: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == menu_item_path(conn, :show, id)

      conn = get conn, menu_item_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Menu item"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, menu_item_path(conn, :create), menu_item: @invalid_attrs
      assert html_response(conn, 200) =~ "New Menu item"
    end
  end

  describe "edit menu_item" do
    setup [:create_menu_item]

    test "renders form for editing chosen menu_item", %{conn: conn, menu_item: menu_item} do
      conn = get conn, menu_item_path(conn, :edit, menu_item)
      assert html_response(conn, 200) =~ "Edit Menu item"
    end
  end

  describe "update menu_item" do
    setup [:create_menu_item]

    test "redirects when data is valid", %{conn: conn, menu_item: menu_item} do
      conn = put conn, menu_item_path(conn, :update, menu_item), menu_item: @update_attrs
      assert redirected_to(conn) == menu_item_path(conn, :show, menu_item)

      conn = get conn, menu_item_path(conn, :show, menu_item)
      assert html_response(conn, 200) =~ "some updated category"
    end

    test "renders errors when data is invalid", %{conn: conn, menu_item: menu_item} do
      conn = put conn, menu_item_path(conn, :update, menu_item), menu_item: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Menu item"
    end
  end

  describe "delete menu_item" do
    setup [:create_menu_item]

    test "deletes chosen menu_item", %{conn: conn, menu_item: menu_item} do
      conn = delete conn, menu_item_path(conn, :delete, menu_item)
      assert redirected_to(conn) == menu_item_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, menu_item_path(conn, :show, menu_item)
      end
    end
  end

  defp create_menu_item(_) do
    menu_item = fixture(:menu_item)
    {:ok, menu_item: menu_item}
  end
end
