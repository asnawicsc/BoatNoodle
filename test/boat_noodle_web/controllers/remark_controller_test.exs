defmodule BoatNoodleWeb.RemarkControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{remark_description: "some remark_description", target_category: "some target_category", target_item: "some target_item"}
  @update_attrs %{remark_description: "some updated remark_description", target_category: "some updated target_category", target_item: "some updated target_item"}
  @invalid_attrs %{remark_description: nil, target_category: nil, target_item: nil}

  def fixture(:remark) do
    {:ok, remark} = BN.create_remark(@create_attrs)
    remark
  end

  describe "index" do
    test "lists all remark", %{conn: conn} do
      conn = get conn, remark_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Remark"
    end
  end

  describe "new remark" do
    test "renders form", %{conn: conn} do
      conn = get conn, remark_path(conn, :new)
      assert html_response(conn, 200) =~ "New Remark"
    end
  end

  describe "create remark" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, remark_path(conn, :create), remark: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == remark_path(conn, :show, id)

      conn = get conn, remark_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Remark"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, remark_path(conn, :create), remark: @invalid_attrs
      assert html_response(conn, 200) =~ "New Remark"
    end
  end

  describe "edit remark" do
    setup [:create_remark]

    test "renders form for editing chosen remark", %{conn: conn, remark: remark} do
      conn = get conn, remark_path(conn, :edit, remark)
      assert html_response(conn, 200) =~ "Edit Remark"
    end
  end

  describe "update remark" do
    setup [:create_remark]

    test "redirects when data is valid", %{conn: conn, remark: remark} do
      conn = put conn, remark_path(conn, :update, remark), remark: @update_attrs
      assert redirected_to(conn) == remark_path(conn, :show, remark)

      conn = get conn, remark_path(conn, :show, remark)
      assert html_response(conn, 200) =~ "some updated remark_description"
    end

    test "renders errors when data is invalid", %{conn: conn, remark: remark} do
      conn = put conn, remark_path(conn, :update, remark), remark: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Remark"
    end
  end

  describe "delete remark" do
    setup [:create_remark]

    test "deletes chosen remark", %{conn: conn, remark: remark} do
      conn = delete conn, remark_path(conn, :delete, remark)
      assert redirected_to(conn) == remark_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, remark_path(conn, :show, remark)
      end
    end
  end

  defp create_remark(_) do
    remark = fixture(:remark)
    {:ok, remark: remark}
  end
end
