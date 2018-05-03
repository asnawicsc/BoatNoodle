defmodule BoatNoodleWeb.DiscountTypeControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{disctypeid: 42, disctypename: "some disctypename"}
  @update_attrs %{disctypeid: 43, disctypename: "some updated disctypename"}
  @invalid_attrs %{disctypeid: nil, disctypename: nil}

  def fixture(:discount_type) do
    {:ok, discount_type} = BN.create_discount_type(@create_attrs)
    discount_type
  end

  describe "index" do
    test "lists all discount_type", %{conn: conn} do
      conn = get conn, discount_type_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Discount type"
    end
  end

  describe "new discount_type" do
    test "renders form", %{conn: conn} do
      conn = get conn, discount_type_path(conn, :new)
      assert html_response(conn, 200) =~ "New Discount type"
    end
  end

  describe "create discount_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, discount_type_path(conn, :create), discount_type: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == discount_type_path(conn, :show, id)

      conn = get conn, discount_type_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Discount type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, discount_type_path(conn, :create), discount_type: @invalid_attrs
      assert html_response(conn, 200) =~ "New Discount type"
    end
  end

  describe "edit discount_type" do
    setup [:create_discount_type]

    test "renders form for editing chosen discount_type", %{conn: conn, discount_type: discount_type} do
      conn = get conn, discount_type_path(conn, :edit, discount_type)
      assert html_response(conn, 200) =~ "Edit Discount type"
    end
  end

  describe "update discount_type" do
    setup [:create_discount_type]

    test "redirects when data is valid", %{conn: conn, discount_type: discount_type} do
      conn = put conn, discount_type_path(conn, :update, discount_type), discount_type: @update_attrs
      assert redirected_to(conn) == discount_type_path(conn, :show, discount_type)

      conn = get conn, discount_type_path(conn, :show, discount_type)
      assert html_response(conn, 200) =~ "some updated disctypename"
    end

    test "renders errors when data is invalid", %{conn: conn, discount_type: discount_type} do
      conn = put conn, discount_type_path(conn, :update, discount_type), discount_type: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Discount type"
    end
  end

  describe "delete discount_type" do
    setup [:create_discount_type]

    test "deletes chosen discount_type", %{conn: conn, discount_type: discount_type} do
      conn = delete conn, discount_type_path(conn, :delete, discount_type)
      assert redirected_to(conn) == discount_type_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, discount_type_path(conn, :show, discount_type)
      end
    end
  end

  defp create_discount_type(_) do
    discount_type = fixture(:discount_type)
    {:ok, discount_type: discount_type}
  end
end
