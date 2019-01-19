defmodule BoatNoodleWeb.SubcatCatalogControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{catalog_id: 42, end_date: ~D[2010-04-17], price: "120.5", start_date: ~D[2010-04-17], subcat_id: 42}
  @update_attrs %{catalog_id: 43, end_date: ~D[2011-05-18], price: "456.7", start_date: ~D[2011-05-18], subcat_id: 43}
  @invalid_attrs %{catalog_id: nil, end_date: nil, price: nil, start_date: nil, subcat_id: nil}

  def fixture(:subcat_catalog) do
    {:ok, subcat_catalog} = BN.create_subcat_catalog(@create_attrs)
    subcat_catalog
  end

  describe "index" do
    test "lists all subcat_catalog", %{conn: conn} do
      conn = get conn, subcat_catalog_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Subcat catalog"
    end
  end

  describe "new subcat_catalog" do
    test "renders form", %{conn: conn} do
      conn = get conn, subcat_catalog_path(conn, :new)
      assert html_response(conn, 200) =~ "New Subcat catalog"
    end
  end

  describe "create subcat_catalog" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, subcat_catalog_path(conn, :create), subcat_catalog: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == subcat_catalog_path(conn, :show, id)

      conn = get conn, subcat_catalog_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Subcat catalog"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, subcat_catalog_path(conn, :create), subcat_catalog: @invalid_attrs
      assert html_response(conn, 200) =~ "New Subcat catalog"
    end
  end

  describe "edit subcat_catalog" do
    setup [:create_subcat_catalog]

    test "renders form for editing chosen subcat_catalog", %{conn: conn, subcat_catalog: subcat_catalog} do
      conn = get conn, subcat_catalog_path(conn, :edit, subcat_catalog)
      assert html_response(conn, 200) =~ "Edit Subcat catalog"
    end
  end

  describe "update subcat_catalog" do
    setup [:create_subcat_catalog]

    test "redirects when data is valid", %{conn: conn, subcat_catalog: subcat_catalog} do
      conn = put conn, subcat_catalog_path(conn, :update, subcat_catalog), subcat_catalog: @update_attrs
      assert redirected_to(conn) == subcat_catalog_path(conn, :show, subcat_catalog)

      conn = get conn, subcat_catalog_path(conn, :show, subcat_catalog)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, subcat_catalog: subcat_catalog} do
      conn = put conn, subcat_catalog_path(conn, :update, subcat_catalog), subcat_catalog: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Subcat catalog"
    end
  end

  describe "delete subcat_catalog" do
    setup [:create_subcat_catalog]

    test "deletes chosen subcat_catalog", %{conn: conn, subcat_catalog: subcat_catalog} do
      conn = delete conn, subcat_catalog_path(conn, :delete, subcat_catalog)
      assert redirected_to(conn) == subcat_catalog_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, subcat_catalog_path(conn, :show, subcat_catalog)
      end
    end
  end

  defp create_subcat_catalog(_) do
    subcat_catalog = fixture(:subcat_catalog)
    {:ok, subcat_catalog: subcat_catalog}
  end
end
