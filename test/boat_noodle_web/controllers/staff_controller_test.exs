defmodule BoatNoodleWeb.StaffControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{branch: "some branch", contact_number: "some contact_number", email: "some email", photo: "some photo", pin_number: 42, staff_name: "some staff_name", staff_role: "some staff_role"}
  @update_attrs %{branch: "some updated branch", contact_number: "some updated contact_number", email: "some updated email", photo: "some updated photo", pin_number: 43, staff_name: "some updated staff_name", staff_role: "some updated staff_role"}
  @invalid_attrs %{branch: nil, contact_number: nil, email: nil, photo: nil, pin_number: nil, staff_name: nil, staff_role: nil}

  def fixture(:staff) do
    {:ok, staff} = BN.create_staff(@create_attrs)
    staff
  end

  describe "index" do
    test "lists all staff", %{conn: conn} do
      conn = get conn, staff_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Staff"
    end
  end

  describe "new staff" do
    test "renders form", %{conn: conn} do
      conn = get conn, staff_path(conn, :new)
      assert html_response(conn, 200) =~ "New Staff"
    end
  end

  describe "create staff" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, staff_path(conn, :create), staff: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == staff_path(conn, :show, id)

      conn = get conn, staff_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Staff"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, staff_path(conn, :create), staff: @invalid_attrs
      assert html_response(conn, 200) =~ "New Staff"
    end
  end

  describe "edit staff" do
    setup [:create_staff]

    test "renders form for editing chosen staff", %{conn: conn, staff: staff} do
      conn = get conn, staff_path(conn, :edit, staff)
      assert html_response(conn, 200) =~ "Edit Staff"
    end
  end

  describe "update staff" do
    setup [:create_staff]

    test "redirects when data is valid", %{conn: conn, staff: staff} do
      conn = put conn, staff_path(conn, :update, staff), staff: @update_attrs
      assert redirected_to(conn) == staff_path(conn, :show, staff)

      conn = get conn, staff_path(conn, :show, staff)
      assert html_response(conn, 200) =~ "some updated branch"
    end

    test "renders errors when data is invalid", %{conn: conn, staff: staff} do
      conn = put conn, staff_path(conn, :update, staff), staff: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Staff"
    end
  end

  describe "delete staff" do
    setup [:create_staff]

    test "deletes chosen staff", %{conn: conn, staff: staff} do
      conn = delete conn, staff_path(conn, :delete, staff)
      assert redirected_to(conn) == staff_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, staff_path(conn, :show, staff)
      end
    end
  end

  defp create_staff(_) do
    staff = fixture(:staff)
    {:ok, staff: staff}
  end
end
