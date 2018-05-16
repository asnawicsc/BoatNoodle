defmodule BoatNoodleWeb.ItemCatControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{category_type: "some category_type", created_at: "2010-04-17 14:00:00.000000Z", is_default: 42, is_delete: 42, itemcatcode: "some itemcatcode", itemcatdesc: "some itemcatdesc", itemcatid: 42, itemcatname: "some itemcatname", updated_at: "2010-04-17 14:00:00.000000Z"}
  @update_attrs %{category_type: "some updated category_type", created_at: "2011-05-18 15:01:01.000000Z", is_default: 43, is_delete: 43, itemcatcode: "some updated itemcatcode", itemcatdesc: "some updated itemcatdesc", itemcatid: 43, itemcatname: "some updated itemcatname", updated_at: "2011-05-18 15:01:01.000000Z"}
  @invalid_attrs %{category_type: nil, created_at: nil, is_default: nil, is_delete: nil, itemcatcode: nil, itemcatdesc: nil, itemcatid: nil, itemcatname: nil, updated_at: nil}

  def fixture(:item_cat) do
    {:ok, item_cat} = BN.create_item_cat(@create_attrs)
    item_cat
  end

  describe "index" do
    test "lists all itemcat", %{conn: conn} do
      conn = get conn, item_cat_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Itemcat"
    end
  end

  describe "new item_cat" do
    test "renders form", %{conn: conn} do
      conn = get conn, item_cat_path(conn, :new)
      assert html_response(conn, 200) =~ "New Item cat"
    end
  end

  describe "create item_cat" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, item_cat_path(conn, :create), item_cat: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == item_cat_path(conn, :show, id)

      conn = get conn, item_cat_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Item cat"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, item_cat_path(conn, :create), item_cat: @invalid_attrs
      assert html_response(conn, 200) =~ "New Item cat"
    end
  end

  describe "edit item_cat" do
    setup [:create_item_cat]

    test "renders form for editing chosen item_cat", %{conn: conn, item_cat: item_cat} do
      conn = get conn, item_cat_path(conn, :edit, item_cat)
      assert html_response(conn, 200) =~ "Edit Item cat"
    end
  end

  describe "update item_cat" do
    setup [:create_item_cat]

    test "redirects when data is valid", %{conn: conn, item_cat: item_cat} do
      conn = put conn, item_cat_path(conn, :update, item_cat), item_cat: @update_attrs
      assert redirected_to(conn) == item_cat_path(conn, :show, item_cat)

      conn = get conn, item_cat_path(conn, :show, item_cat)
      assert html_response(conn, 200) =~ "some updated category_type"
    end

    test "renders errors when data is invalid", %{conn: conn, item_cat: item_cat} do
      conn = put conn, item_cat_path(conn, :update, item_cat), item_cat: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Item cat"
    end
  end

  describe "delete item_cat" do
    setup [:create_item_cat]

    test "deletes chosen item_cat", %{conn: conn, item_cat: item_cat} do
      conn = delete conn, item_cat_path(conn, :delete, item_cat)
      assert redirected_to(conn) == item_cat_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, item_cat_path(conn, :show, item_cat)
      end
    end
  end

  defp create_item_cat(_) do
    item_cat = fixture(:item_cat)
    {:ok, item_cat: item_cat}
  end
end
