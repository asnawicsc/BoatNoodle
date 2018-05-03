defmodule BoatNoodleWeb.UserPwdControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{name: "some name", pass: "some pass"}
  @update_attrs %{name: "some updated name", pass: "some updated pass"}
  @invalid_attrs %{name: nil, pass: nil}

  def fixture(:user_pwd) do
    {:ok, user_pwd} = BN.create_user_pwd(@create_attrs)
    user_pwd
  end

  describe "index" do
    test "lists all user_pwd", %{conn: conn} do
      conn = get conn, user_pwd_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing User pwd"
    end
  end

  describe "new user_pwd" do
    test "renders form", %{conn: conn} do
      conn = get conn, user_pwd_path(conn, :new)
      assert html_response(conn, 200) =~ "New User pwd"
    end
  end

  describe "create user_pwd" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, user_pwd_path(conn, :create), user_pwd: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == user_pwd_path(conn, :show, id)

      conn = get conn, user_pwd_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show User pwd"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_pwd_path(conn, :create), user_pwd: @invalid_attrs
      assert html_response(conn, 200) =~ "New User pwd"
    end
  end

  describe "edit user_pwd" do
    setup [:create_user_pwd]

    test "renders form for editing chosen user_pwd", %{conn: conn, user_pwd: user_pwd} do
      conn = get conn, user_pwd_path(conn, :edit, user_pwd)
      assert html_response(conn, 200) =~ "Edit User pwd"
    end
  end

  describe "update user_pwd" do
    setup [:create_user_pwd]

    test "redirects when data is valid", %{conn: conn, user_pwd: user_pwd} do
      conn = put conn, user_pwd_path(conn, :update, user_pwd), user_pwd: @update_attrs
      assert redirected_to(conn) == user_pwd_path(conn, :show, user_pwd)

      conn = get conn, user_pwd_path(conn, :show, user_pwd)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, user_pwd: user_pwd} do
      conn = put conn, user_pwd_path(conn, :update, user_pwd), user_pwd: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User pwd"
    end
  end

  describe "delete user_pwd" do
    setup [:create_user_pwd]

    test "deletes chosen user_pwd", %{conn: conn, user_pwd: user_pwd} do
      conn = delete conn, user_pwd_path(conn, :delete, user_pwd)
      assert redirected_to(conn) == user_pwd_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, user_pwd_path(conn, :show, user_pwd)
      end
    end
  end

  defp create_user_pwd(_) do
    user_pwd = fixture(:user_pwd)
    {:ok, user_pwd: user_pwd}
  end
end
