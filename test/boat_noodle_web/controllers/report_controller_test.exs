defmodule BoatNoodleWeb.ReportControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{bin: "some bin", filename: "some filename", url_path: "some url_path"}
  @update_attrs %{bin: "some updated bin", filename: "some updated filename", url_path: "some updated url_path"}
  @invalid_attrs %{bin: nil, filename: nil, url_path: nil}

  def fixture(:report) do
    {:ok, report} = BN.create_report(@create_attrs)
    report
  end

  describe "index" do
    test "lists all reports", %{conn: conn} do
      conn = get conn, report_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Reports"
    end
  end

  describe "new report" do
    test "renders form", %{conn: conn} do
      conn = get conn, report_path(conn, :new)
      assert html_response(conn, 200) =~ "New Report"
    end
  end

  describe "create report" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, report_path(conn, :create), report: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == report_path(conn, :show, id)

      conn = get conn, report_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Report"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, report_path(conn, :create), report: @invalid_attrs
      assert html_response(conn, 200) =~ "New Report"
    end
  end

  describe "edit report" do
    setup [:create_report]

    test "renders form for editing chosen report", %{conn: conn, report: report} do
      conn = get conn, report_path(conn, :edit, report)
      assert html_response(conn, 200) =~ "Edit Report"
    end
  end

  describe "update report" do
    setup [:create_report]

    test "redirects when data is valid", %{conn: conn, report: report} do
      conn = put conn, report_path(conn, :update, report), report: @update_attrs
      assert redirected_to(conn) == report_path(conn, :show, report)

      conn = get conn, report_path(conn, :show, report)
      assert html_response(conn, 200) =~ "some updated filename"
    end

    test "renders errors when data is invalid", %{conn: conn, report: report} do
      conn = put conn, report_path(conn, :update, report), report: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Report"
    end
  end

  describe "delete report" do
    setup [:create_report]

    test "deletes chosen report", %{conn: conn, report: report} do
      conn = delete conn, report_path(conn, :delete, report)
      assert redirected_to(conn) == report_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, report_path(conn, :show, report)
      end
    end
  end

  defp create_report(_) do
    report = fixture(:report)
    {:ok, report: report}
  end
end
