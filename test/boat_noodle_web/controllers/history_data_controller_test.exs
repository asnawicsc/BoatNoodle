defmodule BoatNoodleWeb.HistoryDataControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{branch_id: 42, brand_id: 42, end_date: ~D[2010-04-17], json_map: "some json_map", start_date: ~D[2010-04-17]}
  @update_attrs %{branch_id: 43, brand_id: 43, end_date: ~D[2011-05-18], json_map: "some updated json_map", start_date: ~D[2011-05-18]}
  @invalid_attrs %{branch_id: nil, brand_id: nil, end_date: nil, json_map: nil, start_date: nil}

  def fixture(:history_data) do
    {:ok, history_data} = BN.create_history_data(@create_attrs)
    history_data
  end

  describe "index" do
    test "lists all history_data", %{conn: conn} do
      conn = get conn, history_data_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing History data"
    end
  end

  describe "new history_data" do
    test "renders form", %{conn: conn} do
      conn = get conn, history_data_path(conn, :new)
      assert html_response(conn, 200) =~ "New History data"
    end
  end

  describe "create history_data" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, history_data_path(conn, :create), history_data: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == history_data_path(conn, :show, id)

      conn = get conn, history_data_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show History data"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, history_data_path(conn, :create), history_data: @invalid_attrs
      assert html_response(conn, 200) =~ "New History data"
    end
  end

  describe "edit history_data" do
    setup [:create_history_data]

    test "renders form for editing chosen history_data", %{conn: conn, history_data: history_data} do
      conn = get conn, history_data_path(conn, :edit, history_data)
      assert html_response(conn, 200) =~ "Edit History data"
    end
  end

  describe "update history_data" do
    setup [:create_history_data]

    test "redirects when data is valid", %{conn: conn, history_data: history_data} do
      conn = put conn, history_data_path(conn, :update, history_data), history_data: @update_attrs
      assert redirected_to(conn) == history_data_path(conn, :show, history_data)

      conn = get conn, history_data_path(conn, :show, history_data)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, history_data: history_data} do
      conn = put conn, history_data_path(conn, :update, history_data), history_data: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit History data"
    end
  end

  describe "delete history_data" do
    setup [:create_history_data]

    test "deletes chosen history_data", %{conn: conn, history_data: history_data} do
      conn = delete conn, history_data_path(conn, :delete, history_data)
      assert redirected_to(conn) == history_data_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, history_data_path(conn, :show, history_data)
      end
    end
  end

  defp create_history_data(_) do
    history_data = fixture(:history_data)
    {:ok, history_data: history_data}
  end
end
