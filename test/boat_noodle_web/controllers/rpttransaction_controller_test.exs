defmodule BoatNoodleWeb.RPTTRANSACTIONControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{after_disc: "some after_disc", branchcode: "some branchcode", branchid: 42, cash: "120.5", changes: "120.5", decimal: "some decimal", grand_total: "120.5", gst_charge: "some gst_charge", invoiceno: "some invoiceno", is_void: 42, pax: 42, payment_type: "some payment_type", quarter: 42, remark: "some remark", rounding: "120.5", salesdate: "2010-04-17 14:00:00.000000Z", saleshour: 42, salesid: "some salesid", salesmonth: 42, salestime: "2010-04-17 14:00:00.000000Z", salesyear: 42, service_charge: "120.5", staffid: 42, staffname: "some staffname", sub_total: "120.5", tbl_no: 42, type: "some type", void_by: "some void_by", voidreason: "some voidreason"}
  @update_attrs %{after_disc: "some updated after_disc", branchcode: "some updated branchcode", branchid: 43, cash: "456.7", changes: "456.7", decimal: "some updated decimal", grand_total: "456.7", gst_charge: "some updated gst_charge", invoiceno: "some updated invoiceno", is_void: 43, pax: 43, payment_type: "some updated payment_type", quarter: 43, remark: "some updated remark", rounding: "456.7", salesdate: "2011-05-18 15:01:01.000000Z", saleshour: 43, salesid: "some updated salesid", salesmonth: 43, salestime: "2011-05-18 15:01:01.000000Z", salesyear: 43, service_charge: "456.7", staffid: 43, staffname: "some updated staffname", sub_total: "456.7", tbl_no: 43, type: "some updated type", void_by: "some updated void_by", voidreason: "some updated voidreason"}
  @invalid_attrs %{after_disc: nil, branchcode: nil, branchid: nil, cash: nil, changes: nil, decimal: nil, grand_total: nil, gst_charge: nil, invoiceno: nil, is_void: nil, pax: nil, payment_type: nil, quarter: nil, remark: nil, rounding: nil, salesdate: nil, saleshour: nil, salesid: nil, salesmonth: nil, salestime: nil, salesyear: nil, service_charge: nil, staffid: nil, staffname: nil, sub_total: nil, tbl_no: nil, type: nil, void_by: nil, voidreason: nil}

  def fixture(:rpttransaction) do
    {:ok, rpttransaction} = BN.create_rpttransaction(@create_attrs)
    rpttransaction
  end

  describe "index" do
    test "lists all rpt_transaction", %{conn: conn} do
      conn = get conn, rpttransaction_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Rpt transaction"
    end
  end

  describe "new rpttransaction" do
    test "renders form", %{conn: conn} do
      conn = get conn, rpttransaction_path(conn, :new)
      assert html_response(conn, 200) =~ "New Rpttransaction"
    end
  end

  describe "create rpttransaction" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, rpttransaction_path(conn, :create), rpttransaction: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == rpttransaction_path(conn, :show, id)

      conn = get conn, rpttransaction_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Rpttransaction"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, rpttransaction_path(conn, :create), rpttransaction: @invalid_attrs
      assert html_response(conn, 200) =~ "New Rpttransaction"
    end
  end

  describe "edit rpttransaction" do
    setup [:create_rpttransaction]

    test "renders form for editing chosen rpttransaction", %{conn: conn, rpttransaction: rpttransaction} do
      conn = get conn, rpttransaction_path(conn, :edit, rpttransaction)
      assert html_response(conn, 200) =~ "Edit Rpttransaction"
    end
  end

  describe "update rpttransaction" do
    setup [:create_rpttransaction]

    test "redirects when data is valid", %{conn: conn, rpttransaction: rpttransaction} do
      conn = put conn, rpttransaction_path(conn, :update, rpttransaction), rpttransaction: @update_attrs
      assert redirected_to(conn) == rpttransaction_path(conn, :show, rpttransaction)

      conn = get conn, rpttransaction_path(conn, :show, rpttransaction)
      assert html_response(conn, 200) =~ "some updated after_disc"
    end

    test "renders errors when data is invalid", %{conn: conn, rpttransaction: rpttransaction} do
      conn = put conn, rpttransaction_path(conn, :update, rpttransaction), rpttransaction: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Rpttransaction"
    end
  end

  describe "delete rpttransaction" do
    setup [:create_rpttransaction]

    test "deletes chosen rpttransaction", %{conn: conn, rpttransaction: rpttransaction} do
      conn = delete conn, rpttransaction_path(conn, :delete, rpttransaction)
      assert redirected_to(conn) == rpttransaction_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, rpttransaction_path(conn, :show, rpttransaction)
      end
    end
  end

  defp create_rpttransaction(_) do
    rpttransaction = fixture(:rpttransaction)
    {:ok, rpttransaction: rpttransaction}
  end
end
