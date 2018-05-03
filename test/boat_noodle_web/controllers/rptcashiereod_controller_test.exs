defmodule BoatNoodleWeb.RPTCASHIEREODControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{branch_id: 42, branchcode: "some branchcode", cash: "120.5", cash_in: "120.5", close_amt: "120.5", deposit: "120.5", dinein: "120.5", drawamt: "120.5", duration: "some duration", exp_drw_amt: "120.5", extra: "120.5", floats: "120.5", open_amt: "120.5", paidout: "120.5", rptid: 42, staff_name: "some staff_name", takeaway: "120.5", time_end: "2010-04-17 14:00:00.000000Z", time_start: "2010-04-17 14:00:00.000000Z", total_cash: "120.5", total_changes: "120.5", total_disc: "120.5", total_pymt: "120.5", total_round: "120.5", total_sr: "120.5", totalpax: 42, totalsales: "120.5", totalsvc: "120.5", totaltax: "120.5", voiditem: 120.5, voidsales: 120.5}
  @update_attrs %{branch_id: 43, branchcode: "some updated branchcode", cash: "456.7", cash_in: "456.7", close_amt: "456.7", deposit: "456.7", dinein: "456.7", drawamt: "456.7", duration: "some updated duration", exp_drw_amt: "456.7", extra: "456.7", floats: "456.7", open_amt: "456.7", paidout: "456.7", rptid: 43, staff_name: "some updated staff_name", takeaway: "456.7", time_end: "2011-05-18 15:01:01.000000Z", time_start: "2011-05-18 15:01:01.000000Z", total_cash: "456.7", total_changes: "456.7", total_disc: "456.7", total_pymt: "456.7", total_round: "456.7", total_sr: "456.7", totalpax: 43, totalsales: "456.7", totalsvc: "456.7", totaltax: "456.7", voiditem: 456.7, voidsales: 456.7}
  @invalid_attrs %{branch_id: nil, branchcode: nil, cash: nil, cash_in: nil, close_amt: nil, deposit: nil, dinein: nil, drawamt: nil, duration: nil, exp_drw_amt: nil, extra: nil, floats: nil, open_amt: nil, paidout: nil, rptid: nil, staff_name: nil, takeaway: nil, time_end: nil, time_start: nil, total_cash: nil, total_changes: nil, total_disc: nil, total_pymt: nil, total_round: nil, total_sr: nil, totalpax: nil, totalsales: nil, totalsvc: nil, totaltax: nil, voiditem: nil, voidsales: nil}

  def fixture(:rptcashiereod) do
    {:ok, rptcashiereod} = BN.create_rptcashiereod(@create_attrs)
    rptcashiereod
  end

  describe "index" do
    test "lists all rpt_cashier_eod", %{conn: conn} do
      conn = get conn, rptcashiereod_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Rpt cashier eod"
    end
  end

  describe "new rptcashiereod" do
    test "renders form", %{conn: conn} do
      conn = get conn, rptcashiereod_path(conn, :new)
      assert html_response(conn, 200) =~ "New Rptcashiereod"
    end
  end

  describe "create rptcashiereod" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, rptcashiereod_path(conn, :create), rptcashiereod: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == rptcashiereod_path(conn, :show, id)

      conn = get conn, rptcashiereod_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Rptcashiereod"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, rptcashiereod_path(conn, :create), rptcashiereod: @invalid_attrs
      assert html_response(conn, 200) =~ "New Rptcashiereod"
    end
  end

  describe "edit rptcashiereod" do
    setup [:create_rptcashiereod]

    test "renders form for editing chosen rptcashiereod", %{conn: conn, rptcashiereod: rptcashiereod} do
      conn = get conn, rptcashiereod_path(conn, :edit, rptcashiereod)
      assert html_response(conn, 200) =~ "Edit Rptcashiereod"
    end
  end

  describe "update rptcashiereod" do
    setup [:create_rptcashiereod]

    test "redirects when data is valid", %{conn: conn, rptcashiereod: rptcashiereod} do
      conn = put conn, rptcashiereod_path(conn, :update, rptcashiereod), rptcashiereod: @update_attrs
      assert redirected_to(conn) == rptcashiereod_path(conn, :show, rptcashiereod)

      conn = get conn, rptcashiereod_path(conn, :show, rptcashiereod)
      assert html_response(conn, 200) =~ "some updated branchcode"
    end

    test "renders errors when data is invalid", %{conn: conn, rptcashiereod: rptcashiereod} do
      conn = put conn, rptcashiereod_path(conn, :update, rptcashiereod), rptcashiereod: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Rptcashiereod"
    end
  end

  describe "delete rptcashiereod" do
    setup [:create_rptcashiereod]

    test "deletes chosen rptcashiereod", %{conn: conn, rptcashiereod: rptcashiereod} do
      conn = delete conn, rptcashiereod_path(conn, :delete, rptcashiereod)
      assert redirected_to(conn) == rptcashiereod_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, rptcashiereod_path(conn, :show, rptcashiereod)
      end
    end
  end

  defp create_rptcashiereod(_) do
    rptcashiereod = fixture(:rptcashiereod)
    {:ok, rptcashiereod: rptcashiereod}
  end
end
