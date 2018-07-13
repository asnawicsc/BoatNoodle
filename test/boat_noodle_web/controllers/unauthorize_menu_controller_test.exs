defmodule BoatNoodleWeb.UnauthorizeMenuControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{branch_id: 42, brand_id: 42, role_id: 42, url: "some url"}
  @update_attrs %{branch_id: 43, brand_id: 43, role_id: 43, url: "some updated url"}
  @invalid_attrs %{branch_id: nil, brand_id: nil, role_id: nil, url: nil}

  def fixture(:unauthorize_menu) do
    {:ok, unauthorize_menu} = BN.create_unauthorize_menu(@create_attrs)
    unauthorize_menu
  end

  describe "index" do
    test "lists all unauthorize_menu", %{conn: conn} do
      conn = get conn, unauthorize_menu_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Unauthorize menu"
    end
  end

  describe "new unauthorize_menu" do
    test "renders form", %{conn: conn} do
      conn = get conn, unauthorize_menu_path(conn, :new)
      assert html_response(conn, 200) =~ "New Unauthorize menu"
    end
  end

  describe "create unauthorize_menu" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, unauthorize_menu_path(conn, :create), unauthorize_menu: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == unauthorize_menu_path(conn, :show, id)

      conn = get conn, unauthorize_menu_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Unauthorize menu"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, unauthorize_menu_path(conn, :create), unauthorize_menu: @invalid_attrs
      assert html_response(conn, 200) =~ "New Unauthorize menu"
    end
  end

  describe "edit unauthorize_menu" do
    setup [:create_unauthorize_menu]

    test "renders form for editing chosen unauthorize_menu", %{conn: conn, unauthorize_menu: unauthorize_menu} do
      conn = get conn, unauthorize_menu_path(conn, :edit, unauthorize_menu)
      assert html_response(conn, 200) =~ "Edit Unauthorize menu"
    end
  end

  describe "update unauthorize_menu" do
    setup [:create_unauthorize_menu]

    test "redirects when data is valid", %{conn: conn, unauthorize_menu: unauthorize_menu} do
      conn = put conn, unauthorize_menu_path(conn, :update, unauthorize_menu), unauthorize_menu: @update_attrs
      assert redirected_to(conn) == unauthorize_menu_path(conn, :show, unauthorize_menu)

      conn = get conn, unauthorize_menu_path(conn, :show, unauthorize_menu)
      assert html_response(conn, 200) =~ "some updated url"
    end

    test "renders errors when data is invalid", %{conn: conn, unauthorize_menu: unauthorize_menu} do
      conn = put conn, unauthorize_menu_path(conn, :update, unauthorize_menu), unauthorize_menu: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Unauthorize menu"
    end
  end

  describe "delete unauthorize_menu" do
    setup [:create_unauthorize_menu]

    test "deletes chosen unauthorize_menu", %{conn: conn, unauthorize_menu: unauthorize_menu} do
      conn = delete conn, unauthorize_menu_path(conn, :delete, unauthorize_menu)
      assert redirected_to(conn) == unauthorize_menu_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, unauthorize_menu_path(conn, :show, unauthorize_menu)
      end
    end
  end

  defp create_unauthorize_menu(_) do
    unauthorize_menu = fixture(:unauthorize_menu)
    {:ok, unauthorize_menu: unauthorize_menu}
  end
end
