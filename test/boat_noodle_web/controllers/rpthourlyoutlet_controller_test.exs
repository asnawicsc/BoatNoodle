defmodule BoatNoodleWeb.RPTHOURLYOUTLETControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{brachcode: "some brachcode", branchid: 42, branchname: "some branchname", integer: "some integer", pax: 42, sales: "120.5", salesdate: ~N[2010-04-17 14:00:00.000000], saleshour: 42, salesmonth: 42, salesquarter: 42, salesyear: 42, transaction: "some transaction"}
  @update_attrs %{brachcode: "some updated brachcode", branchid: 43, branchname: "some updated branchname", integer: "some updated integer", pax: 43, sales: "456.7", salesdate: ~N[2011-05-18 15:01:01.000000], saleshour: 43, salesmonth: 43, salesquarter: 43, salesyear: 43, transaction: "some updated transaction"}
  @invalid_attrs %{brachcode: nil, branchid: nil, branchname: nil, integer: nil, pax: nil, sales: nil, salesdate: nil, saleshour: nil, salesmonth: nil, salesquarter: nil, salesyear: nil, transaction: nil}

  def fixture(:rpthourlyoutlet) do
    {:ok, rpthourlyoutlet} = BN.create_rpthourlyoutlet(@create_attrs)
    rpthourlyoutlet
  end

  describe "index" do
    test "lists all rpt_hourly_outlet", %{conn: conn} do
      conn = get conn, rpthourlyoutlet_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Rpt hourly outlet"
    end
  end

  describe "new rpthourlyoutlet" do
    test "renders form", %{conn: conn} do
      conn = get conn, rpthourlyoutlet_path(conn, :new)
      assert html_response(conn, 200) =~ "New Rpthourlyoutlet"
    end
  end

  describe "create rpthourlyoutlet" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, rpthourlyoutlet_path(conn, :create), rpthourlyoutlet: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == rpthourlyoutlet_path(conn, :show, id)

      conn = get conn, rpthourlyoutlet_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Rpthourlyoutlet"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, rpthourlyoutlet_path(conn, :create), rpthourlyoutlet: @invalid_attrs
      assert html_response(conn, 200) =~ "New Rpthourlyoutlet"
    end
  end

  describe "edit rpthourlyoutlet" do
    setup [:create_rpthourlyoutlet]

    test "renders form for editing chosen rpthourlyoutlet", %{conn: conn, rpthourlyoutlet: rpthourlyoutlet} do
      conn = get conn, rpthourlyoutlet_path(conn, :edit, rpthourlyoutlet)
      assert html_response(conn, 200) =~ "Edit Rpthourlyoutlet"
    end
  end

  describe "update rpthourlyoutlet" do
    setup [:create_rpthourlyoutlet]

    test "redirects when data is valid", %{conn: conn, rpthourlyoutlet: rpthourlyoutlet} do
      conn = put conn, rpthourlyoutlet_path(conn, :update, rpthourlyoutlet), rpthourlyoutlet: @update_attrs
      assert redirected_to(conn) == rpthourlyoutlet_path(conn, :show, rpthourlyoutlet)

      conn = get conn, rpthourlyoutlet_path(conn, :show, rpthourlyoutlet)
      assert html_response(conn, 200) =~ "some updated brachcode"
    end

    test "renders errors when data is invalid", %{conn: conn, rpthourlyoutlet: rpthourlyoutlet} do
      conn = put conn, rpthourlyoutlet_path(conn, :update, rpthourlyoutlet), rpthourlyoutlet: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Rpthourlyoutlet"
    end
  end

  describe "delete rpthourlyoutlet" do
    setup [:create_rpthourlyoutlet]

    test "deletes chosen rpthourlyoutlet", %{conn: conn, rpthourlyoutlet: rpthourlyoutlet} do
      conn = delete conn, rpthourlyoutlet_path(conn, :delete, rpthourlyoutlet)
      assert redirected_to(conn) == rpthourlyoutlet_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, rpthourlyoutlet_path(conn, :show, rpthourlyoutlet)
      end
    end
  end

  defp create_rpthourlyoutlet(_) do
    rpthourlyoutlet = fixture(:rpthourlyoutlet)
    {:ok, rpthourlyoutlet: rpthourlyoutlet}
  end
end
