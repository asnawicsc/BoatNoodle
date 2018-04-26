defmodule BoatNoodleWeb.MenuCatalogControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{active: true, category_item: "some category_item", item_code: "some item_code", item_name: "some item_name", menu_catalog_master_id: 42, price: "120.5", price_code: "some price_code"}
  @update_attrs %{active: false, category_item: "some updated category_item", item_code: "some updated item_code", item_name: "some updated item_name", menu_catalog_master_id: 43, price: "456.7", price_code: "some updated price_code"}
  @invalid_attrs %{active: nil, category_item: nil, item_code: nil, item_name: nil, menu_catalog_master_id: nil, price: nil, price_code: nil}

  def fixture(:menu_catalog) do
    {:ok, menu_catalog} = BN.create_menu_catalog(@create_attrs)
    menu_catalog
  end

  describe "index" do
    test "lists all menu_catalog", %{conn: conn} do
      conn = get conn, menu_catalog_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Menu catalog"
    end
  end

  describe "new menu_catalog" do
    test "renders form", %{conn: conn} do
      conn = get conn, menu_catalog_path(conn, :new)
      assert html_response(conn, 200) =~ "New Menu catalog"
    end
  end

  describe "create menu_catalog" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, menu_catalog_path(conn, :create), menu_catalog: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == menu_catalog_path(conn, :show, id)

      conn = get conn, menu_catalog_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Menu catalog"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, menu_catalog_path(conn, :create), menu_catalog: @invalid_attrs
      assert html_response(conn, 200) =~ "New Menu catalog"
    end
  end

  describe "edit menu_catalog" do
    setup [:create_menu_catalog]

    test "renders form for editing chosen menu_catalog", %{conn: conn, menu_catalog: menu_catalog} do
      conn = get conn, menu_catalog_path(conn, :edit, menu_catalog)
      assert html_response(conn, 200) =~ "Edit Menu catalog"
    end
  end

  describe "update menu_catalog" do
    setup [:create_menu_catalog]

    test "redirects when data is valid", %{conn: conn, menu_catalog: menu_catalog} do
      conn = put conn, menu_catalog_path(conn, :update, menu_catalog), menu_catalog: @update_attrs
      assert redirected_to(conn) == menu_catalog_path(conn, :show, menu_catalog)

      conn = get conn, menu_catalog_path(conn, :show, menu_catalog)
      assert html_response(conn, 200) =~ "some updated category_item"
    end

    test "renders errors when data is invalid", %{conn: conn, menu_catalog: menu_catalog} do
      conn = put conn, menu_catalog_path(conn, :update, menu_catalog), menu_catalog: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Menu catalog"
    end
  end

  describe "delete menu_catalog" do
    setup [:create_menu_catalog]

    test "deletes chosen menu_catalog", %{conn: conn, menu_catalog: menu_catalog} do
      conn = delete conn, menu_catalog_path(conn, :delete, menu_catalog)
      assert redirected_to(conn) == menu_catalog_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, menu_catalog_path(conn, :show, menu_catalog)
      end
    end
  end

  defp create_menu_catalog(_) do
    menu_catalog = fixture(:menu_catalog)
    {:ok, menu_catalog: menu_catalog}
  end
end
