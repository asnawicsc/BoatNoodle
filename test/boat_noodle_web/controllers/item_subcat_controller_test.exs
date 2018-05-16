defmodule BoatNoodleWeb.ItemSubcatControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{created_at: "2010-04-17 14:00:00.000000Z", enable_disc: 42, include_spend: 42, integer: "some integer", is_active: 42, is_categorize: 42, is_combo: 42, is_default_combo: 42, is_delete: 42, is_print: 42, itemcatid: "some itemcatid", itemcode: "some itemcode", itemdesc: "some itemdesc", itemimage: "some itemimage", itemname: "some itemname", itemprice: "120.5", part_code: "some part_code", price_code: "some price_code", product_code: "some product_code", subcatid: "some subcatid", updated_at: "2010-04-17 14:00:00.000000Z"}
  @update_attrs %{created_at: "2011-05-18 15:01:01.000000Z", enable_disc: 43, include_spend: 43, integer: "some updated integer", is_active: 43, is_categorize: 43, is_combo: 43, is_default_combo: 43, is_delete: 43, is_print: 43, itemcatid: "some updated itemcatid", itemcode: "some updated itemcode", itemdesc: "some updated itemdesc", itemimage: "some updated itemimage", itemname: "some updated itemname", itemprice: "456.7", part_code: "some updated part_code", price_code: "some updated price_code", product_code: "some updated product_code", subcatid: "some updated subcatid", updated_at: "2011-05-18 15:01:01.000000Z"}
  @invalid_attrs %{created_at: nil, enable_disc: nil, include_spend: nil, integer: nil, is_active: nil, is_categorize: nil, is_combo: nil, is_default_combo: nil, is_delete: nil, is_print: nil, itemcatid: nil, itemcode: nil, itemdesc: nil, itemimage: nil, itemname: nil, itemprice: nil, part_code: nil, price_code: nil, product_code: nil, subcatid: nil, updated_at: nil}

  def fixture(:item_subcat) do
    {:ok, item_subcat} = BN.create_item_subcat(@create_attrs)
    item_subcat
  end

  describe "index" do
    test "lists all item_subcat", %{conn: conn} do
      conn = get conn, item_subcat_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Item subcat"
    end
  end

  describe "new item_subcat" do
    test "renders form", %{conn: conn} do
      conn = get conn, item_subcat_path(conn, :new)
      assert html_response(conn, 200) =~ "New Item subcat"
    end
  end

  describe "create item_subcat" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, item_subcat_path(conn, :create), item_subcat: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == item_subcat_path(conn, :show, id)

      conn = get conn, item_subcat_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Item subcat"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, item_subcat_path(conn, :create), item_subcat: @invalid_attrs
      assert html_response(conn, 200) =~ "New Item subcat"
    end
  end

  describe "edit item_subcat" do
    setup [:create_item_subcat]

    test "renders form for editing chosen item_subcat", %{conn: conn, item_subcat: item_subcat} do
      conn = get conn, item_subcat_path(conn, :edit, item_subcat)
      assert html_response(conn, 200) =~ "Edit Item subcat"
    end
  end

  describe "update item_subcat" do
    setup [:create_item_subcat]

    test "redirects when data is valid", %{conn: conn, item_subcat: item_subcat} do
      conn = put conn, item_subcat_path(conn, :update, item_subcat), item_subcat: @update_attrs
      assert redirected_to(conn) == item_subcat_path(conn, :show, item_subcat)

      conn = get conn, item_subcat_path(conn, :show, item_subcat)
      assert html_response(conn, 200) =~ "some updated integer"
    end

    test "renders errors when data is invalid", %{conn: conn, item_subcat: item_subcat} do
      conn = put conn, item_subcat_path(conn, :update, item_subcat), item_subcat: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Item subcat"
    end
  end

  describe "delete item_subcat" do
    setup [:create_item_subcat]

    test "deletes chosen item_subcat", %{conn: conn, item_subcat: item_subcat} do
      conn = delete conn, item_subcat_path(conn, :delete, item_subcat)
      assert redirected_to(conn) == item_subcat_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, item_subcat_path(conn, :show, item_subcat)
      end
    end
  end

  defp create_item_subcat(_) do
    item_subcat = fixture(:item_subcat)
    {:ok, item_subcat: item_subcat}
  end
end
