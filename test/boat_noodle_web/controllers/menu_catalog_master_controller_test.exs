defmodule BoatNoodleWeb.MenuCatalogMasterControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{catalog_name: "some catalog_name"}
  @update_attrs %{catalog_name: "some updated catalog_name"}
  @invalid_attrs %{catalog_name: nil}

  def fixture(:menu_catalog_master) do
    {:ok, menu_catalog_master} = BN.create_menu_catalog_master(@create_attrs)
    menu_catalog_master
  end

  describe "index" do
    test "lists all menu_catalog_master", %{conn: conn} do
      conn = get conn, menu_catalog_master_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Menu catalog master"
    end
  end

  describe "new menu_catalog_master" do
    test "renders form", %{conn: conn} do
      conn = get conn, menu_catalog_master_path(conn, :new)
      assert html_response(conn, 200) =~ "New Menu catalog master"
    end
  end

  describe "create menu_catalog_master" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, menu_catalog_master_path(conn, :create), menu_catalog_master: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == menu_catalog_master_path(conn, :show, id)

      conn = get conn, menu_catalog_master_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Menu catalog master"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, menu_catalog_master_path(conn, :create), menu_catalog_master: @invalid_attrs
      assert html_response(conn, 200) =~ "New Menu catalog master"
    end
  end

  describe "edit menu_catalog_master" do
    setup [:create_menu_catalog_master]

    test "renders form for editing chosen menu_catalog_master", %{conn: conn, menu_catalog_master: menu_catalog_master} do
      conn = get conn, menu_catalog_master_path(conn, :edit, menu_catalog_master)
      assert html_response(conn, 200) =~ "Edit Menu catalog master"
    end
  end

  describe "update menu_catalog_master" do
    setup [:create_menu_catalog_master]

    test "redirects when data is valid", %{conn: conn, menu_catalog_master: menu_catalog_master} do
      conn = put conn, menu_catalog_master_path(conn, :update, menu_catalog_master), menu_catalog_master: @update_attrs
      assert redirected_to(conn) == menu_catalog_master_path(conn, :show, menu_catalog_master)

      conn = get conn, menu_catalog_master_path(conn, :show, menu_catalog_master)
      assert html_response(conn, 200) =~ "some updated catalog_name"
    end

    test "renders errors when data is invalid", %{conn: conn, menu_catalog_master: menu_catalog_master} do
      conn = put conn, menu_catalog_master_path(conn, :update, menu_catalog_master), menu_catalog_master: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Menu catalog master"
    end
  end

  describe "delete menu_catalog_master" do
    setup [:create_menu_catalog_master]

    test "deletes chosen menu_catalog_master", %{conn: conn, menu_catalog_master: menu_catalog_master} do
      conn = delete conn, menu_catalog_master_path(conn, :delete, menu_catalog_master)
      assert redirected_to(conn) == menu_catalog_master_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, menu_catalog_master_path(conn, :show, menu_catalog_master)
      end
    end
  end

  defp create_menu_catalog_master(_) do
    menu_catalog_master = fixture(:menu_catalog_master)
    {:ok, menu_catalog_master: menu_catalog_master}
  end
end
