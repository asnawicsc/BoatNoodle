defmodule BoatNoodleWeb.StaffTypeControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{description: "some description", id: 42, name: "some name"}
  @update_attrs %{description: "some updated description", id: 43, name: "some updated name"}
  @invalid_attrs %{description: nil, id: nil, name: nil}

  def fixture(:staff_type) do
    {:ok, staff_type} = BN.create_staff_type(@create_attrs)
    staff_type
  end

  describe "index" do
    test "lists all staff_type", %{conn: conn} do
      conn = get conn, staff_type_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Staff type"
    end
  end

  describe "new staff_type" do
    test "renders form", %{conn: conn} do
      conn = get conn, staff_type_path(conn, :new)
      assert html_response(conn, 200) =~ "New Staff type"
    end
  end

  describe "create staff_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, staff_type_path(conn, :create), staff_type: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == staff_type_path(conn, :show, id)

      conn = get conn, staff_type_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Staff type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, staff_type_path(conn, :create), staff_type: @invalid_attrs
      assert html_response(conn, 200) =~ "New Staff type"
    end
  end

  describe "edit staff_type" do
    setup [:create_staff_type]

    test "renders form for editing chosen staff_type", %{conn: conn, staff_type: staff_type} do
      conn = get conn, staff_type_path(conn, :edit, staff_type)
      assert html_response(conn, 200) =~ "Edit Staff type"
    end
  end

  describe "update staff_type" do
    setup [:create_staff_type]

    test "redirects when data is valid", %{conn: conn, staff_type: staff_type} do
      conn = put conn, staff_type_path(conn, :update, staff_type), staff_type: @update_attrs
      assert redirected_to(conn) == staff_type_path(conn, :show, staff_type)

      conn = get conn, staff_type_path(conn, :show, staff_type)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, staff_type: staff_type} do
      conn = put conn, staff_type_path(conn, :update, staff_type), staff_type: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Staff type"
    end
  end

  describe "delete staff_type" do
    setup [:create_staff_type]

    test "deletes chosen staff_type", %{conn: conn, staff_type: staff_type} do
      conn = delete conn, staff_type_path(conn, :delete, staff_type)
      assert redirected_to(conn) == staff_type_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, staff_type_path(conn, :show, staff_type)
      end
    end
  end

  defp create_staff_type(_) do
    staff_type = fixture(:staff_type)
    {:ok, staff_type: staff_type}
  end
end
