defmodule BoatNoodleWeb.UserBranchAccessControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{branchid: 42, userbranchid: 42, userid: 42}
  @update_attrs %{branchid: 43, userbranchid: 43, userid: 43}
  @invalid_attrs %{branchid: nil, userbranchid: nil, userid: nil}

  def fixture(:user_branch_access) do
    {:ok, user_branch_access} = BN.create_user_branch_access(@create_attrs)
    user_branch_access
  end

  describe "index" do
    test "lists all user_branch_access", %{conn: conn} do
      conn = get conn, user_branch_access_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing User branch access"
    end
  end

  describe "new user_branch_access" do
    test "renders form", %{conn: conn} do
      conn = get conn, user_branch_access_path(conn, :new)
      assert html_response(conn, 200) =~ "New User branch access"
    end
  end

  describe "create user_branch_access" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, user_branch_access_path(conn, :create), user_branch_access: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == user_branch_access_path(conn, :show, id)

      conn = get conn, user_branch_access_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show User branch access"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_branch_access_path(conn, :create), user_branch_access: @invalid_attrs
      assert html_response(conn, 200) =~ "New User branch access"
    end
  end

  describe "edit user_branch_access" do
    setup [:create_user_branch_access]

    test "renders form for editing chosen user_branch_access", %{conn: conn, user_branch_access: user_branch_access} do
      conn = get conn, user_branch_access_path(conn, :edit, user_branch_access)
      assert html_response(conn, 200) =~ "Edit User branch access"
    end
  end

  describe "update user_branch_access" do
    setup [:create_user_branch_access]

    test "redirects when data is valid", %{conn: conn, user_branch_access: user_branch_access} do
      conn = put conn, user_branch_access_path(conn, :update, user_branch_access), user_branch_access: @update_attrs
      assert redirected_to(conn) == user_branch_access_path(conn, :show, user_branch_access)

      conn = get conn, user_branch_access_path(conn, :show, user_branch_access)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user_branch_access: user_branch_access} do
      conn = put conn, user_branch_access_path(conn, :update, user_branch_access), user_branch_access: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User branch access"
    end
  end

  describe "delete user_branch_access" do
    setup [:create_user_branch_access]

    test "deletes chosen user_branch_access", %{conn: conn, user_branch_access: user_branch_access} do
      conn = delete conn, user_branch_access_path(conn, :delete, user_branch_access)
      assert redirected_to(conn) == user_branch_access_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, user_branch_access_path(conn, :show, user_branch_access)
      end
    end
  end

  defp create_user_branch_access(_) do
    user_branch_access = fixture(:user_branch_access)
    {:ok, user_branch_access: user_branch_access}
  end
end
