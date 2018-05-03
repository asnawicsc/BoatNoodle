defmodule BoatNoodleWeb.ItemCustomizedControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{availability: "some availability", created_at: "2010-04-17 14:00:00.000000Z", customize_code: "some customize_code", customize_detail: "some customize_detail", itemcustomid: 42, price: "120.5", subcatid: "some subcatid", updated_at: "2010-04-17 14:00:00.000000Z"}
  @update_attrs %{availability: "some updated availability", created_at: "2011-05-18 15:01:01.000000Z", customize_code: "some updated customize_code", customize_detail: "some updated customize_detail", itemcustomid: 43, price: "456.7", subcatid: "some updated subcatid", updated_at: "2011-05-18 15:01:01.000000Z"}
  @invalid_attrs %{availability: nil, created_at: nil, customize_code: nil, customize_detail: nil, itemcustomid: nil, price: nil, subcatid: nil, updated_at: nil}

  def fixture(:item_customized) do
    {:ok, item_customized} = BN.create_item_customized(@create_attrs)
    item_customized
  end

  describe "index" do
    test "lists all item_customized", %{conn: conn} do
      conn = get conn, item_customized_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Item customized"
    end
  end

  describe "new item_customized" do
    test "renders form", %{conn: conn} do
      conn = get conn, item_customized_path(conn, :new)
      assert html_response(conn, 200) =~ "New Item customized"
    end
  end

  describe "create item_customized" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, item_customized_path(conn, :create), item_customized: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == item_customized_path(conn, :show, id)

      conn = get conn, item_customized_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Item customized"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, item_customized_path(conn, :create), item_customized: @invalid_attrs
      assert html_response(conn, 200) =~ "New Item customized"
    end
  end

  describe "edit item_customized" do
    setup [:create_item_customized]

    test "renders form for editing chosen item_customized", %{conn: conn, item_customized: item_customized} do
      conn = get conn, item_customized_path(conn, :edit, item_customized)
      assert html_response(conn, 200) =~ "Edit Item customized"
    end
  end

  describe "update item_customized" do
    setup [:create_item_customized]

    test "redirects when data is valid", %{conn: conn, item_customized: item_customized} do
      conn = put conn, item_customized_path(conn, :update, item_customized), item_customized: @update_attrs
      assert redirected_to(conn) == item_customized_path(conn, :show, item_customized)

      conn = get conn, item_customized_path(conn, :show, item_customized)
      assert html_response(conn, 200) =~ "some updated availability"
    end

    test "renders errors when data is invalid", %{conn: conn, item_customized: item_customized} do
      conn = put conn, item_customized_path(conn, :update, item_customized), item_customized: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Item customized"
    end
  end

  describe "delete item_customized" do
    setup [:create_item_customized]

    test "deletes chosen item_customized", %{conn: conn, item_customized: item_customized} do
      conn = delete conn, item_customized_path(conn, :delete, item_customized)
      assert redirected_to(conn) == item_customized_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, item_customized_path(conn, :show, item_customized)
      end
    end
  end

  defp create_item_customized(_) do
    item_customized = fixture(:item_customized)
    {:ok, item_customized: item_customized}
  end
end
