defmodule BoatNoodleWeb.CashierSessionControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{branchid: "some branchid", cash_in: "120.5", cash_out: "120.5", close_amt: "120.5", csid: 42, deposits: "120.5", duration: 42, floatamt: "120.5", open_amt: "120.5", paidout: "120.5", staffid: "some staffid", time_end: "2010-04-17 14:00:00.000000Z", time_start: "2010-04-17 14:00:00.000000Z"}
  @update_attrs %{branchid: "some updated branchid", cash_in: "456.7", cash_out: "456.7", close_amt: "456.7", csid: 43, deposits: "456.7", duration: 43, floatamt: "456.7", open_amt: "456.7", paidout: "456.7", staffid: "some updated staffid", time_end: "2011-05-18 15:01:01.000000Z", time_start: "2011-05-18 15:01:01.000000Z"}
  @invalid_attrs %{branchid: nil, cash_in: nil, cash_out: nil, close_amt: nil, csid: nil, deposits: nil, duration: nil, floatamt: nil, open_amt: nil, paidout: nil, staffid: nil, time_end: nil, time_start: nil}

  def fixture(:cashier_session) do
    {:ok, cashier_session} = BN.create_cashier_session(@create_attrs)
    cashier_session
  end

  describe "index" do
    test "lists all cashier_session", %{conn: conn} do
      conn = get conn, cashier_session_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Cashier session"
    end
  end

  describe "new cashier_session" do
    test "renders form", %{conn: conn} do
      conn = get conn, cashier_session_path(conn, :new)
      assert html_response(conn, 200) =~ "New Cashier session"
    end
  end

  describe "create cashier_session" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, cashier_session_path(conn, :create), cashier_session: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == cashier_session_path(conn, :show, id)

      conn = get conn, cashier_session_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Cashier session"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, cashier_session_path(conn, :create), cashier_session: @invalid_attrs
      assert html_response(conn, 200) =~ "New Cashier session"
    end
  end

  describe "edit cashier_session" do
    setup [:create_cashier_session]

    test "renders form for editing chosen cashier_session", %{conn: conn, cashier_session: cashier_session} do
      conn = get conn, cashier_session_path(conn, :edit, cashier_session)
      assert html_response(conn, 200) =~ "Edit Cashier session"
    end
  end

  describe "update cashier_session" do
    setup [:create_cashier_session]

    test "redirects when data is valid", %{conn: conn, cashier_session: cashier_session} do
      conn = put conn, cashier_session_path(conn, :update, cashier_session), cashier_session: @update_attrs
      assert redirected_to(conn) == cashier_session_path(conn, :show, cashier_session)

      conn = get conn, cashier_session_path(conn, :show, cashier_session)
      assert html_response(conn, 200) =~ "some updated branchid"
    end

    test "renders errors when data is invalid", %{conn: conn, cashier_session: cashier_session} do
      conn = put conn, cashier_session_path(conn, :update, cashier_session), cashier_session: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Cashier session"
    end
  end

  describe "delete cashier_session" do
    setup [:create_cashier_session]

    test "deletes chosen cashier_session", %{conn: conn, cashier_session: cashier_session} do
      conn = delete conn, cashier_session_path(conn, :delete, cashier_session)
      assert redirected_to(conn) == cashier_session_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, cashier_session_path(conn, :show, cashier_session)
      end
    end
  end

  defp create_cashier_session(_) do
    cashier_session = fixture(:cashier_session)
    {:ok, cashier_session: cashier_session}
  end
end
