defmodule BoatNoodleWeb.ModalLogControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{action: "some action", description: "some description", name: "some name", user_id: 42}
  @update_attrs %{action: "some updated action", description: "some updated description", name: "some updated name", user_id: 43}
  @invalid_attrs %{action: nil, description: nil, name: nil, user_id: nil}

  def fixture(:modal_log) do
    {:ok, modal_log} = BN.create_modal_log(@create_attrs)
    modal_log
  end

  describe "index" do
    test "lists all modal_logs", %{conn: conn} do
      conn = get conn, modal_log_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Modal logs"
    end
  end

  describe "new modal_log" do
    test "renders form", %{conn: conn} do
      conn = get conn, modal_log_path(conn, :new)
      assert html_response(conn, 200) =~ "New Modal log"
    end
  end

  describe "create modal_log" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, modal_log_path(conn, :create), modal_log: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == modal_log_path(conn, :show, id)

      conn = get conn, modal_log_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Modal log"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, modal_log_path(conn, :create), modal_log: @invalid_attrs
      assert html_response(conn, 200) =~ "New Modal log"
    end
  end

  describe "edit modal_log" do
    setup [:create_modal_log]

    test "renders form for editing chosen modal_log", %{conn: conn, modal_log: modal_log} do
      conn = get conn, modal_log_path(conn, :edit, modal_log)
      assert html_response(conn, 200) =~ "Edit Modal log"
    end
  end

  describe "update modal_log" do
    setup [:create_modal_log]

    test "redirects when data is valid", %{conn: conn, modal_log: modal_log} do
      conn = put conn, modal_log_path(conn, :update, modal_log), modal_log: @update_attrs
      assert redirected_to(conn) == modal_log_path(conn, :show, modal_log)

      conn = get conn, modal_log_path(conn, :show, modal_log)
      assert html_response(conn, 200) =~ "some updated action"
    end

    test "renders errors when data is invalid", %{conn: conn, modal_log: modal_log} do
      conn = put conn, modal_log_path(conn, :update, modal_log), modal_log: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Modal log"
    end
  end

  describe "delete modal_log" do
    setup [:create_modal_log]

    test "deletes chosen modal_log", %{conn: conn, modal_log: modal_log} do
      conn = delete conn, modal_log_path(conn, :delete, modal_log)
      assert redirected_to(conn) == modal_log_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, modal_log_path(conn, :show, modal_log)
      end
    end
  end

  defp create_modal_log(_) do
    modal_log = fixture(:modal_log)
    {:ok, modal_log: modal_log}
  end
end
