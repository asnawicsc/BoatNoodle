defmodule BoatNoodleWeb.TagCatalogControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{description: "some description", name: "some name", tag_category: "some tag_category", tag_items: "some tag_items"}
  @update_attrs %{description: "some updated description", name: "some updated name", tag_category: "some updated tag_category", tag_items: "some updated tag_items"}
  @invalid_attrs %{description: nil, name: nil, tag_category: nil, tag_items: nil}

  def fixture(:tag_catalog) do
    {:ok, tag_catalog} = BN.create_tag_catalog(@create_attrs)
    tag_catalog
  end

  describe "index" do
    test "lists all tag_catalog", %{conn: conn} do
      conn = get conn, tag_catalog_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Tag catalog"
    end
  end

  describe "new tag_catalog" do
    test "renders form", %{conn: conn} do
      conn = get conn, tag_catalog_path(conn, :new)
      assert html_response(conn, 200) =~ "New Tag catalog"
    end
  end

  describe "create tag_catalog" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, tag_catalog_path(conn, :create), tag_catalog: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == tag_catalog_path(conn, :show, id)

      conn = get conn, tag_catalog_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Tag catalog"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, tag_catalog_path(conn, :create), tag_catalog: @invalid_attrs
      assert html_response(conn, 200) =~ "New Tag catalog"
    end
  end

  describe "edit tag_catalog" do
    setup [:create_tag_catalog]

    test "renders form for editing chosen tag_catalog", %{conn: conn, tag_catalog: tag_catalog} do
      conn = get conn, tag_catalog_path(conn, :edit, tag_catalog)
      assert html_response(conn, 200) =~ "Edit Tag catalog"
    end
  end

  describe "update tag_catalog" do
    setup [:create_tag_catalog]

    test "redirects when data is valid", %{conn: conn, tag_catalog: tag_catalog} do
      conn = put conn, tag_catalog_path(conn, :update, tag_catalog), tag_catalog: @update_attrs
      assert redirected_to(conn) == tag_catalog_path(conn, :show, tag_catalog)

      conn = get conn, tag_catalog_path(conn, :show, tag_catalog)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, tag_catalog: tag_catalog} do
      conn = put conn, tag_catalog_path(conn, :update, tag_catalog), tag_catalog: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Tag catalog"
    end
  end

  describe "delete tag_catalog" do
    setup [:create_tag_catalog]

    test "deletes chosen tag_catalog", %{conn: conn, tag_catalog: tag_catalog} do
      conn = delete conn, tag_catalog_path(conn, :delete, tag_catalog)
      assert redirected_to(conn) == tag_catalog_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, tag_catalog_path(conn, :show, tag_catalog)
      end
    end
  end

  defp create_tag_catalog(_) do
    tag_catalog = fixture(:tag_catalog)
    {:ok, tag_catalog: tag_catalog}
  end
end
