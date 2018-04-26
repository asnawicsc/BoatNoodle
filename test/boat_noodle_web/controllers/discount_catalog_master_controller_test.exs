defmodule BoatNoodleWeb.DiscountCatalogMasterControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{catalog_name: "some catalog_name"}
  @update_attrs %{catalog_name: "some updated catalog_name"}
  @invalid_attrs %{catalog_name: nil}

  def fixture(:discount_catalog_master) do
    {:ok, discount_catalog_master} = BN.create_discount_catalog_master(@create_attrs)
    discount_catalog_master
  end

  describe "index" do
    test "lists all discount_catalog_master", %{conn: conn} do
      conn = get conn, discount_catalog_master_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Discount catalog master"
    end
  end

  describe "new discount_catalog_master" do
    test "renders form", %{conn: conn} do
      conn = get conn, discount_catalog_master_path(conn, :new)
      assert html_response(conn, 200) =~ "New Discount catalog master"
    end
  end

  describe "create discount_catalog_master" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, discount_catalog_master_path(conn, :create), discount_catalog_master: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == discount_catalog_master_path(conn, :show, id)

      conn = get conn, discount_catalog_master_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Discount catalog master"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, discount_catalog_master_path(conn, :create), discount_catalog_master: @invalid_attrs
      assert html_response(conn, 200) =~ "New Discount catalog master"
    end
  end

  describe "edit discount_catalog_master" do
    setup [:create_discount_catalog_master]

    test "renders form for editing chosen discount_catalog_master", %{conn: conn, discount_catalog_master: discount_catalog_master} do
      conn = get conn, discount_catalog_master_path(conn, :edit, discount_catalog_master)
      assert html_response(conn, 200) =~ "Edit Discount catalog master"
    end
  end

  describe "update discount_catalog_master" do
    setup [:create_discount_catalog_master]

    test "redirects when data is valid", %{conn: conn, discount_catalog_master: discount_catalog_master} do
      conn = put conn, discount_catalog_master_path(conn, :update, discount_catalog_master), discount_catalog_master: @update_attrs
      assert redirected_to(conn) == discount_catalog_master_path(conn, :show, discount_catalog_master)

      conn = get conn, discount_catalog_master_path(conn, :show, discount_catalog_master)
      assert html_response(conn, 200) =~ "some updated catalog_name"
    end

    test "renders errors when data is invalid", %{conn: conn, discount_catalog_master: discount_catalog_master} do
      conn = put conn, discount_catalog_master_path(conn, :update, discount_catalog_master), discount_catalog_master: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Discount catalog master"
    end
  end

  describe "delete discount_catalog_master" do
    setup [:create_discount_catalog_master]

    test "deletes chosen discount_catalog_master", %{conn: conn, discount_catalog_master: discount_catalog_master} do
      conn = delete conn, discount_catalog_master_path(conn, :delete, discount_catalog_master)
      assert redirected_to(conn) == discount_catalog_master_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, discount_catalog_master_path(conn, :show, discount_catalog_master)
      end
    end
  end

  defp create_discount_catalog_master(_) do
    discount_catalog_master = fixture(:discount_catalog_master)
    {:ok, discount_catalog_master: discount_catalog_master}
  end
end
