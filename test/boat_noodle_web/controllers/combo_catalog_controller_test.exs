defmodule BoatNoodleWeb.ComboCatalogControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{brand_id: 42, combo_id: 42, combo_item_id: 42, is_active: 42, is_combo_header: 42}
  @update_attrs %{brand_id: 43, combo_id: 43, combo_item_id: 43, is_active: 43, is_combo_header: 43}
  @invalid_attrs %{brand_id: nil, combo_id: nil, combo_item_id: nil, is_active: nil, is_combo_header: nil}

  def fixture(:combo_catalog) do
    {:ok, combo_catalog} = BN.create_combo_catalog(@create_attrs)
    combo_catalog
  end

  describe "index" do
    test "lists all combo_catalog", %{conn: conn} do
      conn = get conn, combo_catalog_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Combo catalog"
    end
  end

  describe "new combo_catalog" do
    test "renders form", %{conn: conn} do
      conn = get conn, combo_catalog_path(conn, :new)
      assert html_response(conn, 200) =~ "New Combo catalog"
    end
  end

  describe "create combo_catalog" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, combo_catalog_path(conn, :create), combo_catalog: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == combo_catalog_path(conn, :show, id)

      conn = get conn, combo_catalog_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Combo catalog"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, combo_catalog_path(conn, :create), combo_catalog: @invalid_attrs
      assert html_response(conn, 200) =~ "New Combo catalog"
    end
  end

  describe "edit combo_catalog" do
    setup [:create_combo_catalog]

    test "renders form for editing chosen combo_catalog", %{conn: conn, combo_catalog: combo_catalog} do
      conn = get conn, combo_catalog_path(conn, :edit, combo_catalog)
      assert html_response(conn, 200) =~ "Edit Combo catalog"
    end
  end

  describe "update combo_catalog" do
    setup [:create_combo_catalog]

    test "redirects when data is valid", %{conn: conn, combo_catalog: combo_catalog} do
      conn = put conn, combo_catalog_path(conn, :update, combo_catalog), combo_catalog: @update_attrs
      assert redirected_to(conn) == combo_catalog_path(conn, :show, combo_catalog)

      conn = get conn, combo_catalog_path(conn, :show, combo_catalog)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, combo_catalog: combo_catalog} do
      conn = put conn, combo_catalog_path(conn, :update, combo_catalog), combo_catalog: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Combo catalog"
    end
  end

  describe "delete combo_catalog" do
    setup [:create_combo_catalog]

    test "deletes chosen combo_catalog", %{conn: conn, combo_catalog: combo_catalog} do
      conn = delete conn, combo_catalog_path(conn, :delete, combo_catalog)
      assert redirected_to(conn) == combo_catalog_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, combo_catalog_path(conn, :show, combo_catalog)
      end
    end
  end

  defp create_combo_catalog(_) do
    combo_catalog = fixture(:combo_catalog)
    {:ok, combo_catalog: combo_catalog}
  end
end
