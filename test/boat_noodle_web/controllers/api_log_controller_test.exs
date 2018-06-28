defmodule BoatNoodleWeb.ApiLogControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{message: "some message"}
  @update_attrs %{message: "some updated message"}
  @invalid_attrs %{message: nil}

  def fixture(:api_log) do
    {:ok, api_log} = BN.create_api_log(@create_attrs)
    api_log
  end

  describe "index" do
    test "lists all api_log", %{conn: conn} do
      conn = get conn, api_log_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Api log"
    end
  end

  describe "new api_log" do
    test "renders form", %{conn: conn} do
      conn = get conn, api_log_path(conn, :new)
      assert html_response(conn, 200) =~ "New Api log"
    end
  end

  describe "create api_log" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, api_log_path(conn, :create), api_log: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == api_log_path(conn, :show, id)

      conn = get conn, api_log_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Api log"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, api_log_path(conn, :create), api_log: @invalid_attrs
      assert html_response(conn, 200) =~ "New Api log"
    end
  end

  describe "edit api_log" do
    setup [:create_api_log]

    test "renders form for editing chosen api_log", %{conn: conn, api_log: api_log} do
      conn = get conn, api_log_path(conn, :edit, api_log)
      assert html_response(conn, 200) =~ "Edit Api log"
    end
  end

  describe "update api_log" do
    setup [:create_api_log]

    test "redirects when data is valid", %{conn: conn, api_log: api_log} do
      conn = put conn, api_log_path(conn, :update, api_log), api_log: @update_attrs
      assert redirected_to(conn) == api_log_path(conn, :show, api_log)

      conn = get conn, api_log_path(conn, :show, api_log)
      assert html_response(conn, 200) =~ "some updated message"
    end

    test "renders errors when data is invalid", %{conn: conn, api_log: api_log} do
      conn = put conn, api_log_path(conn, :update, api_log), api_log: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Api log"
    end
  end

  describe "delete api_log" do
    setup [:create_api_log]

    test "deletes chosen api_log", %{conn: conn, api_log: api_log} do
      conn = delete conn, api_log_path(conn, :delete, api_log)
      assert redirected_to(conn) == api_log_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, api_log_path(conn, :show, api_log)
      end
    end
  end

  defp create_api_log(_) do
    api_log = fixture(:api_log)
    {:ok, api_log: api_log}
  end
end
