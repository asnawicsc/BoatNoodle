defmodule BoatNoodleWeb.StaffLogSessionControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{branch_id: 42, id: 42, log_id: 42, log_in: "2010-04-17 14:00:00.000000Z", log_out: "2010-04-17 14:00:00.000000Z", staff_id: 42}
  @update_attrs %{branch_id: 43, id: 43, log_id: 43, log_in: "2011-05-18 15:01:01.000000Z", log_out: "2011-05-18 15:01:01.000000Z", staff_id: 43}
  @invalid_attrs %{branch_id: nil, id: nil, log_id: nil, log_in: nil, log_out: nil, staff_id: nil}

  def fixture(:staff_log_session) do
    {:ok, staff_log_session} = BN.create_staff_log_session(@create_attrs)
    staff_log_session
  end

  describe "index" do
    test "lists all staff_log_session", %{conn: conn} do
      conn = get conn, staff_log_session_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Staff log session"
    end
  end

  describe "new staff_log_session" do
    test "renders form", %{conn: conn} do
      conn = get conn, staff_log_session_path(conn, :new)
      assert html_response(conn, 200) =~ "New Staff log session"
    end
  end

  describe "create staff_log_session" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, staff_log_session_path(conn, :create), staff_log_session: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == staff_log_session_path(conn, :show, id)

      conn = get conn, staff_log_session_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Staff log session"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, staff_log_session_path(conn, :create), staff_log_session: @invalid_attrs
      assert html_response(conn, 200) =~ "New Staff log session"
    end
  end

  describe "edit staff_log_session" do
    setup [:create_staff_log_session]

    test "renders form for editing chosen staff_log_session", %{conn: conn, staff_log_session: staff_log_session} do
      conn = get conn, staff_log_session_path(conn, :edit, staff_log_session)
      assert html_response(conn, 200) =~ "Edit Staff log session"
    end
  end

  describe "update staff_log_session" do
    setup [:create_staff_log_session]

    test "redirects when data is valid", %{conn: conn, staff_log_session: staff_log_session} do
      conn = put conn, staff_log_session_path(conn, :update, staff_log_session), staff_log_session: @update_attrs
      assert redirected_to(conn) == staff_log_session_path(conn, :show, staff_log_session)

      conn = get conn, staff_log_session_path(conn, :show, staff_log_session)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, staff_log_session: staff_log_session} do
      conn = put conn, staff_log_session_path(conn, :update, staff_log_session), staff_log_session: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Staff log session"
    end
  end

  describe "delete staff_log_session" do
    setup [:create_staff_log_session]

    test "deletes chosen staff_log_session", %{conn: conn, staff_log_session: staff_log_session} do
      conn = delete conn, staff_log_session_path(conn, :delete, staff_log_session)
      assert redirected_to(conn) == staff_log_session_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, staff_log_session_path(conn, :show, staff_log_session)
      end
    end
  end

  defp create_staff_log_session(_) do
    staff_log_session = fixture(:staff_log_session)
    {:ok, staff_log_session: staff_log_session}
  end
end
