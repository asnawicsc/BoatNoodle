defmodule BoatNoodleWeb.DiscountCategoryControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{amount_percentage: 42, description: "some description", discount_catalog: "some discount_catalog", discount_type: "some discount_type", name: "some name", status: true}
  @update_attrs %{amount_percentage: 43, description: "some updated description", discount_catalog: "some updated discount_catalog", discount_type: "some updated discount_type", name: "some updated name", status: false}
  @invalid_attrs %{amount_percentage: nil, description: nil, discount_catalog: nil, discount_type: nil, name: nil, status: nil}

  def fixture(:discount_category) do
    {:ok, discount_category} = BN.create_discount_category(@create_attrs)
    discount_category
  end

  describe "index" do
    test "lists all discount_category", %{conn: conn} do
      conn = get conn, discount_category_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Discount category"
    end
  end

  describe "new discount_category" do
    test "renders form", %{conn: conn} do
      conn = get conn, discount_category_path(conn, :new)
      assert html_response(conn, 200) =~ "New Discount category"
    end
  end

  describe "create discount_category" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, discount_category_path(conn, :create), discount_category: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == discount_category_path(conn, :show, id)

      conn = get conn, discount_category_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Discount category"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, discount_category_path(conn, :create), discount_category: @invalid_attrs
      assert html_response(conn, 200) =~ "New Discount category"
    end
  end

  describe "edit discount_category" do
    setup [:create_discount_category]

    test "renders form for editing chosen discount_category", %{conn: conn, discount_category: discount_category} do
      conn = get conn, discount_category_path(conn, :edit, discount_category)
      assert html_response(conn, 200) =~ "Edit Discount category"
    end
  end

  describe "update discount_category" do
    setup [:create_discount_category]

    test "redirects when data is valid", %{conn: conn, discount_category: discount_category} do
      conn = put conn, discount_category_path(conn, :update, discount_category), discount_category: @update_attrs
      assert redirected_to(conn) == discount_category_path(conn, :show, discount_category)

      conn = get conn, discount_category_path(conn, :show, discount_category)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, discount_category: discount_category} do
      conn = put conn, discount_category_path(conn, :update, discount_category), discount_category: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Discount category"
    end
  end

  describe "delete discount_category" do
    setup [:create_discount_category]

    test "deletes chosen discount_category", %{conn: conn, discount_category: discount_category} do
      conn = delete conn, discount_category_path(conn, :delete, discount_category)
      assert redirected_to(conn) == discount_category_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, discount_category_path(conn, :show, discount_category)
      end
    end
  end

  defp create_discount_category(_) do
    discount_category = fixture(:discount_category)
    {:ok, discount_category: discount_category}
  end
end
