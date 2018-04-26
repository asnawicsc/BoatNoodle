defmodule BoatNoodleWeb.TagItemsControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{item_name: "some item_name", printer: "some printer", tag_name: "some tag_name"}
  @update_attrs %{item_name: "some updated item_name", printer: "some updated printer", tag_name: "some updated tag_name"}
  @invalid_attrs %{item_name: nil, printer: nil, tag_name: nil}

  def fixture(:tag_items) do
    {:ok, tag_items} = BN.create_tag_items(@create_attrs)
    tag_items
  end

  describe "index" do
    test "lists all tag_items", %{conn: conn} do
      conn = get conn, tag_items_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Tag items"
    end
  end

  describe "new tag_items" do
    test "renders form", %{conn: conn} do
      conn = get conn, tag_items_path(conn, :new)
      assert html_response(conn, 200) =~ "New Tag items"
    end
  end

  describe "create tag_items" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, tag_items_path(conn, :create), tag_items: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == tag_items_path(conn, :show, id)

      conn = get conn, tag_items_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Tag items"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, tag_items_path(conn, :create), tag_items: @invalid_attrs
      assert html_response(conn, 200) =~ "New Tag items"
    end
  end

  describe "edit tag_items" do
    setup [:create_tag_items]

    test "renders form for editing chosen tag_items", %{conn: conn, tag_items: tag_items} do
      conn = get conn, tag_items_path(conn, :edit, tag_items)
      assert html_response(conn, 200) =~ "Edit Tag items"
    end
  end

  describe "update tag_items" do
    setup [:create_tag_items]

    test "redirects when data is valid", %{conn: conn, tag_items: tag_items} do
      conn = put conn, tag_items_path(conn, :update, tag_items), tag_items: @update_attrs
      assert redirected_to(conn) == tag_items_path(conn, :show, tag_items)

      conn = get conn, tag_items_path(conn, :show, tag_items)
      assert html_response(conn, 200) =~ "some updated item_name"
    end

    test "renders errors when data is invalid", %{conn: conn, tag_items: tag_items} do
      conn = put conn, tag_items_path(conn, :update, tag_items), tag_items: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Tag items"
    end
  end

  describe "delete tag_items" do
    setup [:create_tag_items]

    test "deletes chosen tag_items", %{conn: conn, tag_items: tag_items} do
      conn = delete conn, tag_items_path(conn, :delete, tag_items)
      assert redirected_to(conn) == tag_items_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, tag_items_path(conn, :show, tag_items)
      end
    end
  end

  defp create_tag_items(_) do
    tag_items = fixture(:tag_items)
    {:ok, tag_items: tag_items}
  end
end
