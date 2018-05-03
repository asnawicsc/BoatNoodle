defmodule BoatNoodleWeb.PasswordResetsControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{created_at: "2010-04-17 14:00:00.000000Z", email: "some email", token: "some token"}
  @update_attrs %{created_at: "2011-05-18 15:01:01.000000Z", email: "some updated email", token: "some updated token"}
  @invalid_attrs %{created_at: nil, email: nil, token: nil}

  def fixture(:password_resets) do
    {:ok, password_resets} = BN.create_password_resets(@create_attrs)
    password_resets
  end

  describe "index" do
    test "lists all password_resets", %{conn: conn} do
      conn = get conn, password_resets_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Password resets"
    end
  end

  describe "new password_resets" do
    test "renders form", %{conn: conn} do
      conn = get conn, password_resets_path(conn, :new)
      assert html_response(conn, 200) =~ "New Password resets"
    end
  end

  describe "create password_resets" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, password_resets_path(conn, :create), password_resets: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == password_resets_path(conn, :show, id)

      conn = get conn, password_resets_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Password resets"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, password_resets_path(conn, :create), password_resets: @invalid_attrs
      assert html_response(conn, 200) =~ "New Password resets"
    end
  end

  describe "edit password_resets" do
    setup [:create_password_resets]

    test "renders form for editing chosen password_resets", %{conn: conn, password_resets: password_resets} do
      conn = get conn, password_resets_path(conn, :edit, password_resets)
      assert html_response(conn, 200) =~ "Edit Password resets"
    end
  end

  describe "update password_resets" do
    setup [:create_password_resets]

    test "redirects when data is valid", %{conn: conn, password_resets: password_resets} do
      conn = put conn, password_resets_path(conn, :update, password_resets), password_resets: @update_attrs
      assert redirected_to(conn) == password_resets_path(conn, :show, password_resets)

      conn = get conn, password_resets_path(conn, :show, password_resets)
      assert html_response(conn, 200) =~ "some updated email"
    end

    test "renders errors when data is invalid", %{conn: conn, password_resets: password_resets} do
      conn = put conn, password_resets_path(conn, :update, password_resets), password_resets: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Password resets"
    end
  end

  describe "delete password_resets" do
    setup [:create_password_resets]

    test "deletes chosen password_resets", %{conn: conn, password_resets: password_resets} do
      conn = delete conn, password_resets_path(conn, :delete, password_resets)
      assert redirected_to(conn) == password_resets_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, password_resets_path(conn, :show, password_resets)
      end
    end
  end

  defp create_password_resets(_) do
    password_resets = fixture(:password_resets)
    {:ok, password_resets: password_resets}
  end
end
