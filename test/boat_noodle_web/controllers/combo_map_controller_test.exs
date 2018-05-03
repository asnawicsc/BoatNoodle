defmodule BoatNoodleWeb.ComboMapControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{linkid: 42, subcatid: 42}
  @update_attrs %{linkid: 43, subcatid: 43}
  @invalid_attrs %{linkid: nil, subcatid: nil}

  def fixture(:combo_map) do
    {:ok, combo_map} = BN.create_combo_map(@create_attrs)
    combo_map
  end

  describe "index" do
    test "lists all combo_map", %{conn: conn} do
      conn = get conn, combo_map_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Combo map"
    end
  end

  describe "new combo_map" do
    test "renders form", %{conn: conn} do
      conn = get conn, combo_map_path(conn, :new)
      assert html_response(conn, 200) =~ "New Combo map"
    end
  end

  describe "create combo_map" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, combo_map_path(conn, :create), combo_map: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == combo_map_path(conn, :show, id)

      conn = get conn, combo_map_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Combo map"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, combo_map_path(conn, :create), combo_map: @invalid_attrs
      assert html_response(conn, 200) =~ "New Combo map"
    end
  end

  describe "edit combo_map" do
    setup [:create_combo_map]

    test "renders form for editing chosen combo_map", %{conn: conn, combo_map: combo_map} do
      conn = get conn, combo_map_path(conn, :edit, combo_map)
      assert html_response(conn, 200) =~ "Edit Combo map"
    end
  end

  describe "update combo_map" do
    setup [:create_combo_map]

    test "redirects when data is valid", %{conn: conn, combo_map: combo_map} do
      conn = put conn, combo_map_path(conn, :update, combo_map), combo_map: @update_attrs
      assert redirected_to(conn) == combo_map_path(conn, :show, combo_map)

      conn = get conn, combo_map_path(conn, :show, combo_map)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, combo_map: combo_map} do
      conn = put conn, combo_map_path(conn, :update, combo_map), combo_map: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Combo map"
    end
  end

  describe "delete combo_map" do
    setup [:create_combo_map]

    test "deletes chosen combo_map", %{conn: conn, combo_map: combo_map} do
      conn = delete conn, combo_map_path(conn, :delete, combo_map)
      assert redirected_to(conn) == combo_map_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, combo_map_path(conn, :show, combo_map)
      end
    end
  end

  defp create_combo_map(_) do
    combo_map = fixture(:combo_map)
    {:ok, combo_map: combo_map}
  end
end
