defmodule BoatNoodleWeb.BranchItemDeactivateControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{branchid: 42, id: 42, is_activate: 42, itemid: 42}
  @update_attrs %{branchid: 43, id: 43, is_activate: 43, itemid: 43}
  @invalid_attrs %{branchid: nil, id: nil, is_activate: nil, itemid: nil}

  def fixture(:branch_item_deactivate) do
    {:ok, branch_item_deactivate} = BN.create_branch_item_deactivate(@create_attrs)
    branch_item_deactivate
  end

  describe "index" do
    test "lists all branch_item_deactivate", %{conn: conn} do
      conn = get conn, branch_item_deactivate_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Branch item deactivate"
    end
  end

  describe "new branch_item_deactivate" do
    test "renders form", %{conn: conn} do
      conn = get conn, branch_item_deactivate_path(conn, :new)
      assert html_response(conn, 200) =~ "New Branch item deactivate"
    end
  end

  describe "create branch_item_deactivate" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, branch_item_deactivate_path(conn, :create), branch_item_deactivate: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == branch_item_deactivate_path(conn, :show, id)

      conn = get conn, branch_item_deactivate_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Branch item deactivate"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, branch_item_deactivate_path(conn, :create), branch_item_deactivate: @invalid_attrs
      assert html_response(conn, 200) =~ "New Branch item deactivate"
    end
  end

  describe "edit branch_item_deactivate" do
    setup [:create_branch_item_deactivate]

    test "renders form for editing chosen branch_item_deactivate", %{conn: conn, branch_item_deactivate: branch_item_deactivate} do
      conn = get conn, branch_item_deactivate_path(conn, :edit, branch_item_deactivate)
      assert html_response(conn, 200) =~ "Edit Branch item deactivate"
    end
  end

  describe "update branch_item_deactivate" do
    setup [:create_branch_item_deactivate]

    test "redirects when data is valid", %{conn: conn, branch_item_deactivate: branch_item_deactivate} do
      conn = put conn, branch_item_deactivate_path(conn, :update, branch_item_deactivate), branch_item_deactivate: @update_attrs
      assert redirected_to(conn) == branch_item_deactivate_path(conn, :show, branch_item_deactivate)

      conn = get conn, branch_item_deactivate_path(conn, :show, branch_item_deactivate)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, branch_item_deactivate: branch_item_deactivate} do
      conn = put conn, branch_item_deactivate_path(conn, :update, branch_item_deactivate), branch_item_deactivate: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Branch item deactivate"
    end
  end

  describe "delete branch_item_deactivate" do
    setup [:create_branch_item_deactivate]

    test "deletes chosen branch_item_deactivate", %{conn: conn, branch_item_deactivate: branch_item_deactivate} do
      conn = delete conn, branch_item_deactivate_path(conn, :delete, branch_item_deactivate)
      assert redirected_to(conn) == branch_item_deactivate_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, branch_item_deactivate_path(conn, :show, branch_item_deactivate)
      end
    end
  end

  defp create_branch_item_deactivate(_) do
    branch_item_deactivate = fixture(:branch_item_deactivate)
    {:ok, branch_item_deactivate: branch_item_deactivate}
  end
end
