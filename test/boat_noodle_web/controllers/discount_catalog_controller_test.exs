defmodule BoatNoodleWeb.DiscountCatalogControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{discount_catalog_master_id: 42, discount_categories: "some discount_categories", discount_category: "some discount_category", discount_name: "some discount_name", name: "some name"}
  @update_attrs %{discount_catalog_master_id: 43, discount_categories: "some updated discount_categories", discount_category: "some updated discount_category", discount_name: "some updated discount_name", name: "some updated name"}
  @invalid_attrs %{discount_catalog_master_id: nil, discount_categories: nil, discount_category: nil, discount_name: nil, name: nil}

  def fixture(:discount_catalog) do
    {:ok, discount_catalog} = BN.create_discount_catalog(@create_attrs)
    discount_catalog
  end

  describe "index" do
    test "lists all discount_catalog", %{conn: conn} do
      conn = get conn, discount_catalog_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Discount catalog"
    end
  end

  describe "new discount_catalog" do
    test "renders form", %{conn: conn} do
      conn = get conn, discount_catalog_path(conn, :new)
      assert html_response(conn, 200) =~ "New Discount catalog"
    end
  end

  describe "create discount_catalog" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, discount_catalog_path(conn, :create), discount_catalog: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == discount_catalog_path(conn, :show, id)

      conn = get conn, discount_catalog_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Discount catalog"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, discount_catalog_path(conn, :create), discount_catalog: @invalid_attrs
      assert html_response(conn, 200) =~ "New Discount catalog"
    end
  end

  describe "edit discount_catalog" do
    setup [:create_discount_catalog]

    test "renders form for editing chosen discount_catalog", %{conn: conn, discount_catalog: discount_catalog} do
      conn = get conn, discount_catalog_path(conn, :edit, discount_catalog)
      assert html_response(conn, 200) =~ "Edit Discount catalog"
    end
  end

  describe "update discount_catalog" do
    setup [:create_discount_catalog]

    test "redirects when data is valid", %{conn: conn, discount_catalog: discount_catalog} do
      conn = put conn, discount_catalog_path(conn, :update, discount_catalog), discount_catalog: @update_attrs
      assert redirected_to(conn) == discount_catalog_path(conn, :show, discount_catalog)

      conn = get conn, discount_catalog_path(conn, :show, discount_catalog)
      assert html_response(conn, 200) =~ "some updated discount_categories"
    end

    test "renders errors when data is invalid", %{conn: conn, discount_catalog: discount_catalog} do
      conn = put conn, discount_catalog_path(conn, :update, discount_catalog), discount_catalog: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Discount catalog"
    end
  end

  describe "delete discount_catalog" do
    setup [:create_discount_catalog]

    test "deletes chosen discount_catalog", %{conn: conn, discount_catalog: discount_catalog} do
      conn = delete conn, discount_catalog_path(conn, :delete, discount_catalog)
      assert redirected_to(conn) == discount_catalog_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, discount_catalog_path(conn, :show, discount_catalog)
      end
    end
  end

  defp create_discount_catalog(_) do
    discount_catalog = fixture(:discount_catalog)
    {:ok, discount_catalog: discount_catalog}
  end
end
